-- 0004_odontograma.sql — Evaluacion odontologica y odontograma veterinario.
--
-- Esta es la pieza propia del producto: no existe equivalente open source
-- (ver docs/dentapet-care/herramientas-open-source.md §4). Los odontogramas
-- disponibles usan numeracion FDI humana de 32 piezas; el perro tiene 42 y el
-- gato 30, con sistema Triadan modificado.
--
-- Decision de almacenamiento: RELACIONAL, una fila por hallazgo, mas un
-- snapshot jsonb congelado al firmar.
--   * Relacional porque el producto vive del seguimiento longitudinal: hay que
--     poder preguntar "todas las piezas 108 con reabsorcion en gatos de mas de
--     10 anios". Contra un blob jsonb eso no se consulta.
--   * Snapshot porque un odontograma firmado es un documento clinico y no
--     puede mutar cuando manana cambie el catalogo de hallazgos.
--
-- (Esto refina lo que el relevamiento de herramientas planteo como "JSON
-- versionado": el requisito real era que fuera consultable y no una imagen.
-- Filas + snapshot cumple las dos cosas.)

-- ---------------------------------------------------------------------------
-- Catalogo de piezas dentales (sistema Triadan modificado)
-- ---------------------------------------------------------------------------
-- Cuadrantes permanentes: 1 sup. der., 2 sup. izq., 3 inf. izq., 4 inf. der.
-- Cuadrantes deciduos:    5 sup. der., 6 sup. izq., 7 inf. izq., 8 inf. der.
-- Posicion dentro del cuadrante: 01-03 incisivos, 04 canino, 05-08 premolares,
-- 09-11 molares. Reglas mnemotecnicas: el canino SIEMPRE es 04 y el primer
-- molar SIEMPRE es 09.

create table pieza_dental (
  id           smallint primary key generated always as identity,
  especie      especie not null,
  triadan      smallint not null check (triadan between 101 and 811),
  cuadrante    smallint not null check (cuadrante between 1 and 8),
  posicion     smallint not null check (posicion between 1 and 11),
  arcada       arcada not null,
  lado         lado not null,
  tipo         tipo_pieza not null,
  deciduo      boolean not null,
  nombre       text not null,
  unique (especie, triadan),

  -- El numero Triadan codifica cuadrante y posicion: se verifica que las
  -- columnas derivadas no puedan contradecirlo.
  constraint triadan_coherente check (triadan = cuadrante * 100 + posicion),
  constraint arcada_coherente check (
    (cuadrante in (1, 2, 5, 6) and arcada = 'superior') or
    (cuadrante in (3, 4, 7, 8) and arcada = 'inferior')
  ),
  constraint lado_coherente check (
    (cuadrante in (1, 4, 5, 8) and lado = 'derecho') or
    (cuadrante in (2, 3, 6, 7) and lado = 'izquierdo')
  ),
  constraint deciduo_coherente check (
    (cuadrante between 1 and 4 and not deciduo) or
    (cuadrante between 5 and 8 and deciduo)
  ),
  -- Regla del 4 y del 9.
  constraint tipo_coherente check (
    (posicion between 1 and 3 and tipo = 'incisivo') or
    (posicion = 4 and tipo = 'canino') or
    (posicion between 5 and 8 and tipo = 'premolar') or
    (posicion between 9 and 11 and tipo = 'molar')
  ),
  -- Los deciduos no tienen molares en perro ni en gato.
  constraint sin_molares_deciduos check (not (deciduo and tipo = 'molar'))
);

create index on pieza_dental (especie, deciduo);

comment on table pieza_dental is
  'Catalogo inmutable. Perro: 42 permanentes + 28 deciduos. Gato: 30 + 26.';

-- ---------------------------------------------------------------------------
-- Catalogo de hallazgos
-- ---------------------------------------------------------------------------
-- Los codigos siguen la nomenclatura AVDC (American Veterinary Dental College).
-- ADVERTENCIA: la lista sembrada en 0012 debe validarse con la odontologa del
-- piloto contra el catalogo AVDC vigente ANTES de cargar el primer paciente.
-- Cambiar el vocabulario con datos ya cargados es carisimo.

create table hallazgo_tipo (
  -- Codigo estable del proyecto. Es el que viaja en la API y en el snapshot.
  codigo               text primary key,
  -- Abreviatura oficial AVDC cuando existe. Null cuando el codigo es propio
  -- (p. ej. profundidad de sondaje, que AVDC no abrevia de forma unica).
  -- Separarlos evita el error de inventar siglas y presentarlas como estandar.
  codigo_avdc          text,
  nombre               text not null,
  descripcion          text,
  ambito               ambito_hallazgo not null,
  escala               escala_hallazgo not null,
  valor_min            numeric,
  valor_max            numeric,
  -- Hallazgos que solo tienen sentido en una especie (p. ej. la
  -- gingivoestomatitis cronica felina).
  especie_exclusiva    especie,
  -- Si el hallazgo implica un acto quirurgico ya realizado, no una
  -- observacion: cambia como lo dibuja la interfaz.
  es_procedimiento     boolean not null default false,
  orden                smallint not null default 100,
  activo               boolean not null default true,

  constraint rango_coherente check (
    (escala = 'presencia'   and valor_min is null and valor_max is null) or
    (escala = 'texto'       and valor_min is null and valor_max is null) or
    (escala = 'grado_0_3'   and valor_min = 0 and valor_max = 3) or
    (escala = 'estadio_0_4' and valor_min = 0 and valor_max = 4) or
    (escala = 'estadio_1_5' and valor_min = 1 and valor_max = 5) or
    (escala = 'tipo_1_3'    and valor_min = 1 and valor_max = 3) or
    (escala = 'milimetros'  and valor_min >= 0)
  )
);

-- ---------------------------------------------------------------------------
-- Evaluacion
-- ---------------------------------------------------------------------------

create table evaluacion (
  id                uuid primary key default gen_random_uuid(),
  mascota_id        uuid not null references mascota(id) on delete cascade,
  clinica_id        uuid not null references clinica(id) on delete restrict,
  profesional_id    uuid not null references usuario(id) on delete restrict,
  tipo              tipo_evaluacion not null,
  fecha             timestamptz not null default now(),

  -- Hallazgos generales de boca. Los indices por pieza van al odontograma.
  dolor             boolean,
  halitosis         smallint check (halitosis between 0 and 3),
  placa             smallint check (placa between 0 and 3),
  calculo           smallint check (calculo between 0 and 3),
  gingivitis        smallint check (gingivitis between 0 and 3),
  observaciones     text,

  -- §22: el nivel de riesgo lo fija el profesional en la evaluacion. Es el
  -- unico lugar del esquema donde se escribe.
  nivel_riesgo      nivel_riesgo,

  firmada_at        timestamptz,
  firmada_por       uuid references usuario(id) on delete restrict,
  creada_at         timestamptz not null default now(),

  constraint firma_completa check (
    (firmada_at is null and firmada_por is null) or
    (firmada_at is not null and firmada_por is not null)
  )
);

create index on evaluacion (mascota_id, fecha desc);
create index on evaluacion (clinica_id, fecha desc);

-- ---------------------------------------------------------------------------
-- Odontograma
-- ---------------------------------------------------------------------------

create table odontograma (
  id             uuid primary key default gen_random_uuid(),
  evaluacion_id  uuid not null unique references evaluacion(id) on delete cascade,
  mascota_id     uuid not null references mascota(id) on delete cascade,
  clinica_id     uuid not null references clinica(id) on delete restrict,
  especie        especie not null,
  profesional_id uuid not null references usuario(id) on delete restrict,
  fecha          timestamptz not null default now(),
  estado         estado_odontograma not null default 'borrador',
  -- Congelado al firmar por el trigger `app.congelar_odontograma`.
  snapshot       jsonb,
  firmado_at     timestamptz,
  firmado_por    uuid references usuario(id) on delete restrict,
  creado_at      timestamptz not null default now(),

  constraint firmado_coherente check (
    (estado = 'borrador' and firmado_at is null and firmado_por is null and snapshot is null) or
    (estado = 'firmado'  and firmado_at is not null and firmado_por is not null and snapshot is not null)
  )
);

create index on odontograma (mascota_id, fecha desc);

create table odontograma_hallazgo (
  id              uuid primary key default gen_random_uuid(),
  odontograma_id  uuid not null references odontograma(id) on delete cascade,
  -- Null cuando el hallazgo es de boca (ambito = 'boca').
  pieza_id        smallint references pieza_dental(id) on delete restrict,
  hallazgo_codigo text not null references hallazgo_tipo(codigo) on delete restrict,
  superficies     superficie_dental[],
  valor_numerico  numeric,
  valor_texto     text,
  nota            text,
  registrado_por  uuid not null references usuario(id) on delete restrict,
  creado_at       timestamptz not null default now()
);

create index on odontograma_hallazgo (odontograma_id);
create index on odontograma_hallazgo (hallazgo_codigo);
create index on odontograma_hallazgo (pieza_id);

-- Un mismo hallazgo no se repite sobre la misma pieza en el mismo odontograma.
create unique index hallazgo_unico_por_pieza
  on odontograma_hallazgo (odontograma_id, pieza_id, hallazgo_codigo)
  where pieza_id is not null;

create unique index hallazgo_unico_de_boca
  on odontograma_hallazgo (odontograma_id, hallazgo_codigo)
  where pieza_id is null;

-- ---------------------------------------------------------------------------
-- Validacion de hallazgos
-- ---------------------------------------------------------------------------
-- Esto no se puede expresar con CHECK porque cruza tres tablas. Va en trigger,
-- que es la unica forma de que sea inviolable desde cualquier cliente.

create or replace function app.validar_hallazgo()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  h  hallazgo_tipo%rowtype;
  p  pieza_dental%rowtype;
  o  odontograma%rowtype;
begin
  select * into o from odontograma where id = new.odontograma_id;
  select * into h from hallazgo_tipo where codigo = new.hallazgo_codigo;

  if not h.activo then
    raise exception 'El hallazgo % esta dado de baja en el catalogo', h.codigo;
  end if;

  -- Un odontograma firmado es un documento: no se le agregan ni modifican
  -- hallazgos. Se crea uno nuevo en una evaluacion nueva.
  if o.estado = 'firmado' then
    raise exception 'El odontograma % esta firmado y no admite cambios', o.id;
  end if;

  -- Coherencia de ambito.
  if h.ambito = 'pieza' and new.pieza_id is null then
    raise exception 'El hallazgo % requiere una pieza dental', h.codigo;
  end if;
  if h.ambito = 'boca' and new.pieza_id is not null then
    raise exception 'El hallazgo % es de boca y no admite pieza', h.codigo;
  end if;

  -- La pieza tiene que pertenecer a la especie del paciente. Sin esto se
  -- pueden cargar molares mandibulares 311 en un gato, que no existen.
  if new.pieza_id is not null then
    select * into p from pieza_dental where id = new.pieza_id;
    if p.especie <> o.especie then
      raise exception 'La pieza % (Triadan %) no corresponde a la especie %',
        p.id, p.triadan, o.especie;
    end if;
    -- Superficie palatina solo en maxilar, lingual solo en mandibula.
    if 'palatina' = any(new.superficies) and p.arcada <> 'superior' then
      raise exception 'La superficie palatina solo aplica a piezas maxilares (Triadan %)', p.triadan;
    end if;
    if 'lingual' = any(new.superficies) and p.arcada <> 'inferior' then
      raise exception 'La superficie lingual solo aplica a piezas mandibulares (Triadan %)', p.triadan;
    end if;
  end if;

  if h.especie_exclusiva is not null and h.especie_exclusiva <> o.especie then
    raise exception 'El hallazgo % solo aplica a la especie %', h.codigo, h.especie_exclusiva;
  end if;

  -- Coherencia del valor con la escala declarada.
  if h.escala = 'presencia' then
    if new.valor_numerico is not null then
      raise exception 'El hallazgo % no admite valor numerico', h.codigo;
    end if;
  elsif h.escala = 'texto' then
    if new.valor_texto is null then
      raise exception 'El hallazgo % requiere descripcion', h.codigo;
    end if;
  else
    if new.valor_numerico is null then
      raise exception 'El hallazgo % requiere un valor en escala %', h.codigo, h.escala;
    end if;
    if new.valor_numerico < h.valor_min
       or (h.valor_max is not null and new.valor_numerico > h.valor_max) then
      raise exception 'Valor % fuera de rango para % (escala %: % a %)',
        new.valor_numerico, h.codigo, h.escala, h.valor_min, h.valor_max;
    end if;
  end if;

  return new;
end;
$$;

create trigger validar_hallazgo
  before insert or update on odontograma_hallazgo
  for each row execute function app.validar_hallazgo();

-- ---------------------------------------------------------------------------
-- Firma del odontograma
-- ---------------------------------------------------------------------------
-- Al pasar a 'firmado' se materializa el snapshot. El odontograma firmado es
-- inmutable: cualquier UPDATE posterior se rechaza.

create or replace function app.congelar_odontograma()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if old.estado = 'firmado' then
    raise exception 'El odontograma % ya fue firmado y es inmutable', old.id;
  end if;

  if new.estado = 'firmado' then
    if new.firmado_por is null then
      new.firmado_por := app.uid();
    end if;
    if not app.es_clinico_registrado(new.firmado_por, new.clinica_id) then
      raise exception 'Solo un veterinario de la clinica puede firmar un odontograma';
    end if;
    new.firmado_at := coalesce(new.firmado_at, now());
    new.snapshot := jsonb_build_object(
      'version_esquema', 1,
      'especie', new.especie,
      'fecha', new.fecha,
      'profesional_id', new.profesional_id,
      'firmado_por', new.firmado_por,
      'firmado_at', new.firmado_at,
      'hallazgos', coalesce((
        select jsonb_agg(jsonb_build_object(
                 'triadan', p.triadan,
                 'pieza', p.nombre,
                 'codigo', oh.hallazgo_codigo,
                 'hallazgo', ht.nombre,
                 'ambito', ht.ambito,
                 'escala', ht.escala,
                 'superficies', oh.superficies,
                 'valor_numerico', oh.valor_numerico,
                 'valor_texto', oh.valor_texto,
                 'nota', oh.nota
               ) order by p.triadan nulls first, oh.hallazgo_codigo)
        from odontograma_hallazgo oh
        join hallazgo_tipo ht on ht.codigo = oh.hallazgo_codigo
        left join pieza_dental p on p.id = oh.pieza_id
        where oh.odontograma_id = new.id
      ), '[]'::jsonb)
    );
  end if;

  return new;
end;
$$;

create trigger congelar_odontograma
  before update on odontograma
  for each row execute function app.congelar_odontograma();

-- Coherencia de especie entre odontograma y paciente.
create or replace function app.validar_especie_odontograma()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  e especie;
begin
  select especie into e from mascota where id = new.mascota_id;
  if e is distinct from new.especie then
    raise exception 'La especie del odontograma (%) no coincide con la del paciente (%)',
      new.especie, e;
  end if;
  return new;
end;
$$;

create trigger validar_especie_odontograma
  before insert on odontograma
  for each row execute function app.validar_especie_odontograma();

-- ---------------------------------------------------------------------------
-- Vista de lectura para el portal
-- ---------------------------------------------------------------------------
-- Devuelve las 42/30 piezas de la especie del paciente con sus hallazgos, aun
-- las sanas: la interfaz necesita dibujar la arcada completa, no solo lo
-- marcado. `security_invoker` hace que respete la RLS del que consulta.

create view v_odontograma_piezas
with (security_invoker = true) as
select
  o.id                                   as odontograma_id,
  o.mascota_id,
  o.clinica_id,
  o.estado,
  p.id                                   as pieza_id,
  p.triadan,
  p.nombre                               as pieza,
  p.arcada,
  p.lado,
  p.tipo,
  p.deciduo,
  coalesce(
    jsonb_agg(
      jsonb_build_object(
        'codigo', oh.hallazgo_codigo,
        'nombre', ht.nombre,
        'superficies', oh.superficies,
        'valor_numerico', oh.valor_numerico,
        'valor_texto', oh.valor_texto,
        'nota', oh.nota
      ) order by ht.orden
    ) filter (where oh.id is not null),
    '[]'::jsonb
  )                                      as hallazgos
from odontograma o
join pieza_dental p on p.especie = o.especie
left join odontograma_hallazgo oh on oh.odontograma_id = o.id and oh.pieza_id = p.id
left join hallazgo_tipo ht on ht.codigo = oh.hallazgo_codigo
group by o.id, o.mascota_id, o.clinica_id, o.estado,
         p.id, p.triadan, p.nombre, p.arcada, p.lado, p.tipo, p.deciduo;

comment on view v_odontograma_piezas is
  'Arcada completa por odontograma, con hallazgos por pieza. Incluye piezas sanas.';
