-- 0005_planes.sql — Planes dentales, actividades, adherencia y habituacion.

create table producto (
  id        uuid primary key default gen_random_uuid(),
  nombre    text not null,
  tipo      text not null,   -- pasta, gel, aditivo, cepillo, dedal, snack, dieta
  marca     text,
  notas     text,
  -- §6 del brief prohibe el comercio electronico en el MVP: esto es catalogo
  -- de referencia para las indicaciones, no un producto vendible.
  activo    boolean not null default true,
  creado_at timestamptz not null default now()
);

-- §23. Plantillas globales (clinica_id null) o propias de una clinica.
create table plantilla_plan (
  id          uuid primary key default gen_random_uuid(),
  clinica_id  uuid references clinica(id) on delete cascade,
  codigo      text not null,
  nombre      text not null,
  descripcion text,
  especie     especie,
  definicion  jsonb not null,
  activa      boolean not null default true,
  creada_at   timestamptz not null default now(),
  unique (clinica_id, codigo)
);

-- §8. El plan SIEMPRE lo crea un profesional. No hay plan generado por la app.
create table plan_dental (
  id                uuid primary key default gen_random_uuid(),
  mascota_id        uuid not null references mascota(id) on delete cascade,
  clinica_id        uuid not null references clinica(id) on delete restrict,
  profesional_id    uuid not null references usuario(id) on delete restrict,
  plantilla_id      uuid references plantilla_plan(id) on delete set null,
  evaluacion_id     uuid references evaluacion(id) on delete set null,
  objetivo          text not null,
  nivel_seguimiento text not null default 'estandar',
  tecnica           text,
  indicaciones      text,
  estado            estado_plan not null default 'borrador',
  fecha_inicio      date not null default current_date,
  fecha_revision    date,
  firmado_at        timestamptz,
  firmado_por       uuid references usuario(id) on delete restrict,
  creado_at         timestamptz not null default now(),

  constraint revision_posterior check (fecha_revision is null or fecha_revision >= fecha_inicio),
  constraint firma_completa check (
    (firmado_at is null and firmado_por is null) or
    (firmado_at is not null and firmado_por is not null)
  )
);

create index on plan_dental (mascota_id, estado);
create index on plan_dental (clinica_id, estado);
create index on plan_dental (fecha_revision) where estado = 'activo';

-- Un solo plan activo por mascota: dos planes simultaneos generan
-- recordatorios contradictorios.
create unique index un_plan_activo_por_mascota
  on plan_dental (mascota_id) where estado = 'activo';

-- Un plan solo se activa firmado por un clinico de la clinica (§23).
create or replace function app.validar_activacion_plan()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if new.estado = 'activo' then
    if new.firmado_por is null then
      raise exception 'Un plan activo debe estar firmado por un profesional';
    end if;
    if not app.es_clinico_registrado(new.firmado_por, new.clinica_id) then
      raise exception 'Solo un veterinario de la clinica puede firmar un plan dental';
    end if;
  end if;
  return new;
end;
$$;

create trigger validar_activacion_plan
  before insert or update on plan_dental
  for each row execute function app.validar_activacion_plan();

create table actividad (
  id            uuid primary key default gen_random_uuid(),
  plan_id       uuid not null references plan_dental(id) on delete cascade,
  tipo          tipo_actividad not null,
  titulo        text not null,
  instrucciones text,
  producto_id   uuid references producto(id) on delete set null,
  contenido_id  uuid,   -- FK agregada en 0009, cuando existe contenido_educativo
  -- Frecuencia: dias de la semana (1=lunes .. 7=domingo) + hora.
  -- Deliberadamente simple: cron completo es mas expresivo de lo que el
  -- dominio necesita y mucho mas dificil de explicarle al tutor.
  dias_semana   smallint[] not null default '{1,2,3,4,5,6,7}',
  hora          time not null,
  duracion_min  smallint check (duracion_min between 1 and 120),
  orden         smallint not null default 1,
  activa        boolean not null default true,
  creada_at     timestamptz not null default now(),

  constraint dias_validos check (
    array_length(dias_semana, 1) between 1 and 7
    and dias_semana <@ array[1,2,3,4,5,6,7]::smallint[]
  )
);

create index on actividad (plan_id) where activa;

-- §11. Una fila por ocurrencia. `fecha_programada` es la ocurrencia concreta
-- que se esperaba, no el momento del registro: sin eso no se puede calcular
-- adherencia ni detectar abandono.
create table registro_adherencia (
  id               uuid primary key default gen_random_uuid(),
  actividad_id     uuid not null references actividad(id) on delete cascade,
  mascota_id       uuid not null references mascota(id) on delete cascade,
  fecha_programada date not null,
  resultado        resultado_actividad not null,
  motivo           motivo_incumplimiento,
  nota             text,
  registrado_por   uuid references usuario(id) on delete set null,
  registrado_at    timestamptz not null default now(),

  unique (actividad_id, fecha_programada),

  -- Un incumplimiento sin motivo no sirve para nada en el portal.
  constraint motivo_coherente check (
    (resultado = 'realizado' and motivo is null) or
    (resultado in ('parcial', 'no_realizado'))
  )
);

create index on registro_adherencia (mascota_id, fecha_programada desc);
create index on registro_adherencia (actividad_id, fecha_programada desc);
-- Para el panel de motivos de incumplimiento del portal (§20).
create index on registro_adherencia (motivo) where motivo is not null;

-- Dolor y sangrado no son "motivos de incumplimiento" como los demas: son
-- signos clinicos. Al registrarlos se genera una alerta (trigger en 0006).

-- §9. Programa de habituacion en 5 etapas.
create table etapa_habituacion (
  numero      smallint primary key check (numero between 1 and 5),
  nombre      text not null,
  descripcion text not null,
  duracion_sugerida_dias smallint
);

create table progreso_habituacion (
  id              uuid primary key default gen_random_uuid(),
  mascota_id      uuid not null references mascota(id) on delete cascade,
  etapa           smallint not null references etapa_habituacion(numero),
  estado          text not null default 'en_curso',  -- en_curso | completada | no_tolerada | suspendida
  -- §9: el profesional puede adelantar, retroceder o suspender. Se registra
  -- quien movio la etapa para que el historial sea auditable.
  modificado_por  uuid references usuario(id) on delete set null,
  por_profesional boolean not null default false,
  nota            text,
  iniciada_at     timestamptz not null default now(),
  cerrada_at      timestamptz,

  constraint estado_valido check (estado in ('en_curso', 'completada', 'no_tolerada', 'suspendida'))
);

create index on progreso_habituacion (mascota_id, iniciada_at desc);
create unique index una_etapa_en_curso
  on progreso_habituacion (mascota_id) where estado = 'en_curso';

-- ---------------------------------------------------------------------------
-- Adherencia calculada
-- ---------------------------------------------------------------------------
-- Se calcula sobre ocurrencias ESPERADAS, no sobre registros existentes. Si se
-- calculara sobre lo registrado, un tutor que no abre la app tendria 100% de
-- adherencia, que es exactamente el paciente que hay que detectar.

create or replace function app.ocurrencias_esperadas(
  p_mascota uuid, p_desde date, p_hasta date
) returns table (actividad_id uuid, fecha date)
language sql
stable
as $$
  select a.id, d::date
  from plan_dental pl
  join actividad a on a.plan_id = pl.id and a.activa
  cross join lateral generate_series(
    greatest(p_desde, pl.fecha_inicio), p_hasta, interval '1 day'
  ) as d
  where pl.mascota_id = p_mascota
    and pl.estado = 'activo'
    -- extract(isodow) devuelve 1=lunes .. 7=domingo
    and extract(isodow from d)::smallint = any(a.dias_semana);
$$;

create or replace function app.adherencia(
  p_mascota uuid, p_desde date, p_hasta date
) returns numeric
language sql
stable
as $$
  select case
    when count(*) = 0 then null
    else round(
      100.0 * count(*) filter (
        where r.resultado = 'realizado'
      ) / count(*), 1)
  end
  from app.ocurrencias_esperadas(p_mascota, p_desde, p_hasta) o
  left join registro_adherencia r
    on r.actividad_id = o.actividad_id and r.fecha_programada = o.fecha;
$$;

comment on function app.adherencia(uuid, date, date) is
  'Porcentaje sobre ocurrencias esperadas. Null si el paciente no tenia plan activo.';

grant execute on function
  app.ocurrencias_esperadas(uuid, date, date),
  app.adherencia(uuid, date, date),
  app.edad_meses(uuid),
  app.es_tutor_de(uuid), app.es_titular_de(uuid),
  app.clinica_de_mascota(uuid), app.puede_ver_mascota(uuid),
  app.puede_tratar_mascota(uuid)
to authenticated, service_role;
