-- 0006_fotos_alertas_mensajes.sql — Fotografias, signos de alarma y mensajeria.

-- ---------------------------------------------------------------------------
-- Fotografias dentales (§12)
-- ---------------------------------------------------------------------------

create table solicitud_fotografia (
  id             uuid primary key default gen_random_uuid(),
  mascota_id     uuid not null references mascota(id) on delete cascade,
  clinica_id     uuid not null references clinica(id) on delete restrict,
  profesional_id uuid not null references usuario(id) on delete restrict,
  posiciones     posicion_fotografia[] not null,
  motivo         text,
  vence_at       timestamptz,
  cumplida_at    timestamptz,
  creada_at      timestamptz not null default now(),

  constraint posiciones_no_vacias check (array_length(posiciones, 1) >= 1)
);

create index on solicitud_fotografia (mascota_id) where cumplida_at is null;

create table fotografia (
  id                     uuid primary key default gen_random_uuid(),
  mascota_id             uuid not null references mascota(id) on delete cascade,
  clinica_id             uuid references clinica(id) on delete set null,
  solicitud_id           uuid references solicitud_fotografia(id) on delete set null,
  posicion               posicion_fotografia not null,
  -- Bucket PRIVADO de Supabase Storage. Nunca URL publica ni adivinable.
  storage_path           text not null,
  tomada_at              timestamptz not null default now(),
  comentario_tutor       text,
  subida_por             uuid references usuario(id) on delete set null,

  estado                 estado_fotografia not null default 'pendiente_revision',
  revisada_por           uuid references usuario(id) on delete restrict,
  revisada_at            timestamptz,
  comentario_profesional text,
  creada_at              timestamptz not null default now()
);

create index on fotografia (mascota_id, tomada_at desc);
create index on fotografia (clinica_id, estado) where estado = 'pendiente_revision';

-- §12: "Nunca mostrar diagnostico automatico". La contracara tecnica de esa
-- regla es que ningun estado distinto de 'pendiente_revision' puede existir
-- sin un profesional que lo haya puesto. Si esto viviera solo en la interfaz,
-- un job, una migracion o un bug podrian emitir una senal clinica sin
-- supervision — que es justo lo que el brief prohibe.
create or replace function app.validar_revision_fotografia()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if new.estado <> 'pendiente_revision' then
    if new.revisada_por is null then
      raise exception 'Una fotografia solo cambia de estado si la revisa un profesional';
    end if;
    if new.clinica_id is null
       or not app.es_clinico_registrado(new.revisada_por, new.clinica_id) then
      raise exception 'Solo un veterinario de la clinica puede revisar una fotografia';
    end if;
    new.revisada_at := coalesce(new.revisada_at, now());
  else
    if new.revisada_por is not null then
      raise exception 'Una fotografia pendiente de revision no puede tener revisor';
    end if;
  end if;
  return new;
end;
$$;

create trigger validar_revision_fotografia
  before insert or update on fotografia
  for each row execute function app.validar_revision_fotografia();

-- ---------------------------------------------------------------------------
-- Signos de alarma (§13)
-- ---------------------------------------------------------------------------
-- El componente con mas riesgo clinico del producto. La tabla guarda el
-- reporte crudo del tutor; la clasificacion es siempre humana.

create table alerta (
  id                     uuid primary key default gen_random_uuid(),
  mascota_id             uuid not null references mascota(id) on delete cascade,
  clinica_id             uuid references clinica(id) on delete set null,
  origen                 text not null default 'tutor',  -- tutor | sistema
  tipo_signo             tipo_signo_alarma,
  inicio                 timestamptz,
  intensidad             smallint check (intensidad between 1 and 5),
  come                   boolean,
  bebe                   boolean,
  dificultad_respiratoria boolean,
  descripcion            text,
  fotografia_id          uuid references fotografia(id) on delete set null,
  reportada_por          uuid references usuario(id) on delete set null,

  estado                 estado_alerta not null default 'nueva',
  -- §13: la clasificacion de gravedad la hace el profesional (§3.3). La app
  -- no calcula severidad; a lo sumo ordena la bandeja.
  clasificada_por        uuid references usuario(id) on delete restrict,
  clasificada_at         timestamptz,
  nota_profesional       text,
  -- Se registra que se mostro la derivacion a guardia, para poder auditar que
  -- el tutor recibio la indicacion de no esperar respuesta en la app.
  derivacion_mostrada_at timestamptz,
  creada_at              timestamptz not null default now()
);

create index on alerta (clinica_id, estado, creada_at desc);
create index on alerta (mascota_id, creada_at desc);

create or replace function app.validar_clasificacion_alerta()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if new.estado <> 'nueva' and new.clasificada_por is null then
    raise exception 'Una alerta solo cambia de estado si la clasifica un profesional';
  end if;
  if new.clasificada_por is not null then
    if new.clinica_id is null
       or not app.es_clinico_registrado(new.clasificada_por, new.clinica_id) then
      raise exception 'Solo un veterinario de la clinica puede clasificar una alerta';
    end if;
    new.clasificada_at := coalesce(new.clasificada_at, now());
  end if;
  return new;
end;
$$;

create trigger validar_clasificacion_alerta
  before insert or update on alerta
  for each row execute function app.validar_clasificacion_alerta();

-- Dolor y sangrado registrados como motivo de incumplimiento son signos
-- clinicos, no falta de tiempo. Generan alerta automatica para la bandeja del
-- profesional. Es la unica alerta de origen 'sistema' del MVP, y no clasifica
-- nada: solo levanta la mano.
create or replace function app.alerta_por_incumplimiento()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_clinica uuid;
begin
  if new.motivo in ('dolor', 'sangrado') then
    select clinica_id into v_clinica from mascota where id = new.mascota_id;
    insert into alerta (mascota_id, clinica_id, origen, tipo_signo, inicio,
                        descripcion, reportada_por)
    values (new.mascota_id, v_clinica, 'sistema',
            case new.motivo when 'dolor' then 'dolor'::tipo_signo_alarma
                            else 'sangrado'::tipo_signo_alarma end,
            new.registrado_at,
            'Generada automaticamente: el tutor reporto ' || new.motivo ||
            ' al registrar una actividad del plan.',
            new.registrado_por);
  end if;
  return new;
end;
$$;

create trigger alerta_por_incumplimiento
  after insert on registro_adherencia
  for each row execute function app.alerta_por_incumplimiento();

-- ---------------------------------------------------------------------------
-- Mensajeria (§24)
-- ---------------------------------------------------------------------------

create table conversacion (
  id               uuid primary key default gen_random_uuid(),
  mascota_id       uuid not null references mascota(id) on delete cascade,
  clinica_id       uuid not null references clinica(id) on delete cascade,
  asunto           text,
  abierta          boolean not null default true,
  responsable_id   uuid references usuario(id) on delete set null,
  ultimo_mensaje_at timestamptz,
  creada_at        timestamptz not null default now()
);

create index on conversacion (clinica_id, abierta, ultimo_mensaje_at desc);
create index on conversacion (mascota_id);

create table mensaje (
  id              uuid primary key default gen_random_uuid(),
  conversacion_id uuid not null references conversacion(id) on delete cascade,
  autor_id        uuid not null references usuario(id) on delete restrict,
  cuerpo          text not null,
  adjunto_path    text,
  -- §24: la IA puede sugerir borradores, pero un mensaje clinico solo sale
  -- aprobado por un profesional. Un borrador sin aprobar no se entrega.
  es_borrador_ia  boolean not null default false,
  aprobado_por    uuid references usuario(id) on delete restrict,
  aprobado_at     timestamptz,
  leido_at        timestamptz,
  creado_at       timestamptz not null default now(),

  constraint borrador_no_entregable check (
    not es_borrador_ia or aprobado_por is not null or leido_at is null
  )
);

create index on mensaje (conversacion_id, creado_at);

create or replace function app.tocar_conversacion()
returns trigger
language plpgsql
as $$
begin
  update conversacion set ultimo_mensaje_at = new.creado_at
  where id = new.conversacion_id;
  return new;
end;
$$;

create trigger tocar_conversacion
  after insert on mensaje
  for each row execute function app.tocar_conversacion();
