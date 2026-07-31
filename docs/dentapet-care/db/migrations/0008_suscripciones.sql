-- 0008_suscripciones.sql — Planes comerciales, suscripciones, pagos y webhooks.
--
-- Regla de arquitectura (§16 del brief, §6 del relevamiento): esta tabla es la
-- FUENTE DE VERDAD del estado de suscripcion. Ningun otro modulo consulta a
-- RevenueCat ni a Mercado Pago. Los webhooks de ambos proveedores escriben
-- aca, normalizando a los mismos estados. Asi las automatizaciones de
-- renovacion (§25) son independientes del medio de pago.

create table plan_comercial (
  id             uuid primary key default gen_random_uuid(),
  codigo         text not null unique,
  nombre         text not null,
  descripcion    text,
  periodicidad   periodicidad not null,
  precio         numeric(12,2) not null check (precio >= 0),
  moneda         char(3) not null default 'ARS',
  mascotas_incluidas smallint not null default 1 check (mascotas_incluidas >= 1),
  -- §16: lo que incluye y lo que NO incluye tiene que ser dato, no copy suelto
  -- en la pantalla. Se muestra sin ocultar renovacion automatica ni limites.
  incluye        jsonb not null default '[]',
  no_incluye     jsonb not null default '[]',
  revisiones_asincronicas_anuales smallint not null default 0,
  controles_incluidos_anuales     smallint not null default 0,
  dias_prueba    smallint not null default 0,
  activo         boolean not null default true,
  creado_at      timestamptz not null default now()
);

create table suscripcion (
  id                    uuid primary key default gen_random_uuid(),
  usuario_id            uuid not null references usuario(id) on delete restrict,
  plan_comercial_id     uuid not null references plan_comercial(id) on delete restrict,
  -- Una suscripcion puede haberse originado en una clinica que la bonifica.
  clinica_origen_id     uuid references clinica(id) on delete set null,
  estado                estado_suscripcion not null,
  canal                 canal_pago not null,
  -- Identificador del proveedor: app_user_id de RevenueCat o preapproval_id de
  -- Mercado Pago. Unico por canal para que un webhook duplicado no cree dos.
  id_externo            text,
  inicio                timestamptz not null default now(),
  fin_periodo           timestamptz,
  renovacion_automatica boolean not null default true,
  cancelada_at          timestamptz,
  motivo_cancelacion    text,
  actualizada_at        timestamptz not null default now(),
  creada_at             timestamptz not null default now(),

  unique (canal, id_externo)
);

create index on suscripcion (usuario_id, estado);
create index on suscripcion (estado, fin_periodo);
-- Para el aviso de renovacion a 15 y 3 dias (§25).
create index on suscripcion (fin_periodo) where estado in ('activa', 'en_prueba');

-- Un usuario no puede tener dos suscripciones vivas: si migra de canal, la
-- anterior se cierra primero.
create unique index una_suscripcion_viva_por_usuario
  on suscripcion (usuario_id)
  where estado in ('en_prueba', 'activa', 'en_gracia', 'pago_fallido');

create table pago (
  id             uuid primary key default gen_random_uuid(),
  suscripcion_id uuid not null references suscripcion(id) on delete cascade,
  monto          numeric(12,2) not null,
  moneda         char(3) not null default 'ARS',
  canal          canal_pago not null,
  id_externo     text,
  estado         text not null,   -- aprobado | rechazado | pendiente | reintegrado
  fecha          timestamptz not null default now(),
  factura_url    text,
  creado_at      timestamptz not null default now(),

  unique (canal, id_externo),
  constraint estado_valido check (estado in ('aprobado', 'rechazado', 'pendiente', 'reintegrado'))
);

create index on pago (suscripcion_id, fecha desc);

-- Idempotencia de webhooks. Los dos proveedores reintentan entregas: sin esta
-- tabla, un reintento duplica pagos o revive suscripciones canceladas.
create table evento_pago_externo (
  id            uuid primary key default gen_random_uuid(),
  canal         canal_pago not null,
  evento_id     text not null,
  tipo          text,
  payload       jsonb not null,
  recibido_at   timestamptz not null default now(),
  procesado_at  timestamptz,
  error         text,
  unique (canal, evento_id)
);

create index on evento_pago_externo (procesado_at) where procesado_at is null;

-- Acceso a beneficios: lo consulta la app antes de habilitar una revision
-- asincronica o un control incluido.
create or replace function app.suscripcion_vigente(p_usuario uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from suscripcion
    where usuario_id = p_usuario
      and estado in ('en_prueba', 'activa', 'en_gracia')
      and (fin_periodo is null or fin_periodo > now())
  );
$$;

grant execute on function app.suscripcion_vigente(uuid) to authenticated, service_role;

create or replace function app.tocar_suscripcion()
returns trigger
language plpgsql
as $$
begin
  new.actualizada_at := now();
  return new;
end;
$$;

create trigger tocar_suscripcion
  before update on suscripcion
  for each row execute function app.tocar_suscripcion();
