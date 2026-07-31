-- pruebas.sql — Suite de verificacion del esquema.
--
-- Cubre lo que no se puede confiar a la interfaz:
--   * formulas dentarias y coherencia del odontograma
--   * inmutabilidad del odontograma firmado
--   * aislamiento entre clinicas (RLS)
--   * los "no puede" del §3.4 (asistente) y del §12 (fotografias)
--   * calculo de adherencia sobre ocurrencias esperadas
--   * imposibilidad de sobreturnos
--
-- Uso:  psql -d dentapet -v ON_ERROR_STOP=1 -f tests/pruebas.sql
-- Sin dependencias externas (no requiere pgTAP).

\set QUIET on
set client_min_messages to notice;

create schema if not exists pruebas;
-- Las secciones de RLS corren como `authenticated`: los helpers tienen que
-- seguir siendo invocables desde ese rol.
grant usage on schema pruebas to authenticated;

-- Helper: ejecuta un SQL que DEBE fallar. Si no falla, la prueba falla.
create or replace function pruebas.debe_fallar(p_sql text, p_caso text)
returns void
language plpgsql
as $$
begin
  begin
    execute p_sql;
  exception when others then
    raise notice 'OK   %  (rechazado: %)', p_caso, left(sqlerrm, 70);
    return;
  end;
  raise exception 'FALLO  %: se esperaba un rechazo y la operacion se acepto', p_caso;
end;
$$;

create or replace function pruebas.verificar(p_condicion boolean, p_caso text)
returns void
language plpgsql
as $$
begin
  if p_condicion then
    raise notice 'OK   %', p_caso;
  else
    raise exception 'FALLO  %', p_caso;
  end if;
end;
$$;

-- ===========================================================================
-- Datos de prueba
-- ===========================================================================
-- Dos clinicas independientes. La prueba central del modelo multi-clinica es
-- que la clinica B no alcance NADA de la clinica A.

do $$
declare
  cli_a uuid := '11111111-1111-1111-1111-111111111111';
  cli_b uuid := '22222222-2222-2222-2222-222222222222';
  odon_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  asis_a uuid := 'aaaaaaaa-0000-0000-0000-000000000002';
  admin_a uuid := 'aaaaaaaa-0000-0000-0000-000000000003';
  vet_b uuid := 'bbbbbbbb-0000-0000-0000-000000000001';
  tutor_a uuid := 'cccccccc-0000-0000-0000-000000000001';
  tutor_b uuid := 'cccccccc-0000-0000-0000-000000000002';
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';  -- perro, clinica A
  michi uuid := 'dddddddd-0000-0000-0000-000000000002'; -- gato, clinica B
begin
  insert into clinica (id, nombre, telefono, guardia_telefono, guardia_es_propia,
                       horario_atencion, respuesta_estimada_horas)
  values (cli_a, 'Clinica Norte', '+541100000001', '+541199999999', false,
          'Lunes a viernes de 9 a 19', 24),
         (cli_b, 'Clinica Sur', '+541100000002', null, false, 'Lunes a sabado de 8 a 20', 48);

  insert into usuario (id, email, nombre, apellido) values
    (odon_a,  'odontologa@norte.test', 'Ana',   'Odontologa'),
    (asis_a,  'recepcion@norte.test',  'Rita',  'Recepcion'),
    (admin_a, 'admin@norte.test',      'Aldo',  'Admin'),
    (vet_b,   'vet@sur.test',          'Bruno', 'Veterinario'),
    (tutor_a, 'tutor.a@correo.test',   'Tania', 'Tutora'),
    (tutor_b, 'tutor.b@correo.test',   'Tomas', 'Tutor');

  insert into membresia (usuario_id, clinica_id, rol, matricula) values
    (odon_a,  cli_a, 'veterinario_odontologo', 'MP-1234'),
    (asis_a,  cli_a, 'asistente', null),
    (admin_a, cli_a, 'admin_clinica', null),
    (vet_b,   cli_b, 'veterinario_generalista', 'MP-5678');

  insert into mascota (id, clinica_id, nombre, especie, raza, sexo, fecha_nacimiento, peso_kg)
  values (mona,  cli_a, 'Mona',  'perro', 'Bulldog frances', 'hembra', '2015-03-01', 12.5),
         (michi, cli_b, 'Michi', 'gato',  'Comun europeo',   'macho',  '2019-06-15', 4.2);

  insert into tutor_mascota (usuario_id, mascota_id, es_titular) values
    (tutor_a, mona, true),
    (tutor_b, michi, true);
end $$;

-- ===========================================================================
-- 1. Catalogo Triadan
-- ===========================================================================

do $$
begin
  perform pruebas.verificar(
    (select count(*) from pieza_dental where especie = 'perro' and not deciduo) = 42,
    'Perro permanente: 42 piezas');
  perform pruebas.verificar(
    (select count(*) from pieza_dental where especie = 'gato' and not deciduo) = 30,
    'Gato permanente: 30 piezas');
  perform pruebas.verificar(
    (select count(*) from pieza_dental where especie = 'perro' and deciduo) = 28,
    'Perro deciduo: 28 piezas');
  perform pruebas.verificar(
    (select count(*) from pieza_dental where especie = 'gato' and deciduo) = 26,
    'Gato deciduo: 26 piezas');

  -- El gato no tiene primer premolar maxilar (105) ni 305/306 mandibulares.
  perform pruebas.verificar(
    not exists (select 1 from pieza_dental where especie = 'gato' and triadan in (105, 205, 305, 306)),
    'Gato: no existen las piezas 105, 205, 305 ni 306');
  perform pruebas.verificar(
    exists (select 1 from pieza_dental where especie = 'perro' and triadan = 311),
    'Perro: existe el tercer molar mandibular (311)');
  perform pruebas.verificar(
    not exists (select 1 from pieza_dental where especie = 'gato' and triadan = 311),
    'Gato: no existe la pieza 311');
  perform pruebas.verificar(
    (select tipo from pieza_dental where especie = 'perro' and triadan = 104) = 'canino',
    'Regla del 4: la pieza 104 es el canino');
  perform pruebas.verificar(
    (select tipo from pieza_dental where especie = 'perro' and triadan = 309) = 'molar',
    'Regla del 9: la pieza 309 es el primer molar');
end $$;

-- ===========================================================================
-- 2. Odontograma: coherencia clinica
-- ===========================================================================

do $$
declare
  cli_a uuid := '11111111-1111-1111-1111-111111111111';
  odon_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';
  michi uuid := 'dddddddd-0000-0000-0000-000000000002';
  v_eval uuid;
  v_odo uuid;
  v_pieza_perro smallint;
  v_pieza_gato smallint;
  v_pieza_mandibular smallint;
begin
  insert into evaluacion (mascota_id, clinica_id, profesional_id, tipo, nivel_riesgo)
  values (mona, cli_a, odon_a, 'odontologica', 'moderado')
  returning id into v_eval;

  insert into odontograma (evaluacion_id, mascota_id, clinica_id, especie, profesional_id)
  values (v_eval, mona, cli_a, 'perro', odon_a)
  returning id into v_odo;

  select id into v_pieza_perro from pieza_dental where especie = 'perro' and triadan = 108;
  select id into v_pieza_gato  from pieza_dental where especie = 'gato'  and triadan = 108;
  select id into v_pieza_mandibular from pieza_dental where especie = 'perro' and triadan = 309;

  -- Caso valido.
  insert into odontograma_hallazgo
    (odontograma_id, pieza_id, hallazgo_codigo, superficies, valor_numerico, registrado_por)
  values (v_odo, v_pieza_perro, 'PD', array['vestibular']::superficie_dental[], 2, odon_a);
  perform pruebas.verificar(true, 'Hallazgo periodontal valido aceptado');

  -- Pieza de otra especie.
  perform pruebas.debe_fallar(format(
    'insert into odontograma_hallazgo (odontograma_id, pieza_id, hallazgo_codigo, valor_numerico, registrado_por)
     values (%L, %s, ''PD'', 1, %L)', v_odo, v_pieza_gato, odon_a),
    'Pieza felina en odontograma canino');

  -- Superficie palatina en pieza mandibular.
  perform pruebas.debe_fallar(format(
    'insert into odontograma_hallazgo (odontograma_id, pieza_id, hallazgo_codigo, superficies, valor_numerico, registrado_por)
     values (%L, %s, ''GING'', array[''palatina'']::superficie_dental[], 2, %L)',
    v_odo, v_pieza_mandibular, odon_a),
    'Superficie palatina en pieza mandibular');

  -- Valor fuera de escala (PD es estadio 0-4).
  perform pruebas.debe_fallar(format(
    'insert into odontograma_hallazgo (odontograma_id, pieza_id, hallazgo_codigo, valor_numerico, registrado_por)
     values (%L, %s, ''PD'', 7, %L)', v_odo, v_pieza_mandibular, odon_a),
    'Estadio periodontal 7 fuera de rango');

  -- Hallazgo de boca con pieza.
  perform pruebas.debe_fallar(format(
    'insert into odontograma_hallazgo (odontograma_id, pieza_id, hallazgo_codigo, valor_numerico, registrado_por)
     values (%L, %s, ''HAL'', 2, %L)', v_odo, v_pieza_perro, odon_a),
    'Halitosis (hallazgo de boca) asignada a una pieza');

  -- Hallazgo de pieza sin pieza.
  perform pruebas.debe_fallar(format(
    'insert into odontograma_hallazgo (odontograma_id, hallazgo_codigo, valor_numerico, registrado_por)
     values (%L, ''PD'', 2, %L)', v_odo, odon_a),
    'Enfermedad periodontal sin pieza asociada');

  -- Hallazgo exclusivo de gato en un perro.
  perform pruebas.debe_fallar(format(
    'insert into odontograma_hallazgo (odontograma_id, hallazgo_codigo, registrado_por)
     values (%L, ''FCGS'', %L)', v_odo, odon_a),
    'Gingivoestomatitis felina en un paciente canino');

  -- Especie del odontograma distinta de la del paciente.
  perform pruebas.debe_fallar(format(
    'insert into odontograma (evaluacion_id, mascota_id, clinica_id, especie, profesional_id)
     values (gen_random_uuid(), %L, %L, ''gato'', %L)', mona, cli_a, odon_a),
    'Odontograma felino sobre paciente canino');

  -- Firma: congela snapshot y vuelve inmutable.
  update odontograma set estado = 'firmado', firmado_por = odon_a where id = v_odo;

  perform pruebas.verificar(
    (select snapshot -> 'hallazgos' -> 0 ->> 'triadan' from odontograma where id = v_odo) = '108',
    'Al firmar se congela el snapshot con la pieza 108');

  perform pruebas.debe_fallar(format(
    'update odontograma set estado = ''borrador'' where id = %L', v_odo),
    'Modificar un odontograma ya firmado');

  perform pruebas.debe_fallar(format(
    'insert into odontograma_hallazgo (odontograma_id, pieza_id, hallazgo_codigo, valor_numerico, registrado_por)
     values (%L, %s, ''MOV'', 1, %L)', v_odo, v_pieza_mandibular, odon_a),
    'Agregar hallazgos a un odontograma firmado');

  -- La vista devuelve la arcada completa, no solo lo marcado.
  perform pruebas.verificar(
    (select count(*) from v_odontograma_piezas where odontograma_id = v_odo) = 70,
    'La vista devuelve las 70 piezas caninas (42 permanentes + 28 deciduas)');
end $$;

-- ===========================================================================
-- 3. Firma por quien no corresponde
-- ===========================================================================

do $$
declare
  cli_a uuid := '11111111-1111-1111-1111-111111111111';
  odon_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  asis_a uuid := 'aaaaaaaa-0000-0000-0000-000000000002';
  vet_b uuid := 'bbbbbbbb-0000-0000-0000-000000000001';
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';
  v_eval uuid;
  v_odo uuid;
begin
  insert into evaluacion (mascota_id, clinica_id, profesional_id, tipo)
  values (mona, cli_a, odon_a, 'control') returning id into v_eval;
  insert into odontograma (evaluacion_id, mascota_id, clinica_id, especie, profesional_id)
  values (v_eval, mona, cli_a, 'perro', odon_a) returning id into v_odo;

  perform pruebas.debe_fallar(format(
    'update odontograma set estado = ''firmado'', firmado_por = %L where id = %L', asis_a, v_odo),
    'La asistente firma un odontograma');

  perform pruebas.debe_fallar(format(
    'update odontograma set estado = ''firmado'', firmado_por = %L where id = %L', vet_b, v_odo),
    'Un veterinario de otra clinica firma el odontograma');

  -- Un plan activo sin firma profesional tampoco entra.
  perform pruebas.debe_fallar(format(
    'insert into plan_dental (mascota_id, clinica_id, profesional_id, objetivo, estado)
     values (%L, %L, %L, ''Prevencion'', ''activo'')', mona, cli_a, odon_a),
    'Plan activo sin firma profesional');

  perform pruebas.debe_fallar(format(
    'insert into plan_dental (mascota_id, clinica_id, profesional_id, objetivo, estado, firmado_at, firmado_por)
     values (%L, %L, %L, ''Prevencion'', ''activo'', now(), %L)', mona, cli_a, odon_a, asis_a),
    'Plan activo firmado por la asistente');
end $$;

-- ===========================================================================
-- 4. Fotografias: ningun estado se asigna solo (§12)
-- ===========================================================================

do $$
declare
  cli_a uuid := '11111111-1111-1111-1111-111111111111';
  odon_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  asis_a uuid := 'aaaaaaaa-0000-0000-0000-000000000002';
  tutor_a uuid := 'cccccccc-0000-0000-0000-000000000001';
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';
  v_foto uuid;
begin
  insert into fotografia (mascota_id, clinica_id, posicion, storage_path, subida_por)
  values (mona, cli_a, 'frontal', 'privado/mona/2026-07-31-frontal.jpg', tutor_a)
  returning id into v_foto;

  perform pruebas.verificar(
    (select estado from fotografia where id = v_foto) = 'pendiente_revision',
    'La fotografia nace pendiente de revision');

  perform pruebas.debe_fallar(format(
    'update fotografia set estado = ''requiere_consulta'' where id = %L', v_foto),
    'Cambiar el estado de una fotografia sin profesional');

  perform pruebas.debe_fallar(format(
    'update fotografia set estado = ''revisada'', revisada_por = %L where id = %L', asis_a, v_foto),
    'La asistente interpreta una fotografia');

  update fotografia set estado = 'seguimiento_habitual', revisada_por = odon_a,
         comentario_profesional = 'Sin cambios respecto de la serie anterior.'
  where id = v_foto;

  perform pruebas.verificar(
    (select revisada_at is not null from fotografia where id = v_foto),
    'Al revisar se sella la fecha de revision');
end $$;

-- ===========================================================================
-- 5. Adherencia sobre ocurrencias esperadas
-- ===========================================================================

do $$
declare
  cli_a uuid := '11111111-1111-1111-1111-111111111111';
  odon_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  tutor_a uuid := 'cccccccc-0000-0000-0000-000000000001';
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';
  v_plan uuid;
  v_act uuid;
  v_desde date := current_date - 6;
  d date;
  i integer := 0;
begin
  insert into plan_dental (mascota_id, clinica_id, profesional_id, objetivo, estado,
                           fecha_inicio, firmado_at, firmado_por)
  values (mona, cli_a, odon_a, 'Control de placa en paciente braquicefalo', 'activo',
          v_desde, now(), odon_a)
  returning id into v_plan;

  insert into actividad (plan_id, tipo, titulo, hora, duracion_min)
  values (v_plan, 'cepillado', 'Cepillado dental', '21:00', 3)
  returning id into v_act;

  perform pruebas.verificar(
    (select count(*) from app.ocurrencias_esperadas(mona, v_desde, current_date)) = 7,
    'Se esperan 7 ocurrencias en 7 dias con actividad diaria');

  -- Un tutor que nunca abre la app NO tiene 100% de adherencia.
  perform pruebas.verificar(
    app.adherencia(mona, v_desde, current_date) = 0.0,
    'Sin registros la adherencia es 0%, no 100%');

  -- Cuatro de siete (el ejemplo del §7 del brief).
  for d in select generate_series(v_desde, v_desde + 3, interval '1 day')::date loop
    insert into registro_adherencia (actividad_id, mascota_id, fecha_programada, resultado, registrado_por)
    values (v_act, mona, d, 'realizado', tutor_a);
  end loop;

  perform pruebas.verificar(
    app.adherencia(mona, v_desde, current_date) = 57.1,
    'Cuatro de siete cuidados completados = 57.1%');

  -- Un incumplimiento por dolor levanta una alerta automatica.
  insert into registro_adherencia (actividad_id, mascota_id, fecha_programada, resultado, motivo, registrado_por)
  values (v_act, mona, v_desde + 4, 'no_realizado', 'dolor', tutor_a);

  perform pruebas.verificar(
    exists (select 1 from alerta where mascota_id = mona and origen = 'sistema' and tipo_signo = 'dolor'),
    'Un incumplimiento por dolor genera alerta para el profesional');

  -- Un motivo en un registro cumplido no tiene sentido.
  perform pruebas.debe_fallar(format(
    'insert into registro_adherencia (actividad_id, mascota_id, fecha_programada, resultado, motivo, registrado_por)
     values (%L, %L, %L, ''realizado'', ''sin_tiempo'', %L)',
    v_act, mona, v_desde + 5, tutor_a),
    'Registro "realizado" con motivo de incumplimiento');
end $$;

-- ===========================================================================
-- 6. Turnos: sin sobreturnos ni turnos fuera de disponibilidad
-- ===========================================================================

do $$
declare
  cli_a uuid := '11111111-1111-1111-1111-111111111111';
  odon_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';
  v_lunes date := date_trunc('week', current_date + interval '7 days')::date;
  v_inicio timestamptz;
begin
  insert into disponibilidad (profesional_id, clinica_id, dia_semana, hora_inicio, hora_fin)
  values (odon_a, cli_a, 1, '09:00', '13:00');

  v_inicio := (v_lunes + time '10:00') at time zone current_setting('TimeZone');

  insert into turno (mascota_id, clinica_id, profesional_id, tipo, rango, estado)
  values (mona, cli_a, odon_a, 'consulta_odontologica',
          tstzrange(v_inicio, v_inicio + interval '30 minutes'), 'confirmado');

  perform pruebas.debe_fallar(format(
    'insert into turno (mascota_id, clinica_id, profesional_id, tipo, rango, estado)
     values (%L, %L, %L, ''control'', tstzrange(%L::timestamptz + interval ''15 minutes'',
                                                %L::timestamptz + interval ''45 minutes''), ''solicitado'')',
    mona, cli_a, odon_a, v_inicio, v_inicio),
    'Sobreturno solapado con otro turno del mismo profesional');

  perform pruebas.debe_fallar(format(
    'insert into turno (mascota_id, clinica_id, profesional_id, tipo, rango, estado)
     values (%L, %L, %L, ''control'', tstzrange(%L::timestamptz + interval ''8 hours'',
                                                %L::timestamptz + interval ''9 hours''), ''solicitado'')',
    mona, cli_a, odon_a, v_inicio, v_inicio),
    'Turno fuera de la disponibilidad declarada');

  perform pruebas.verificar(
    (select count(*) from app.franjas_libres(odon_a, v_lunes, 30)) = 7,
    'Quedan 7 franjas de 30 minutos libres de 8 posibles');
end $$;

-- ===========================================================================
-- 7. Procedimientos: piezas coherentes con la especie
-- ===========================================================================

do $$
declare
  cli_b uuid := '22222222-2222-2222-2222-222222222222';
  vet_b uuid := 'bbbbbbbb-0000-0000-0000-000000000001';
  michi uuid := 'dddddddd-0000-0000-0000-000000000002';
begin
  perform pruebas.debe_fallar(format(
    'insert into procedimiento (mascota_id, clinica_id, profesional_id, tipo, piezas_triadan)
     values (%L, %L, %L, ''extraccion'', array[311]::smallint[])', michi, cli_b, vet_b),
    'Extraccion de la pieza 311 en un gato (no existe)');

  insert into procedimiento (mascota_id, clinica_id, profesional_id, tipo, piezas_triadan)
  values (michi, cli_b, vet_b, 'extraccion', array[307, 407]::smallint[]);
  perform pruebas.verificar(true, 'Extraccion de premolares felinos 307 y 407 aceptada');
end $$;

-- ===========================================================================
-- 8. RLS: aislamiento entre clinicas y limites por rol
-- ===========================================================================
-- A partir de aca se ejecuta como rol `authenticated`, igual que la API.

do $$
declare
  cli_a uuid := '11111111-1111-1111-1111-111111111111';
  odon_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  asis_a uuid := 'aaaaaaaa-0000-0000-0000-000000000002';
  vet_b uuid := 'bbbbbbbb-0000-0000-0000-000000000001';
  tutor_a uuid := 'cccccccc-0000-0000-0000-000000000001';
  tutor_b uuid := 'cccccccc-0000-0000-0000-000000000002';
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';
  n integer;
begin
  -- --- Veterinario de la clinica B ---------------------------------------
  perform set_config('app.usuario_actual', vet_b::text, true);
  set local role authenticated;

  select count(*) into n from mascota where id = mona;
  perform pruebas.verificar(n = 0, 'La clinica B no ve al paciente de la clinica A');

  select count(*) into n from evaluacion where mascota_id = mona;
  perform pruebas.verificar(n = 0, 'La clinica B no ve las evaluaciones de la clinica A');

  select count(*) into n from fotografia where mascota_id = mona;
  perform pruebas.verificar(n = 0, 'La clinica B no ve las fotografias de la clinica A');

  select count(*) into n from odontograma where mascota_id = mona;
  perform pruebas.verificar(n = 0, 'La clinica B no ve los odontogramas de la clinica A');

  reset role;

  -- --- Tutor de otra mascota ---------------------------------------------
  perform set_config('app.usuario_actual', tutor_b::text, true);
  set local role authenticated;

  select count(*) into n from mascota where id = mona;
  perform pruebas.verificar(n = 0, 'Un tutor no ve mascotas ajenas');

  reset role;

  -- --- Tutor propio -------------------------------------------------------
  perform set_config('app.usuario_actual', tutor_a::text, true);
  set local role authenticated;

  select count(*) into n from mascota where id = mona;
  perform pruebas.verificar(n = 1, 'El tutor ve su propia mascota');

  select count(*) into n from clinica where id = cli_a;
  perform pruebas.verificar(n = 1, 'El tutor ve los datos de contacto y guardia de su clinica');

  select count(*) into n from odontograma where mascota_id = mona;
  perform pruebas.verificar(n = 2, 'El tutor ve el historial de odontogramas de su mascota');

  -- El tutor no evalua ni diagnostica.
  perform pruebas.debe_fallar(format(
    'insert into evaluacion (mascota_id, clinica_id, profesional_id, tipo, nivel_riesgo)
     values (%L, %L, %L, ''odontologica'', ''alto'')', mona, cli_a, tutor_a),
    'Un tutor crea una evaluacion clinica');

  -- Ni marca sus antecedentes como profesionales.
  perform pruebas.debe_fallar(format(
    'insert into antecedente (mascota_id, tipo, descripcion, es_profesional, cargado_por)
     values (%L, ''odontologico'', ''Periodontitis grado 3'', true, %L)', mona, tutor_a),
    'Un tutor carga un antecedente marcado como profesional');

  -- Pero si puede cargar el suyo.
  insert into antecedente (mascota_id, tipo, descripcion, es_profesional, cargado_por)
  values (mona, 'alergia', 'Reaccion a un shampoo', false, tutor_a);
  perform pruebas.verificar(true, 'El tutor carga un antecedente propio');

  reset role;

  -- --- Asistente: pertenece a la clinica pero no es clinica ---------------
  perform set_config('app.usuario_actual', asis_a::text, true);
  set local role authenticated;

  select count(*) into n from mascota where id = mona;
  perform pruebas.verificar(n = 1, 'La asistente ve a los pacientes de su clinica');

  perform pruebas.debe_fallar(format(
    'insert into evaluacion (mascota_id, clinica_id, profesional_id, tipo, nivel_riesgo)
     values (%L, %L, %L, ''odontologica'', ''alto'')', mona, cli_a, asis_a),
    'La asistente registra una evaluacion clinica');

  perform pruebas.debe_fallar(format(
    'insert into plan_dental (mascota_id, clinica_id, profesional_id, objetivo)
     values (%L, %L, %L, ''Plan propio'')', mona, cli_a, asis_a),
    'La asistente crea un plan dental');

  -- Un UPDATE bloqueado por RLS no lanza excepcion: afecta cero filas. Es la
  -- diferencia entre "prohibido" y "invisible", y hay que probarla asi.
  update evaluacion set nivel_riesgo = 'bajo' where nivel_riesgo = 'moderado';
  get diagnostics n = row_count;
  perform pruebas.verificar(n = 0, 'La asistente no puede modificar el nivel de riesgo');

  perform pruebas.debe_fallar(format(
    'insert into procedimiento (mascota_id, clinica_id, profesional_id, tipo)
     values (%L, %L, %L, ''extraccion'')', mona, cli_a, asis_a),
    'La asistente registra un procedimiento');

  -- Lo que si puede: gestionar turnos.
  select count(*) into n from turno where mascota_id = mona;
  perform pruebas.verificar(n >= 1, 'La asistente ve la agenda de su clinica');

  reset role;

  -- --- Odontologa ---------------------------------------------------------
  perform set_config('app.usuario_actual', odon_a::text, true);
  set local role authenticated;

  insert into evaluacion (mascota_id, clinica_id, profesional_id, tipo, nivel_riesgo, observaciones)
  values (mona, cli_a, odon_a, 'control', 'alto', 'Control trimestral.');
  perform pruebas.verificar(true, 'La odontologa registra una evaluacion');

  reset role;
end $$;

-- ===========================================================================
-- 9. Politica anti-fatiga (§10)
-- ===========================================================================

do $$
declare
  tutor_a uuid := 'cccccccc-0000-0000-0000-000000000001';
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';
  v_momento timestamptz := date_trunc('day', now()) + interval '10 hours';
begin
  insert into preferencia_notificacion (usuario_id, canal, hora_inicio, hora_fin, nivel_insistencia)
  values (tutor_a, 'push', '08:00', '21:00', 2);

  perform pruebas.verificar(
    app.puede_notificar(tutor_a, 'push', v_momento, false),
    'Sin envios previos se puede notificar');

  insert into notificacion (usuario_id, mascota_id, tipo, canal, titulo, cuerpo, programada_para, enviada_at)
  values (tutor_a, mona, 'recordatorio_actividad', 'push', 'Cepillado de Mona',
          'Hoy corresponde el cepillado dental de Mona.', v_momento, v_momento),
         (tutor_a, mona, 'recordatorio_amable', 'push', 'Podes intentarlo mas tarde',
          'Si no pudieron hacerlo, registra que dificultad tuvieron.', v_momento, v_momento);

  perform pruebas.verificar(
    not app.puede_notificar(tutor_a, 'push', v_momento, false),
    'Con dos envios del dia se suprime el tercero');

  perform pruebas.verificar(
    app.puede_notificar(tutor_a, 'push', v_momento, true),
    'Una notificacion de origen clinico nunca se suprime');

  perform pruebas.verificar(
    not app.puede_notificar(tutor_a, 'push', date_trunc('day', now()) + interval '23 hours', false),
    'Fuera de la franja horaria no se notifica');
end $$;

-- ===========================================================================
-- 10. Auditoria
-- ===========================================================================

do $$
declare
  mona uuid := 'dddddddd-0000-0000-0000-000000000001';
  odon_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  n integer;
begin
  perform set_config('app.usuario_actual', odon_a::text, true);
  perform set_config('app.dispositivo', 'portal-web/chrome-141', true);

  update mascota set peso_kg = 13.1 where id = mona;

  select count(*) into n from auditoria
  where tabla = 'mascota' and registro_id = mona and accion = 'UPDATE';
  perform pruebas.verificar(n = 1, 'El cambio de peso queda auditado');

  perform pruebas.verificar(
    (select campos_cambiados from auditoria
      where tabla = 'mascota' and registro_id = mona and accion = 'UPDATE'
      order by id desc limit 1) = array['peso_kg'],
    'La auditoria registra exactamente que campo cambio');

  perform pruebas.verificar(
    (select datos_anteriores ->> 'peso_kg' from auditoria
      where tabla = 'mascota' and registro_id = mona and accion = 'UPDATE'
      order by id desc limit 1) = '12.50',
    'La auditoria conserva la version anterior');

  perform pruebas.verificar(
    (select dispositivo from auditoria
      where tabla = 'mascota' and registro_id = mona and accion = 'UPDATE'
      order by id desc limit 1) = 'portal-web/chrome-141',
    'La auditoria registra el dispositivo');

  -- Un UPDATE que no cambia nada no ensucia la auditoria.
  select count(*) into n from auditoria where tabla = 'mascota' and registro_id = mona;
  update mascota set peso_kg = 13.1 where id = mona;
  perform pruebas.verificar(
    (select count(*) from auditoria where tabla = 'mascota' and registro_id = mona) = n,
    'Un UPDATE sin cambios reales no genera registro de auditoria');
end $$;

do $$ begin raise notice ''; raise notice 'Todas las pruebas pasaron.'; end $$;
