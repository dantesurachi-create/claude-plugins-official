-- 0003_mascotas.sql — Mascotas, tutores, antecedentes y cuestionario inicial.

create table mascota (
  id                       uuid primary key default gen_random_uuid(),
  -- Nullable a proposito: §5 permite "continuar sin clinica". Una mascota sin
  -- clinica solo la ve su tutor; ningun profesional puede alcanzarla.
  clinica_id               uuid references clinica(id) on delete set null,
  nombre                   text not null,
  especie                  especie not null,
  raza                     text,
  sexo                     sexo,
  fecha_nacimiento         date,
  nacimiento_estimado      boolean not null default false,
  peso_kg                  numeric(5,2) check (peso_kg > 0 and peso_kg < 200),
  esterilizado             boolean,
  foto_path                text,
  microchip                text,
  profesional_habitual_id  uuid references usuario(id) on delete set null,
  alimentacion             text,
  activa                   boolean not null default true,
  creada_at                timestamptz not null default now(),

  constraint fecha_nacimiento_pasada check (fecha_nacimiento is null or fecha_nacimiento <= current_date)
);

create index on mascota (clinica_id) where activa;
create index on mascota (profesional_habitual_id);

-- Edad en meses. La app la muestra como "11 anios" pero el portal necesita
-- meses para los pacientes jovenes y para los cortes por paciente senior.
create or replace function app.edad_meses(p_mascota uuid)
returns integer
language sql
stable
as $$
  select case
    when m.fecha_nacimiento is null then null
    else (extract(year from age(current_date, m.fecha_nacimiento)) * 12
        + extract(month from age(current_date, m.fecha_nacimiento)))::integer
  end
  from mascota m where m.id = p_mascota;
$$;

-- §3.1: el tutor puede invitar a otros miembros de la familia. `titular` es
-- quien contrata la suscripcion; `miembro` puede registrar actividades pero
-- no dar de baja la mascota ni gestionar el pago.
create table tutor_mascota (
  id           uuid primary key default gen_random_uuid(),
  usuario_id   uuid not null references usuario(id) on delete cascade,
  mascota_id   uuid not null references mascota(id) on delete cascade,
  es_titular   boolean not null default false,
  activa       boolean not null default true,
  invitada_por uuid references usuario(id) on delete set null,
  creada_at    timestamptz not null default now(),
  unique (usuario_id, mascota_id)
);

create index on tutor_mascota (mascota_id) where activa;
create index on tutor_mascota (usuario_id) where activa;

-- Una sola titularidad por mascota.
create unique index un_titular_por_mascota
  on tutor_mascota (mascota_id) where es_titular and activa;

create or replace function app.es_tutor_de(p_mascota uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (select 1 from tutor_mascota
                  where mascota_id = p_mascota and usuario_id = app.uid() and activa);
$$;

create or replace function app.es_titular_de(p_mascota uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (select 1 from tutor_mascota
                  where mascota_id = p_mascota and usuario_id = app.uid()
                    and es_titular and activa);
$$;

-- Clinica a la que pertenece una mascota. Se usa en casi todas las politicas
-- RLS de tablas hijas, por eso es SECURITY DEFINER y STABLE.
create or replace function app.clinica_de_mascota(p_mascota uuid)
returns uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select clinica_id from mascota where id = p_mascota;
$$;

-- Predicado unico de lectura de una mascota: tutor vinculado, o miembro de la
-- clinica que la atiende. Toda tabla clinica hija reusa esto.
create or replace function app.puede_ver_mascota(p_mascota uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select app.es_tutor_de(p_mascota)
      or app.pertenece_a(app.clinica_de_mascota(p_mascota));
$$;

create or replace function app.puede_tratar_mascota(p_mascota uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select app.es_clinico_de(app.clinica_de_mascota(p_mascota));
$$;

create table antecedente (
  id             uuid primary key default gen_random_uuid(),
  mascota_id     uuid not null references mascota(id) on delete cascade,
  tipo           tipo_antecedente not null,
  descripcion    text not null,
  fecha          date,
  -- Un antecedente cargado por el tutor en el onboarding no tiene el mismo
  -- peso que uno cargado por la veterinaria. El portal los muestra distinto.
  cargado_por    uuid references usuario(id) on delete set null,
  es_profesional boolean not null default false,
  vigente        boolean not null default true,
  creado_at      timestamptz not null default now()
);

create index on antecedente (mascota_id, tipo) where vigente;

-- §5, pantalla 4. Las respuestas se guardan como jsonb contra un formulario
-- versionado (SurveyJS). NO hay columna de puntaje ni de riesgo: el resultado
-- del cuestionario no es un diagnostico y la app no lo presenta como tal.
create table cuestionario_inicial (
  id                 uuid primary key default gen_random_uuid(),
  mascota_id         uuid not null references mascota(id) on delete cascade,
  version_formulario text not null,
  respuestas         jsonb not null,
  respondido_por     uuid references usuario(id) on delete set null,
  creado_at          timestamptz not null default now()
);

create index on cuestionario_inicial (mascota_id, creado_at desc);

comment on table cuestionario_inicial is
  'Insumo para la evaluacion profesional. No produce nivel de riesgo (§5).';
