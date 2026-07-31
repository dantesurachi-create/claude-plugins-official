-- 0001_base.sql — Extensiones, esquemas, roles y tipos enumerados.
--
-- Convenciones de todo el esquema:
--   * Las tablas viven en `public` para que PostREST/Supabase las exponga.
--   * Las funciones auxiliares viven en `app` y NO se exponen por la API.
--   * Todo identificador es uuid v4 generado en la base.
--   * Toda tabla clínica lleva `clinica_id`: es la unidad de aislamiento (§30).
--   * Nombres en español, sin tildes en identificadores SQL.

create extension if not exists pgcrypto;    -- gen_random_uuid()
create extension if not exists btree_gist;  -- EXCLUDE con igualdad + rango
create extension if not exists citext;      -- emails case-insensitive

create schema if not exists app;

-- Roles de Supabase. En un proyecto Supabase ya existen; el bloque los crea
-- localmente para que estas migraciones corran igual en una base limpia.
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin noinherit bypassrls;
  end if;
end $$;

grant usage on schema public to anon, authenticated, service_role;
grant usage on schema app to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Identidad del usuario en curso
-- ---------------------------------------------------------------------------
-- Resuelve el usuario autenticado desde el JWT (Supabase) o desde un GUC
-- (tests locales y jobs). Es el unico punto del esquema que sabe de donde
-- sale la identidad: si manana se cambia de proveedor de auth, se toca aca.
create or replace function app.uid()
returns uuid
language sql
stable
as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), '')::uuid,
    nullif(current_setting('request.jwt.claims', true)::jsonb ->> 'sub', '')::uuid,
    nullif(current_setting('app.usuario_actual', true), '')::uuid
  );
$$;

-- ---------------------------------------------------------------------------
-- Tipos enumerados
-- ---------------------------------------------------------------------------

-- §3 del brief. `tutor` no se almacena como membresia de clinica: se deriva
-- del vinculo tutor_mascota. Los demas son roles dentro de una clinica.
create type rol_clinica as enum (
  'veterinario_generalista',
  'veterinario_odontologo',
  'asistente',
  'admin_clinica'
);

create type especie as enum ('perro', 'gato');
create type sexo as enum ('macho', 'hembra');

-- El nivel de riesgo SOLO lo fija un profesional (§5, §22). No hay valor
-- calculado por la aplicacion ni derivado del cuestionario inicial.
create type nivel_riesgo as enum ('bajo', 'moderado', 'alto', 'muy_alto');

create type tipo_evaluacion as enum ('inicial', 'control', 'odontologica', 'posoperatoria');

create type tipo_actividad as enum (
  'cepillado', 'adaptacion_contacto', 'pasta_veterinaria', 'gel', 'aditivo',
  'dieta_dental', 'snack_dental', 'revision_visual', 'fotografia',
  'control_veterinario', 'medicacion', 'seguimiento_posprocedimiento'
);

create type estado_plan as enum ('borrador', 'activo', 'pausado', 'finalizado');

create type resultado_actividad as enum ('realizado', 'parcial', 'no_realizado');

-- §11. Los motivos son cerrados a proposito: alimentan las metricas de
-- incumplimiento del portal, y texto libre no se puede agregar.
create type motivo_incumplimiento as enum (
  'rechazo_animal', 'sin_tiempo', 'falta_producto', 'dolor', 'sangrado',
  'olvido', 'otro'
);

create type posicion_fotografia as enum (
  'frontal', 'lateral_derecha', 'lateral_izquierda', 'superior', 'inferior',
  'zona_especifica'
);

-- §12. Ningun estado distinto de 'pendiente_revision' se asigna solo:
-- la transicion exige profesional (ver trigger en 0006).
create type estado_fotografia as enum (
  'pendiente_revision', 'revisada', 'repetir', 'requiere_consulta',
  'seguimiento_habitual'
);

create type tipo_signo_alarma as enum (
  'dolor', 'sangrado', 'inflamacion', 'masa', 'secrecion', 'diente_fracturado',
  'diente_movil', 'perdida_apetito', 'dificultad_masticar', 'cambio_conducta',
  'salivacion_intensa', 'inflamacion_facial', 'traumatismo'
);

create type estado_alerta as enum (
  'nueva', 'en_revision', 'resuelta', 'derivada_guardia'
);

create type tipo_turno as enum (
  'evaluacion_inicial', 'control', 'consulta_odontologica',
  'seguimiento_posoperatorio', 'revision_prioritaria', 'videoconsulta',
  'procedimiento'
);

create type estado_turno as enum (
  'solicitado', 'confirmado', 'reprogramado', 'cancelado', 'ausente', 'realizado'
);

-- §6/§16. Estados normalizados: el resto del sistema consulta esta tabla y
-- nunca al proveedor de pago.
create type estado_suscripcion as enum (
  'en_prueba', 'activa', 'en_gracia', 'pago_fallido', 'vencida', 'cancelada'
);

create type canal_pago as enum (
  'app_store', 'google_play', 'mercado_pago', 'transferencia'
);

create type periodicidad as enum ('mensual', 'anual');

create type canal_notificacion as enum ('push', 'email', 'sms', 'whatsapp', 'in_app');

create type tipo_notificacion as enum (
  'recordatorio_actividad', 'recordatorio_amable', 'control_proximo',
  'solicitud_fotografia', 'reposicion_producto', 'alerta_clinica',
  'suscripcion', 'mensaje_clinica', 'resumen_semanal'
);

create type tipo_documento as enum (
  'consentimiento', 'presupuesto', 'informe', 'indicacion', 'receta',
  'alta_posoperatoria', 'radiografia', 'biopsia'
);

create type tipo_antecedente as enum (
  'enfermedad', 'medicacion', 'alergia', 'anestesico', 'odontologico'
);

-- ---------------------------------------------------------------------------
-- Tipos del odontograma (§4 del relevamiento de herramientas)
-- ---------------------------------------------------------------------------

create type arcada as enum ('superior', 'inferior');
create type lado as enum ('derecho', 'izquierdo');
create type tipo_pieza as enum ('incisivo', 'canino', 'premolar', 'molar');

-- Superficies dentales. En veterinaria se usa `palatina` en maxilar y
-- `lingual` en mandibula; se mantienen separadas porque la odontologa
-- las dicta distinto y colapsarlas pierde informacion.
create type superficie_dental as enum (
  'vestibular', 'palatina', 'lingual', 'mesial', 'distal', 'oclusal'
);

-- Un hallazgo aplica a una pieza concreta o a la boca entera
-- (gingivoestomatitis, halitosis, maloclusion general).
create type ambito_hallazgo as enum ('pieza', 'boca');

-- Escala de medicion del hallazgo. Determina como se valida `valor_numerico`.
create type escala_hallazgo as enum (
  'presencia',    -- esta o no esta; sin valor
  'grado_0_3',    -- movilidad, gingivitis, calculo, placa, furcacion
  'estadio_1_5',  -- reabsorcion dentaria (TR), estadios AVDC
  'estadio_0_4',  -- enfermedad periodontal (PD)
  'tipo_1_3',     -- tipo de reabsorcion dentaria
  'milimetros',   -- sondaje, recesion
  'texto'         -- descriptivo libre
);

create type estado_odontograma as enum ('borrador', 'firmado');
