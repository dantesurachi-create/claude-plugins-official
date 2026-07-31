-- 0009_contenidos_documentos_notificaciones.sql

-- ---------------------------------------------------------------------------
-- Biblioteca educativa (§17)
-- ---------------------------------------------------------------------------
-- Autor profesional y fecha de revision son obligatorios: un contenido sin
-- responsable identificable no se publica en una plataforma clinica.

create table contenido_educativo (
  id                    uuid primary key default gen_random_uuid(),
  categoria             text not null,
  titulo                text not null,
  resumen               text,
  formato               text not null,  -- video | infografia | articulo | faq | checklist | audio
  url                   text,
  storage_path          text,
  autor_profesional_id  uuid references usuario(id) on delete set null,
  autor_nombre          text not null,
  fecha_revision        date not null,
  nivel                 text not null default 'basico',
  duracion_min          smallint,
  especie               especie,
  publicado             boolean not null default false,
  creado_at             timestamptz not null default now(),

  constraint formato_valido check (
    formato in ('video', 'infografia', 'articulo', 'faq', 'checklist', 'audio')
  ),
  constraint tiene_fuente check (url is not null or storage_path is not null)
);

create index on contenido_educativo (categoria) where publicado;

-- FK diferida desde 0005: una actividad puede tener contenido asociado.
alter table actividad
  add constraint actividad_contenido_fk
  foreign key (contenido_id) references contenido_educativo(id) on delete set null;

-- ---------------------------------------------------------------------------
-- Documentos y consentimientos (§14, §30)
-- ---------------------------------------------------------------------------

create table documento (
  id          uuid primary key default gen_random_uuid(),
  mascota_id  uuid references mascota(id) on delete cascade,
  clinica_id  uuid not null references clinica(id) on delete restrict,
  tipo        tipo_documento not null,
  titulo      text not null,
  storage_path text not null,
  emitido_por uuid references usuario(id) on delete set null,
  emitido_at  timestamptz not null default now(),
  creado_at   timestamptz not null default now()
);

create index on documento (mascota_id, emitido_at desc);

-- FK diferida desde 0007: indicaciones preanestesicas firmadas.
alter table turno
  add constraint turno_indicaciones_fk
  foreign key (indicaciones_doc_id) references documento(id) on delete set null;

-- Consentimiento informado. NO es un booleano en la tabla de usuarios: hay que
-- poder probar QUE texto acepto la persona, CUANDO y DESDE DONDE. Un booleano
-- no prueba nada frente a un reclamo (Ley 25.326 en Argentina).
create table consentimiento (
  id             uuid primary key default gen_random_uuid(),
  usuario_id     uuid not null references usuario(id) on delete restrict,
  mascota_id     uuid references mascota(id) on delete set null,
  tipo           text not null,  -- terminos | privacidad | comunicaciones | procedimiento | anestesia
  version_texto  text not null,
  texto_hash     text not null,
  aceptado       boolean not null,
  aceptado_at    timestamptz not null default now(),
  ip             inet,
  user_agent     text,
  revocado_at    timestamptz,

  constraint tipo_valido check (
    tipo in ('terminos', 'privacidad', 'comunicaciones', 'procedimiento', 'anestesia')
  )
);

create index on consentimiento (usuario_id, tipo, aceptado_at desc);

comment on column consentimiento.texto_hash is
  'Hash del texto exacto aceptado. Permite probar que version se acepto aunque el documento cambie.';

-- ---------------------------------------------------------------------------
-- Notificaciones y politica anti-fatiga (§10)
-- ---------------------------------------------------------------------------

create table preferencia_notificacion (
  id                 uuid primary key default gen_random_uuid(),
  usuario_id         uuid not null references usuario(id) on delete cascade,
  canal              canal_notificacion not null,
  activo             boolean not null default true,
  hora_inicio        time not null default '08:00',
  hora_fin           time not null default '21:00',
  resumen_semanal    boolean not null default true,
  -- 1 = minima, 2 = normal, 3 = alta. Se reduce solo ante baja respuesta.
  nivel_insistencia  smallint not null default 2 check (nivel_insistencia between 1 and 3),
  creada_at          timestamptz not null default now(),
  unique (usuario_id, canal)
);

create table notificacion (
  id               uuid primary key default gen_random_uuid(),
  usuario_id       uuid not null references usuario(id) on delete cascade,
  mascota_id       uuid references mascota(id) on delete cascade,
  tipo             tipo_notificacion not null,
  canal            canal_notificacion not null,
  titulo           text not null,
  cuerpo           text not null,
  programada_para  timestamptz not null,
  enviada_at       timestamptz,
  leida_at         timestamptz,
  -- Cuando la politica anti-fatiga suprime un envio, queda registrado con el
  -- motivo. Sin esto no se puede auditar por que un tutor no recibio un aviso.
  suprimida_at     timestamptz,
  suprimida_motivo text,
  -- §10: "no enviar mas de dos recordatorios diarios SALVO indicacion
  -- clinica". Esta bandera es esa excepcion, y solo la puede poner un
  -- profesional al crear la indicacion.
  origen_clinico   boolean not null default false,
  creada_at        timestamptz not null default now()
);

create index on notificacion (usuario_id, programada_para);
create index on notificacion (programada_para) where enviada_at is null and suprimida_at is null;

-- EL punto unico de la politica anti-fatiga. Toda notificacion pasa por aca.
-- Si esta regla queda dispersa en cada punto de envio, se viola sola en tres
-- meses: un modulo nuevo manda push y nadie se entera.
create or replace function app.puede_notificar(
  p_usuario uuid,
  p_canal canal_notificacion,
  p_momento timestamptz default now(),
  p_origen_clinico boolean default false
) returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  pref  preferencia_notificacion%rowtype;
  enviadas_hoy integer;
begin
  -- Las alertas de origen clinico no se suprimen nunca.
  if p_origen_clinico then
    return true;
  end if;

  select * into pref
  from preferencia_notificacion
  where usuario_id = p_usuario and canal = p_canal;

  -- Sin preferencia explicita se asume el canal activo con horario por defecto.
  if not found then
    pref.activo := true;
    pref.hora_inicio := '08:00';
    pref.hora_fin := '21:00';
    pref.nivel_insistencia := 2;
  end if;

  if not pref.activo then
    return false;
  end if;

  -- Modo silencioso / franja horaria del usuario.
  if p_momento::time < pref.hora_inicio or p_momento::time > pref.hora_fin then
    return false;
  end if;

  select count(*) into enviadas_hoy
  from notificacion
  where usuario_id = p_usuario
    and enviada_at is not null
    and enviada_at::date = p_momento::date
    and not origen_clinico;

  -- Tope diario segun insistencia: 1, 2 o 3. El brief fija 2 como norma.
  return enviadas_hoy < pref.nivel_insistencia;
end;
$$;

comment on function app.puede_notificar(uuid, canal_notificacion, timestamptz, boolean) is
  'Politica anti-fatiga del §10. Punto UNICO: ninguna notificacion se envia sin pasar por aca.';

grant execute on function
  app.puede_notificar(uuid, canal_notificacion, timestamptz, boolean)
to authenticated, service_role;
