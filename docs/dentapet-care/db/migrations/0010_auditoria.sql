-- 0010_auditoria.sql — Auditoria de acciones clinicas (§30).
--
-- El brief exige registrar por cada accion clinica: usuario, profesional,
-- fecha, hora, dispositivo, accion, version anterior y version nueva.
--
-- La implementacion sigue el modelo de supabase/supa_audit (repo archivado,
-- ver herramientas-open-source.md §13): triggers genericos que guardan la fila
-- entera antes y despues. Se mantiene en las migraciones del proyecto en lugar
-- de depender de una extension sin mantenimiento.

create table auditoria (
  id               bigint primary key generated always as identity,
  tabla            text not null,
  registro_id      uuid,
  accion           text not null check (accion in ('INSERT', 'UPDATE', 'DELETE')),
  usuario_id       uuid,
  rol_bd           text not null,
  clinica_id       uuid,
  dispositivo      text,
  ocurrido_at      timestamptz not null default now(),
  datos_anteriores jsonb,
  datos_nuevos     jsonb,
  -- Solo las columnas que efectivamente cambiaron: hace legible el historial
  -- en el portal sin tener que diffear dos jsonb enteros en el cliente.
  campos_cambiados text[]
);

create index on auditoria (tabla, registro_id, ocurrido_at desc);
create index on auditoria (usuario_id, ocurrido_at desc);
create index on auditoria (clinica_id, ocurrido_at desc);

-- La auditoria es de solo lectura para todos: nadie la edita ni la borra.
-- Ni siquiera un admin de clinica. Solo `service_role` (que tiene BYPASSRLS)
-- puede purgarla desde un job de retencion.
revoke insert, update, delete on auditoria from authenticated, anon;

create or replace function app.auditar()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_anterior  jsonb;
  v_nuevo     jsonb;
  v_id        uuid;
  v_clinica   uuid;
  v_cambios   text[];
begin
  if tg_op = 'DELETE' then
    v_anterior := to_jsonb(old);
    v_nuevo := null;
  elsif tg_op = 'INSERT' then
    v_anterior := null;
    v_nuevo := to_jsonb(new);
  else
    v_anterior := to_jsonb(old);
    v_nuevo := to_jsonb(new);
    select array_agg(clave order by clave) into v_cambios
    from (
      select key as clave from jsonb_each(v_nuevo)
      except
      select key from jsonb_each(v_anterior)
      union
      select n.key
      from jsonb_each(v_nuevo) n
      join jsonb_each(v_anterior) a on a.key = n.key
      where n.value is distinct from a.value
    ) c;

    -- UPDATE que no cambia nada no se audita: solo genera ruido.
    if v_cambios is null then
      return null;
    end if;
  end if;

  v_id := coalesce(v_nuevo ->> 'id', v_anterior ->> 'id')::uuid;
  v_clinica := nullif(coalesce(v_nuevo ->> 'clinica_id', v_anterior ->> 'clinica_id'), '')::uuid;

  insert into auditoria (
    tabla, registro_id, accion, usuario_id, rol_bd, clinica_id, dispositivo,
    datos_anteriores, datos_nuevos, campos_cambiados
  ) values (
    tg_table_name, v_id, tg_op, app.uid(), current_user, v_clinica,
    nullif(current_setting('app.dispositivo', true), ''),
    v_anterior, v_nuevo, v_cambios
  );

  return null;  -- AFTER trigger
end;
$$;

-- Se audita todo lo clinico y todo lo que cambia permisos o dinero.
-- No se auditan las tablas de catalogo (pieza_dental, hallazgo_tipo,
-- etapa_habituacion): son inmutables en operacion normal.
do $$
declare
  t text;
begin
  foreach t in array array[
    'mascota', 'antecedente', 'tutor_mascota',
    'evaluacion', 'odontograma', 'odontograma_hallazgo',
    'plan_dental', 'actividad', 'registro_adherencia', 'progreso_habituacion',
    'fotografia', 'solicitud_fotografia', 'alerta',
    'turno', 'procedimiento', 'documento', 'consentimiento',
    'mensaje', 'conversacion',
    'membresia', 'suscripcion', 'pago'
  ] loop
    execute format(
      'create trigger auditar_%1$s after insert or update or delete on %1$I
         for each row execute function app.auditar()', t);
  end loop;
end $$;
