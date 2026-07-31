-- 0007_turnos.sql — Agenda, disponibilidad y turnos (§15).
--
-- Alcance deliberadamente acotado: una clinica, sus sucursales, sus
-- profesionales. Sin calendarios externos ni round-robin — eso llega en fase 3
-- y ahi se reevalua integrar Cal.com (ver herramientas-open-source.md §5).

create table disponibilidad (
  id             uuid primary key default gen_random_uuid(),
  profesional_id uuid not null references usuario(id) on delete cascade,
  clinica_id     uuid not null references clinica(id) on delete cascade,
  sucursal_id    uuid references sucursal(id) on delete set null,
  dia_semana     smallint not null check (dia_semana between 1 and 7),
  hora_inicio    time not null,
  hora_fin       time not null,
  vigente_desde  date not null default current_date,
  vigente_hasta  date,

  constraint franja_valida check (hora_fin > hora_inicio),
  constraint vigencia_valida check (vigente_hasta is null or vigente_hasta >= vigente_desde)
);

create index on disponibilidad (clinica_id, dia_semana);
create index on disponibilidad (profesional_id, dia_semana);

create table turno (
  id                    uuid primary key default gen_random_uuid(),
  mascota_id            uuid not null references mascota(id) on delete cascade,
  clinica_id            uuid not null references clinica(id) on delete restrict,
  sucursal_id           uuid references sucursal(id) on delete set null,
  profesional_id        uuid references usuario(id) on delete set null,
  tipo                  tipo_turno not null,
  rango                 tstzrange not null,
  estado                estado_turno not null default 'solicitado',
  motivo_consulta       text,
  -- §15: las indicaciones preanestesicas SOLO se envian si las cargo o
  -- aprobo un profesional. Por eso apuntan a un documento firmado y no a un
  -- texto libre que recepcion pueda tipear.
  indicaciones_doc_id   uuid,
  turno_anterior_id     uuid references turno(id) on delete set null,
  creado_por            uuid references usuario(id) on delete set null,
  creado_at             timestamptz not null default now(),

  constraint rango_valido check (not isempty(rango) and lower(rango) is not null)
);

create index on turno (clinica_id, estado);
create index on turno (mascota_id, rango);
create index on turno using gist (rango);

-- Sobreturnos imposibles a nivel de base de datos, no de aplicacion: dos
-- clientes concurrentes no pueden reservar la misma franja del mismo
-- profesional. Solo aplica a turnos vivos.
alter table turno add constraint sin_sobreturnos
  exclude using gist (
    profesional_id with =,
    rango with &&
  ) where (estado in ('solicitado', 'confirmado', 'reprogramado'));

-- El turno tiene que caer dentro de una franja de disponibilidad vigente del
-- profesional. Se valida en trigger porque cruza tablas.
create or replace function app.validar_turno_en_disponibilidad()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dia    smallint;
  v_inicio time;
  v_fin    time;
  v_fecha  date;
begin
  if new.profesional_id is null or new.estado in ('cancelado', 'ausente', 'realizado') then
    return new;
  end if;

  v_fecha  := (lower(new.rango))::date;
  v_dia    := extract(isodow from lower(new.rango))::smallint;
  v_inicio := (lower(new.rango))::time;
  v_fin    := (upper(new.rango))::time;

  if not exists (
    select 1 from disponibilidad d
    where d.profesional_id = new.profesional_id
      and d.dia_semana = v_dia
      and d.hora_inicio <= v_inicio
      and d.hora_fin    >= v_fin
      and d.vigente_desde <= v_fecha
      and (d.vigente_hasta is null or d.vigente_hasta >= v_fecha)
  ) then
    raise exception 'El turno cae fuera de la disponibilidad declarada del profesional';
  end if;

  return new;
end;
$$;

create trigger validar_turno_en_disponibilidad
  before insert or update on turno
  for each row execute function app.validar_turno_en_disponibilidad();

-- Franjas libres de un profesional en un dia, en pasos de N minutos.
-- Alimenta la pantalla "ver disponibilidad" de la app (§15).
create or replace function app.franjas_libres(
  p_profesional uuid, p_fecha date, p_duracion_min integer default 30
) returns table (inicio timestamptz, fin timestamptz)
language sql
stable
as $$
  with franjas as (
    select generate_series(
             (p_fecha + d.hora_inicio) at time zone current_setting('TimeZone'),
             (p_fecha + d.hora_fin) at time zone current_setting('TimeZone')
               - make_interval(mins => p_duracion_min),
             make_interval(mins => p_duracion_min)
           ) as inicio
    from disponibilidad d
    where d.profesional_id = p_profesional
      and d.dia_semana = extract(isodow from p_fecha)::smallint
      and d.vigente_desde <= p_fecha
      and (d.vigente_hasta is null or d.vigente_hasta >= p_fecha)
  )
  select f.inicio, f.inicio + make_interval(mins => p_duracion_min)
  from franjas f
  where not exists (
    select 1 from turno t
    where t.profesional_id = p_profesional
      and t.estado in ('solicitado', 'confirmado', 'reprogramado')
      and t.rango && tstzrange(f.inicio, f.inicio + make_interval(mins => p_duracion_min))
  )
  order by f.inicio;
$$;

grant execute on function app.franjas_libres(uuid, date, integer)
  to authenticated, service_role;

create table procedimiento (
  id             uuid primary key default gen_random_uuid(),
  mascota_id     uuid not null references mascota(id) on delete cascade,
  clinica_id     uuid not null references clinica(id) on delete restrict,
  profesional_id uuid not null references usuario(id) on delete restrict,
  turno_id       uuid references turno(id) on delete set null,
  tipo           text not null,  -- limpieza, extraccion, radiografia, biopsia, otro
  fecha          timestamptz not null default now(),
  -- Piezas intervenidas en numeracion Triadan. Se valida contra el catalogo.
  piezas_triadan smallint[],
  descripcion    text,
  complicaciones text,
  creado_at      timestamptz not null default now()
);

create index on procedimiento (mascota_id, fecha desc);
create index on procedimiento (clinica_id, fecha desc);

-- Las piezas registradas en un procedimiento tienen que existir en la especie
-- del paciente: sin esto se puede registrar una extraccion del 311 en un gato.
create or replace function app.validar_piezas_procedimiento()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_especie especie;
  v_triadan smallint;
begin
  if new.piezas_triadan is null or array_length(new.piezas_triadan, 1) is null then
    return new;
  end if;

  select especie into v_especie from mascota where id = new.mascota_id;

  foreach v_triadan in array new.piezas_triadan loop
    if not exists (select 1 from pieza_dental
                    where especie = v_especie and triadan = v_triadan) then
      raise exception 'La pieza Triadan % no existe en la especie %', v_triadan, v_especie;
    end if;
  end loop;

  return new;
end;
$$;

create trigger validar_piezas_procedimiento
  before insert or update on procedimiento
  for each row execute function app.validar_piezas_procedimiento();
