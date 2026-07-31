-- 0002_tenencia.sql — Clinicas, sucursales, usuarios y membresias.
--
-- Modelo de tenencia:
--   clinica 1---N sucursal
--   usuario N---N clinica  (via membresia, con rol)  -> profesionales y staff
--   usuario N---N mascota  (via tutor_mascota)       -> tutores
--
-- Un tutor NO tiene membresia de clinica. Su acceso se deriva siempre de las
-- mascotas que tiene vinculadas. Esto evita el error clasico de darle a un
-- tutor "rol en la clinica" y que despues vea de mas.

create table clinica (
  id                          uuid primary key default gen_random_uuid(),
  nombre                      text not null,
  cuit                        text,
  telefono                    text,
  email                       citext,
  direccion                   text,
  ciudad                      text,
  pais                        text not null default 'AR',
  -- §13: el flujo de signos de alarma muestra estos datos SIEMPRE, y por eso
  -- son parte de la clinica y no de una configuracion opcional.
  guardia_telefono            text,
  guardia_direccion           text,
  guardia_es_propia           boolean not null default false,
  -- §24: la mensajeria debe declarar horario y tiempo de respuesta.
  horario_atencion            text,
  respuesta_estimada_horas    integer check (respuesta_estimada_horas > 0),
  activa                      boolean not null default true,
  creada_at                   timestamptz not null default now()
);

comment on column clinica.guardia_es_propia is
  'Si es false, la app no promete respuesta y solo deriva a la guardia externa (§13).';

create table sucursal (
  id          uuid primary key default gen_random_uuid(),
  clinica_id  uuid not null references clinica(id) on delete cascade,
  nombre      text not null,
  direccion   text,
  telefono    text,
  activa      boolean not null default true,
  creada_at   timestamptz not null default now()
);

create index on sucursal (clinica_id);

-- `usuario.id` coincide con `auth.users.id` de Supabase. No se duplica la
-- contrasena ni el email verificado: eso es responsabilidad de Auth.
create table usuario (
  id              uuid primary key,
  email           citext not null unique,
  nombre          text not null,
  apellido        text not null,
  telefono        text,
  pais            text,
  ciudad          text,
  es_superadmin   boolean not null default false,
  activo          boolean not null default true,
  creado_at       timestamptz not null default now()
);

create table membresia (
  id           uuid primary key default gen_random_uuid(),
  usuario_id   uuid not null references usuario(id) on delete cascade,
  clinica_id   uuid not null references clinica(id) on delete cascade,
  rol          rol_clinica not null,
  matricula    text,
  activa       boolean not null default true,
  creada_at    timestamptz not null default now(),
  unique (usuario_id, clinica_id, rol)
);

create index on membresia (clinica_id, rol) where activa;
create index on membresia (usuario_id) where activa;

comment on column membresia.matricula is
  'Matricula profesional. Requerida para firmar indicaciones (§23).';

-- ---------------------------------------------------------------------------
-- Funciones de autorizacion
-- ---------------------------------------------------------------------------
-- Todas son SECURITY DEFINER y STABLE: las politicas RLS las invocan por fila,
-- asi que tienen que poder leer `membresia` sin disparar la RLS de esa misma
-- tabla (recursion infinita) y ser cacheables dentro de la consulta.

create or replace function app.es_superadmin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce((select es_superadmin and activo from usuario where id = app.uid()), false);
$$;

create or replace function app.roles_en(p_clinica uuid)
returns rol_clinica[]
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(array_agg(rol), '{}')
  from membresia
  where usuario_id = app.uid() and clinica_id = p_clinica and activa;
$$;

create or replace function app.pertenece_a(p_clinica uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select app.es_superadmin()
      or exists (select 1 from membresia
                  where usuario_id = app.uid() and clinica_id = p_clinica and activa);
$$;

-- "Clinico" = puede evaluar, diagnosticar y firmar. Excluye a asistente y a
-- admin_clinica: esa exclusion es el nucleo del §3.4 del brief y la unica
-- forma de que sea real es que viva en la base, no en la interfaz.
create or replace function app.es_clinico_de(p_clinica uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select app.es_superadmin()
      or exists (select 1 from membresia
                  where usuario_id = app.uid() and clinica_id = p_clinica and activa
                    and rol in ('veterinario_generalista', 'veterinario_odontologo'));
$$;

create or replace function app.es_odontologo_de(p_clinica uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select app.es_superadmin()
      or exists (select 1 from membresia
                  where usuario_id = app.uid() and clinica_id = p_clinica and activa
                    and rol = 'veterinario_odontologo');
$$;

create or replace function app.es_admin_de(p_clinica uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select app.es_superadmin()
      or exists (select 1 from membresia
                  where usuario_id = app.uid() and clinica_id = p_clinica and activa
                    and rol = 'admin_clinica');
$$;

-- Comprueba que un uuid dado sea un profesional habilitado para firmar en la
-- clinica. Se usa en constraints de firma, donde el firmante puede no ser el
-- usuario en curso (carga diferida por parte de recepcion, migraciones).
create or replace function app.es_clinico_registrado(p_usuario uuid, p_clinica uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (select 1 from membresia
                  where usuario_id = p_usuario and clinica_id = p_clinica and activa
                    and rol in ('veterinario_generalista', 'veterinario_odontologo'));
$$;

revoke execute on function
  app.es_superadmin(), app.roles_en(uuid), app.pertenece_a(uuid),
  app.es_clinico_de(uuid), app.es_odontologo_de(uuid), app.es_admin_de(uuid),
  app.es_clinico_registrado(uuid, uuid)
from public;

grant execute on function
  app.uid(), app.es_superadmin(), app.roles_en(uuid), app.pertenece_a(uuid),
  app.es_clinico_de(uuid), app.es_odontologo_de(uuid), app.es_admin_de(uuid),
  app.es_clinico_registrado(uuid, uuid)
to authenticated, service_role;
