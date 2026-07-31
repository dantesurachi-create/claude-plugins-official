-- 0012_seed_catalogos.sql — Catalogos inmutables: piezas dentales, hallazgos,
-- etapas de habituacion y plan comercial del piloto.

-- ---------------------------------------------------------------------------
-- Piezas dentales (Triadan modificado)
-- ---------------------------------------------------------------------------
-- Formulas dentarias sembradas:
--
--   PERRO permanente (42): I 3/3, C 1/1, P 4/4, M 2/3  (x2 lados)
--     maxilar   por lado: 101-110  (10 piezas)
--     mandibular por lado: 301-311 (11 piezas)
--   PERRO deciduo (28): I 3/3, C 1/1, P 3/3
--     no existe el primer premolar deciduo (505), ni molares deciduos
--
--   GATO permanente (30): I 3/3, C 1/1, P 3/2, M 1/1
--     maxilar   por lado: 101,102,103,104,106,107,108,109  (8 piezas)
--     mandibular por lado: 301,302,303,304,307,308,309      (7 piezas)
--   GATO deciduo (26): I 3/3, C 1/1, P 3/2
--
-- Las ausencias no son arbitrarias: el gato carece del primer premolar
-- maxilar (105) y del primero y segundo mandibulares (305, 306). Cargar esas
-- piezas haria que la interfaz dibuje dientes que el paciente no tiene.

create or replace function app.nombre_pieza(
  p_tipo tipo_pieza, p_posicion smallint, p_arcada arcada, p_lado lado, p_deciduo boolean
) returns text
language sql
immutable
as $$
  select initcap(p_tipo::text)
      || case
           when p_tipo = 'incisivo' then ' ' || p_posicion
           when p_tipo = 'premolar' then ' ' || (p_posicion - 4)
           when p_tipo = 'molar'    then ' ' || (p_posicion - 8)
           else ''
         end
      || ' ' || p_arcada::text
      || ' ' || p_lado::text
      || case when p_deciduo then ' (deciduo)' else '' end;
$$;

do $$
declare
  v_especie      especie;
  v_cuadrante    smallint;
  v_posicion     smallint;
  v_posiciones   smallint[];
  v_arcada       arcada;
  v_lado         lado;
  v_tipo         tipo_pieza;
  v_deciduo      boolean;
begin
  foreach v_especie in array array['perro', 'gato']::especie[] loop
    for v_cuadrante in 1..8 loop
      v_arcada  := case when v_cuadrante in (1,2,5,6) then 'superior' else 'inferior' end;
      v_lado    := case when v_cuadrante in (1,4,5,8) then 'derecho' else 'izquierdo' end;
      v_deciduo := v_cuadrante >= 5;

      v_posiciones := case
        when v_especie = 'perro' and not v_deciduo and v_arcada = 'superior'
          then array[1,2,3,4,5,6,7,8,9,10]
        when v_especie = 'perro' and not v_deciduo and v_arcada = 'inferior'
          then array[1,2,3,4,5,6,7,8,9,10,11]
        when v_especie = 'perro' and v_deciduo
          then array[1,2,3,4,6,7,8]
        when v_especie = 'gato' and not v_deciduo and v_arcada = 'superior'
          then array[1,2,3,4,6,7,8,9]
        when v_especie = 'gato' and not v_deciduo and v_arcada = 'inferior'
          then array[1,2,3,4,7,8,9]
        when v_especie = 'gato' and v_deciduo and v_arcada = 'superior'
          then array[1,2,3,4,6,7,8]
        else array[1,2,3,4,7,8]
      end::smallint[];

      foreach v_posicion in array v_posiciones loop
        v_tipo := case
          when v_posicion between 1 and 3 then 'incisivo'
          when v_posicion = 4 then 'canino'
          when v_posicion between 5 and 8 then 'premolar'
          else 'molar'
        end::tipo_pieza;

        insert into pieza_dental
          (especie, triadan, cuadrante, posicion, arcada, lado, tipo, deciduo, nombre)
        values (
          v_especie, (v_cuadrante * 100 + v_posicion)::smallint, v_cuadrante, v_posicion,
          v_arcada, v_lado, v_tipo, v_deciduo,
          app.nombre_pieza(v_tipo, v_posicion, v_arcada, v_lado, v_deciduo)
        );
      end loop;
    end loop;
  end loop;
end $$;

-- Verificacion de las formulas dentarias. Si alguien toca el bloque de arriba
-- y rompe una cuenta, la migracion falla en vez de sembrar una arcada mal.
do $$
declare
  n integer;
begin
  select count(*) into n from pieza_dental where especie = 'perro' and not deciduo;
  assert n = 42, format('Perro permanente debe tener 42 piezas, tiene %s', n);

  select count(*) into n from pieza_dental where especie = 'perro' and deciduo;
  assert n = 28, format('Perro deciduo debe tener 28 piezas, tiene %s', n);

  select count(*) into n from pieza_dental where especie = 'gato' and not deciduo;
  assert n = 30, format('Gato permanente debe tener 30 piezas, tiene %s', n);

  select count(*) into n from pieza_dental where especie = 'gato' and deciduo;
  assert n = 26, format('Gato deciduo debe tener 26 piezas, tiene %s', n);

  -- Regla del 4 y del 9.
  select count(*) into n from pieza_dental where posicion = 4 and tipo <> 'canino';
  assert n = 0, 'La posicion 04 siempre es el canino';
  select count(*) into n from pieza_dental where posicion = 9 and tipo <> 'molar';
  assert n = 0, 'La posicion 09 siempre es el primer molar';
end $$;

-- ---------------------------------------------------------------------------
-- Catalogo de hallazgos
-- ---------------------------------------------------------------------------
-- `codigo_avdc` se completa solo donde la abreviatura oficial del American
-- Veterinary Dental College es conocida y estable. Donde el proyecto define su
-- propio codigo, queda null: no se inventan siglas que parezcan estandar.
--
-- ANTES DEL PRIMER PACIENTE: validar esta lista con la odontologa del piloto
-- contra el catalogo AVDC vigente. Cambiar el vocabulario con datos cargados
-- obliga a migrar historia clinica.

insert into hallazgo_tipo
  (codigo, codigo_avdc, nombre, descripcion, ambito, escala, valor_min, valor_max,
   especie_exclusiva, es_procedimiento, orden) values

-- Periodonto
('PD',      'PD',   'Enfermedad periodontal', 'Estadio 0 a 4 segun AVDC.',
            'pieza', 'estadio_0_4', 0, 4, null, false, 10),
('GING',    null,   'Gingivitis', 'Indice de inflamacion gingival 0 a 3.',
            'pieza', 'grado_0_3', 0, 3, null, false, 11),
('SOND',    null,   'Profundidad de sondaje', 'Milimetros de bolsa periodontal.',
            'pieza', 'milimetros', 0, null, null, false, 12),
('GR',      'GR',   'Recesion gingival', 'Milimetros de recesion.',
            'pieza', 'milimetros', 0, null, null, false, 13),
('FUR',     null,   'Exposicion de furcacion', 'Grado 1 a 3 (se registra 0 si no hay).',
            'pieza', 'grado_0_3', 0, 3, null, false, 14),
('MOV',     null,   'Movilidad dentaria', 'Indice de movilidad 0 a 3.',
            'pieza', 'grado_0_3', 0, 3, null, false, 15),
('GH',      'GH',   'Hiperplasia gingival', null,
            'pieza', 'presencia', null, null, null, false, 16),
('CALC',    null,   'Calculo dental', 'Indice 0 a 3.',
            'pieza', 'grado_0_3', 0, 3, null, false, 17),
('PLACA',   null,   'Placa bacteriana', 'Indice 0 a 3.',
            'pieza', 'grado_0_3', 0, 3, null, false, 18),

-- Reabsorcion dentaria
('TR',      'TR',   'Reabsorcion dentaria', 'Estadio 1 a 5 segun AVDC.',
            'pieza', 'estadio_1_5', 1, 5, null, false, 20),
('TR_TIPO', null,   'Tipo de reabsorcion dentaria', 'Tipo 1, 2 o 3 segun aspecto radiografico.',
            'pieza', 'tipo_1_3', 1, 3, null, false, 21),

-- Fracturas y traumatismos
('EF',      'EF',   'Fractura de esmalte', 'Sin exposicion de dentina.',
            'pieza', 'presencia', null, null, null, false, 30),
('UCF',     'UCF',  'Fractura de corona no complicada', 'Sin exposicion pulpar.',
            'pieza', 'presencia', null, null, null, false, 31),
('CCF',     'CCF',  'Fractura de corona complicada', 'Con exposicion pulpar.',
            'pieza', 'presencia', null, null, null, false, 32),
('UCRF',    'UCRF', 'Fractura corona-raiz no complicada', null,
            'pieza', 'presencia', null, null, null, false, 33),
('CCRF',    'CCRF', 'Fractura corona-raiz complicada', null,
            'pieza', 'presencia', null, null, null, false, 34),
('RF',      'RF',   'Fractura radicular', null,
            'pieza', 'presencia', null, null, null, false, 35),
('AB',      'AB',   'Abrasion', 'Desgaste por contacto con material externo.',
            'pieza', 'presencia', null, null, null, false, 36),
('AT',      'AT',   'Atricion', 'Desgaste por contacto diente contra diente.',
            'pieza', 'presencia', null, null, null, false, 37),
('DISC',    null,   'Decoloracion coronaria', 'Suele indicar necrosis pulpar.',
            'pieza', 'presencia', null, null, null, false, 38),

-- Desarrollo y otras patologias
('CA',      'CA',   'Caries', 'Infrecuente en perro, muy rara en gato.',
            'pieza', 'presencia', null, null, null, false, 40),
('ED',      null,   'Defecto de esmalte', 'Hipoplasia o hipocalcificacion.',
            'pieza', 'presencia', null, null, null, false, 41),
('RD',      'RD',   'Deciduo persistente', 'Pieza decidua retenida.',
            'pieza', 'presencia', null, null, null, false, 42),
('SN',      'SN',   'Pieza supernumeraria', null,
            'pieza', 'presencia', null, null, null, false, 43),
('ROT',     null,   'Rotacion o apinamiento', null,
            'pieza', 'presencia', null, null, null, false, 44),
('AUS_C',   null,   'Ausente (congenito)', 'Pieza nunca erupcionada.',
            'pieza', 'presencia', null, null, null, false, 45),
('AUS_X',   null,   'Ausente (extraida previamente)', null,
            'pieza', 'presencia', null, null, null, false, 46),
('ONF',     'ONF',  'Fistula oronasal', 'Frecuente en canino maxilar.',
            'pieza', 'presencia', null, null, null, false, 47),

-- Hallazgos de boca
('HAL',     null,   'Halitosis', 'Intensidad 0 a 3.',
            'boca', 'grado_0_3', 0, 3, null, false, 60),
('MAL',     null,   'Maloclusion', 'Descripcion del tipo de maloclusion observada.',
            'boca', 'texto', null, null, null, false, 61),
('OM',      'OM',   'Masa oral', 'Descripcion y ubicacion. Requiere evaluacion.',
            'boca', 'texto', null, null, null, false, 62),
('FCGS',    null,   'Gingivoestomatitis cronica felina', null,
            'boca', 'presencia', null, null, 'gato', false, 63),
('ULC',     null,   'Ulcera de contacto', null,
            'boca', 'presencia', null, null, null, false, 64),

-- Procedimientos registrados sobre la pieza
('X',       'X',    'Extraccion simple cerrada', null,
            'pieza', 'presencia', null, null, null, true, 80),
('XS',      'XS',   'Extraccion quirurgica', null,
            'pieza', 'presencia', null, null, null, true, 81),
('RAD',     null,   'Radiografia dental realizada', null,
            'pieza', 'presencia', null, null, null, true, 82),
('PULI',    null,   'Pulido y destartraje realizados', null,
            'pieza', 'presencia', null, null, null, true, 83);

-- ---------------------------------------------------------------------------
-- Etapas de habituacion al cepillado (§9)
-- ---------------------------------------------------------------------------

insert into etapa_habituacion (numero, nombre, descripcion, duracion_sugerida_dias) values
(1, 'Tolerar el contacto',
    'Tocar suavemente el hocico y levantar los labios unos segundos. Reforzar en positivo. '
    'Detenerse ante cualquier senal de molestia.', 7),
(2, 'Contacto con encias',
    'Masajear suavemente la encia con el dedo limpio. Suspender ante dolor o sangrado y '
    'consultar con la clinica.', 7),
(3, 'Introduccion de la pasta',
    'Permitir que pruebe pasta veterinaria. Nunca usar pasta dental humana. '
    'Registrar la tolerancia.', 7),
(4, 'Dedal o gasa',
    'Contacto breve con movimientos suaves, priorizando las superficies externas.', 10),
(5, 'Cepillo',
    'Introduccion gradual del cepillo, aumentando el tiempo de a poco.', 14);

-- ---------------------------------------------------------------------------
-- Plan comercial del piloto (§16)
-- ---------------------------------------------------------------------------
-- Precios en cero: los define la clinica antes del lanzamiento. Lo que importa
-- del seed es la estructura de beneficios y limites, que la app muestra sin
-- ocultar la renovacion automatica.

insert into plan_comercial
  (codigo, nombre, descripcion, periodicidad, precio, moneda, mascotas_incluidas,
   incluye, no_incluye, revisiones_asincronicas_anuales, controles_incluidos_anuales,
   dias_prueba, activo) values
('control_mensual', 'DentaPet Control (mensual)',
 'Programa de prevencion y seguimiento dental con acompanamiento profesional.',
 'mensual', 0, 'ARS', 1,
 '["Aplicacion y plan personalizado","Recordatorios de higiene","Historial dental",
   "Seguimiento de adherencia","Biblioteca educativa","Un control anual incluido",
   "Dos revisiones asincronicas por ano","Prioridad de turnos",
   "Seguimiento posprocedimiento"]'::jsonb,
 '["Limpieza dental bajo anestesia","Extracciones","Radiografias dentales",
   "Medicacion","Estudios prequirurgicos","Atencion de urgencias"]'::jsonb,
 2, 1, 0, true),
('control_anual', 'DentaPet Control (anual)',
 'Mismo programa con pago anual y descuento.',
 'anual', 0, 'ARS', 1,
 '["Aplicacion y plan personalizado","Recordatorios de higiene","Historial dental",
   "Seguimiento de adherencia","Biblioteca educativa","Un control anual incluido",
   "Dos revisiones asincronicas por ano","Prioridad de turnos",
   "Seguimiento posprocedimiento"]'::jsonb,
 '["Limpieza dental bajo anestesia","Extracciones","Radiografias dentales",
   "Medicacion","Estudios prequirurgicos","Atencion de urgencias"]'::jsonb,
 2, 1, 0, true);

-- ---------------------------------------------------------------------------
-- Plantillas de plan (§23)
-- ---------------------------------------------------------------------------
-- Globales (clinica_id null). La definicion jsonb describe las actividades que
-- se instancian al aplicar la plantilla; el profesional las ajusta antes de
-- firmar.

insert into plantilla_plan (clinica_id, codigo, nombre, descripcion, especie, definicion) values
(null, 'preventivo_adulto', 'Preventivo adulto', 'Paciente adulto sin patologia periodontal establecida.', null,
 '{"actividades":[
    {"tipo":"cepillado","dias_semana":[1,2,3,4,5,6,7],"hora":"21:00","duracion_min":3},
    {"tipo":"revision_visual","dias_semana":[7],"hora":"11:00","duracion_min":2},
    {"tipo":"fotografia","dias_semana":[7],"hora":"11:15","duracion_min":5}
  ],"revision_meses":6}'::jsonb),
(null, 'raza_pequena', 'Raza pequena', 'Mayor riesgo periodontal: seguimiento mas frecuente.', 'perro',
 '{"actividades":[
    {"tipo":"cepillado","dias_semana":[1,2,3,4,5,6,7],"hora":"21:00","duracion_min":3},
    {"tipo":"aditivo","dias_semana":[1,2,3,4,5,6,7],"hora":"09:00","duracion_min":1},
    {"tipo":"fotografia","dias_semana":[7],"hora":"11:00","duracion_min":5}
  ],"revision_meses":4}'::jsonb),
(null, 'gato_adulto', 'Gato adulto', 'Adaptado a la tolerancia felina al manejo bucal.', 'gato',
 '{"actividades":[
    {"tipo":"adaptacion_contacto","dias_semana":[1,3,5],"hora":"20:00","duracion_min":2},
    {"tipo":"gel","dias_semana":[1,3,5],"hora":"20:05","duracion_min":1},
    {"tipo":"revision_visual","dias_semana":[7],"hora":"11:00","duracion_min":2}
  ],"revision_meses":6}'::jsonb),
(null, 'senior', 'Paciente senior', 'Control mas frecuente y atencion a signos de dolor.', null,
 '{"actividades":[
    {"tipo":"cepillado","dias_semana":[1,2,3,4,5,6,7],"hora":"20:00","duracion_min":2},
    {"tipo":"revision_visual","dias_semana":[3,7],"hora":"11:00","duracion_min":2}
  ],"revision_meses":4}'::jsonb),
(null, 'poslimpieza', 'Poslimpieza', 'Mantenimiento posterior a destartraje profesional.', null,
 '{"actividades":[
    {"tipo":"seguimiento_posprocedimiento","dias_semana":[1],"hora":"10:00","duracion_min":5},
    {"tipo":"cepillado","dias_semana":[1,2,3,4,5,6,7],"hora":"21:00","duracion_min":3},
    {"tipo":"fotografia","dias_semana":[7],"hora":"11:00","duracion_min":5}
  ],"revision_meses":6}'::jsonb),
(null, 'posextraccion', 'Posextraccion', 'Seguimiento a 24 h, 72 h y 7 dias.', null,
 '{"actividades":[
    {"tipo":"medicacion","dias_semana":[1,2,3,4,5,6,7],"hora":"09:00","duracion_min":1},
    {"tipo":"seguimiento_posprocedimiento","dias_semana":[1,3,7],"hora":"10:00","duracion_min":5},
    {"tipo":"fotografia","dias_semana":[7],"hora":"11:00","duracion_min":5}
  ],"revision_meses":1}'::jsonb),
(null, 'periodontal_previa', 'Enfermedad periodontal previa', 'Paciente con antecedente periodontal.', null,
 '{"actividades":[
    {"tipo":"cepillado","dias_semana":[1,2,3,4,5,6,7],"hora":"21:00","duracion_min":3},
    {"tipo":"gel","dias_semana":[1,4],"hora":"21:10","duracion_min":1},
    {"tipo":"fotografia","dias_semana":[7],"hora":"11:00","duracion_min":5}
  ],"revision_meses":3}'::jsonb),
(null, 'habituacion', 'Habituacion al cepillado', 'Programa progresivo en cinco etapas.', null,
 '{"actividades":[
    {"tipo":"adaptacion_contacto","dias_semana":[1,2,3,4,5,6,7],"hora":"20:00","duracion_min":2}
  ],"revision_meses":2,"programa_habituacion":true}'::jsonb),
(null, 'fractura_seguimiento', 'Diente fracturado en seguimiento', 'Control de pieza fracturada sin exposicion pulpar.', null,
 '{"actividades":[
    {"tipo":"revision_visual","dias_semana":[1,4],"hora":"11:00","duracion_min":2},
    {"tipo":"fotografia","dias_semana":[7],"hora":"11:15","duracion_min":5}
  ],"revision_meses":2}'::jsonb);
