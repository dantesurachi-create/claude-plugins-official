-- 0011_rls.sql — Row Level Security: aislamiento por clinica y permisos por rol.
--
-- Principio: la interfaz puede esconder un boton, pero eso no es un control de
-- acceso. Todo lo que el §3 del brief define como "no puede" se expresa aca.
--
-- En particular, el §3.4 (la asistente no diagnostica, no prescribe, no
-- modifica indicaciones clinicas, no interpreta fotografias, no firma) se
-- implementa usando `app.es_clinico_de()` en lugar de `app.pertenece_a()` en
-- las tablas clinicas: la asistente pertenece a la clinica pero no es clinica.

-- Privilegios base. RLS filtra filas, pero GRANT sigue siendo necesario.
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage, select on all sequences in schema public to authenticated;

-- Escrituras reservadas a los webhooks / jobs (service_role tiene BYPASSRLS).
revoke insert, update, delete on suscripcion, pago, evento_pago_externo,
  notificacion, auditoria from authenticated;

do $$
declare t text;
begin
  foreach t in array array[
    'clinica','sucursal','usuario','membresia','mascota','tutor_mascota',
    'antecedente','cuestionario_inicial','pieza_dental','hallazgo_tipo',
    'evaluacion','odontograma','odontograma_hallazgo','producto',
    'plantilla_plan','plan_dental','actividad','registro_adherencia',
    'etapa_habituacion','progreso_habituacion','solicitud_fotografia',
    'fotografia','alerta','conversacion','mensaje','disponibilidad','turno',
    'procedimiento','plan_comercial','suscripcion','pago','evento_pago_externo',
    'contenido_educativo','documento','consentimiento',
    'preferencia_notificacion','notificacion','auditoria'
  ] loop
    execute format('alter table %I enable row level security', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- Vinculo automatico del titular
-- ---------------------------------------------------------------------------
-- Cuando un tutor registra una mascota desde la app queda vinculado como
-- titular en la misma transaccion. Sin esto, entre el INSERT de `mascota` y el
-- de `tutor_mascota` la fila queda huerfana y su propio creador no la ve.
-- Si quien la crea es personal de la clinica (§3.4: recepcion registra
-- pacientes), no se lo vincula como tutor.
create or replace function app.vincular_titular()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if app.uid() is null then
    return new;
  end if;
  if new.clinica_id is not null and app.pertenece_a(new.clinica_id) then
    return new;
  end if;
  insert into tutor_mascota (usuario_id, mascota_id, es_titular)
  values (app.uid(), new.id, true)
  on conflict (usuario_id, mascota_id) do nothing;
  return new;
end;
$$;

create trigger vincular_titular
  after insert on mascota
  for each row execute function app.vincular_titular();

-- ---------------------------------------------------------------------------
-- Catalogos: lectura para todos, escritura solo service_role
-- ---------------------------------------------------------------------------

create policy leer_piezas on pieza_dental for select to authenticated using (true);
create policy leer_hallazgos on hallazgo_tipo for select to authenticated using (true);
create policy leer_etapas on etapa_habituacion for select to authenticated using (true);
create policy leer_productos on producto for select to authenticated using (activo);
create policy leer_planes_comerciales on plan_comercial for select to authenticated using (activo);

create policy leer_contenidos on contenido_educativo for select to authenticated
  using (publicado or app.es_superadmin());

create policy leer_plantillas on plantilla_plan for select to authenticated
  using (clinica_id is null or app.pertenece_a(clinica_id));
create policy escribir_plantillas on plantilla_plan for all to authenticated
  using (clinica_id is not null and app.es_admin_de(clinica_id))
  with check (clinica_id is not null and app.es_admin_de(clinica_id));

-- ---------------------------------------------------------------------------
-- Clinicas, sucursales, usuarios y membresias
-- ---------------------------------------------------------------------------

-- El tutor necesita ver los datos de la clinica de su mascota: telefono,
-- direccion y guardia son parte del flujo de signos de alarma (§13).
create policy leer_clinica on clinica for select to authenticated
  using (
    app.pertenece_a(id)
    or exists (select 1 from mascota m
               where m.clinica_id = clinica.id and app.es_tutor_de(m.id))
  );

create policy actualizar_clinica on clinica for update to authenticated
  using (app.es_admin_de(id)) with check (app.es_admin_de(id));

create policy leer_sucursal on sucursal for select to authenticated
  using (
    app.pertenece_a(clinica_id)
    or exists (select 1 from mascota m
               where m.clinica_id = sucursal.clinica_id and app.es_tutor_de(m.id))
  );

create policy administrar_sucursal on sucursal for all to authenticated
  using (app.es_admin_de(clinica_id)) with check (app.es_admin_de(clinica_id));

-- Un usuario se ve a si mismo; el personal de una clinica ve a los colegas de
-- esa clinica y a los tutores de sus pacientes.
create policy leer_usuario on usuario for select to authenticated
  using (
    id = app.uid()
    or app.es_superadmin()
    or exists (
      select 1 from membresia m1
      join membresia m2 on m2.clinica_id = m1.clinica_id and m2.activa
      where m1.usuario_id = app.uid() and m1.activa and m2.usuario_id = usuario.id
    )
    or exists (
      select 1 from tutor_mascota tm
      join mascota mas on mas.id = tm.mascota_id
      where tm.usuario_id = usuario.id and tm.activa
        and mas.clinica_id is not null and app.pertenece_a(mas.clinica_id)
    )
  );

create policy actualizar_usuario on usuario for update to authenticated
  using (id = app.uid()) with check (id = app.uid());

create policy leer_membresia on membresia for select to authenticated
  using (usuario_id = app.uid() or app.pertenece_a(clinica_id));

create policy administrar_membresia on membresia for all to authenticated
  using (app.es_admin_de(clinica_id)) with check (app.es_admin_de(clinica_id));

-- ---------------------------------------------------------------------------
-- Mascotas y su entorno
-- ---------------------------------------------------------------------------

create policy leer_mascota on mascota for select to authenticated
  using (app.puede_ver_mascota(id));

-- Cualquier usuario autenticado puede registrar una mascota (onboarding del
-- tutor). El trigger `vincular_titular` la ata a quien la creo.
create policy crear_mascota on mascota for insert to authenticated
  with check (clinica_id is null or app.pertenece_a(clinica_id) or true);

create policy actualizar_mascota on mascota for update to authenticated
  using (app.es_tutor_de(id) or app.pertenece_a(clinica_id))
  with check (app.es_tutor_de(id) or app.pertenece_a(clinica_id));

create policy leer_vinculo_tutor on tutor_mascota for select to authenticated
  using (usuario_id = app.uid() or app.puede_ver_mascota(mascota_id));

-- Invitar familia: solo el titular. Registrar tutores: tambien el personal.
create policy administrar_vinculo_tutor on tutor_mascota for all to authenticated
  using (app.es_titular_de(mascota_id) or app.pertenece_a(app.clinica_de_mascota(mascota_id)))
  with check (app.es_titular_de(mascota_id) or app.pertenece_a(app.clinica_de_mascota(mascota_id)));

create policy leer_antecedente on antecedente for select to authenticated
  using (app.puede_ver_mascota(mascota_id));

-- El tutor carga antecedentes, pero NO puede marcarlos como profesionales.
create policy cargar_antecedente on antecedente for insert to authenticated
  with check (
    (app.es_tutor_de(mascota_id) and not es_profesional)
    or (app.puede_tratar_mascota(mascota_id) and es_profesional)
  );

create policy actualizar_antecedente on antecedente for update to authenticated
  using (app.puede_tratar_mascota(mascota_id))
  with check (app.puede_tratar_mascota(mascota_id));

create policy leer_cuestionario on cuestionario_inicial for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy cargar_cuestionario on cuestionario_inicial for insert to authenticated
  with check (app.puede_ver_mascota(mascota_id));

-- ---------------------------------------------------------------------------
-- Evaluacion y odontograma — solo clinicos escriben
-- ---------------------------------------------------------------------------

create policy leer_evaluacion on evaluacion for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy escribir_evaluacion on evaluacion for insert to authenticated
  with check (app.es_clinico_de(clinica_id));
create policy actualizar_evaluacion on evaluacion for update to authenticated
  using (app.es_clinico_de(clinica_id)) with check (app.es_clinico_de(clinica_id));

create policy leer_odontograma on odontograma for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy escribir_odontograma on odontograma for insert to authenticated
  with check (app.es_clinico_de(clinica_id));
create policy actualizar_odontograma on odontograma for update to authenticated
  using (app.es_clinico_de(clinica_id)) with check (app.es_clinico_de(clinica_id));

create policy leer_hallazgo on odontograma_hallazgo for select to authenticated
  using (exists (select 1 from odontograma o
                 where o.id = odontograma_id and app.puede_ver_mascota(o.mascota_id)));

create policy escribir_hallazgo on odontograma_hallazgo for all to authenticated
  using (exists (select 1 from odontograma o
                 where o.id = odontograma_id and app.es_clinico_de(o.clinica_id)))
  with check (exists (select 1 from odontograma o
                      where o.id = odontograma_id and app.es_clinico_de(o.clinica_id)));

-- ---------------------------------------------------------------------------
-- Planes y adherencia
-- ---------------------------------------------------------------------------

create policy leer_plan on plan_dental for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy escribir_plan on plan_dental for all to authenticated
  using (app.es_clinico_de(clinica_id)) with check (app.es_clinico_de(clinica_id));

create policy leer_actividad on actividad for select to authenticated
  using (exists (select 1 from plan_dental p
                 where p.id = plan_id and app.puede_ver_mascota(p.mascota_id)));
create policy escribir_actividad on actividad for all to authenticated
  using (exists (select 1 from plan_dental p
                 where p.id = plan_id and app.es_clinico_de(p.clinica_id)))
  with check (exists (select 1 from plan_dental p
                      where p.id = plan_id and app.es_clinico_de(p.clinica_id)));

-- El registro de adherencia lo carga el tutor. Es la unica tabla clinica donde
-- el tutor escribe, y por eso no acepta texto libre en el motivo.
create policy leer_adherencia on registro_adherencia for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy registrar_adherencia on registro_adherencia for insert to authenticated
  with check (app.es_tutor_de(mascota_id) or app.puede_tratar_mascota(mascota_id));
create policy corregir_adherencia on registro_adherencia for update to authenticated
  using (app.es_tutor_de(mascota_id) or app.puede_tratar_mascota(mascota_id))
  with check (app.es_tutor_de(mascota_id) or app.puede_tratar_mascota(mascota_id));

create policy leer_habituacion on progreso_habituacion for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
-- El tutor avanza etapas; solo el profesional puede adelantar, retroceder o
-- suspender el programa, y eso queda marcado en `por_profesional` (§9).
create policy escribir_habituacion on progreso_habituacion for insert to authenticated
  with check (
    (app.es_tutor_de(mascota_id) and not por_profesional)
    or (app.puede_tratar_mascota(mascota_id) and por_profesional)
  );
create policy actualizar_habituacion on progreso_habituacion for update to authenticated
  using (app.es_tutor_de(mascota_id) or app.puede_tratar_mascota(mascota_id))
  with check (
    (app.es_tutor_de(mascota_id) and not por_profesional)
    or (app.puede_tratar_mascota(mascota_id) and por_profesional)
  );

-- ---------------------------------------------------------------------------
-- Fotografias y alertas
-- ---------------------------------------------------------------------------

create policy leer_solicitud_foto on solicitud_fotografia for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy escribir_solicitud_foto on solicitud_fotografia for all to authenticated
  using (app.es_clinico_de(clinica_id)) with check (app.es_clinico_de(clinica_id));

create policy leer_fotografia on fotografia for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy subir_fotografia on fotografia for insert to authenticated
  with check (app.puede_ver_mascota(mascota_id));

-- El tutor solo puede tocar una foto que todavia nadie reviso (para corregir
-- su comentario). Cambiar el estado exige clinico: lo garantizan esta politica
-- y, ademas, el trigger `validar_revision_fotografia`.
create policy revisar_fotografia on fotografia for update to authenticated
  using (
    (app.es_tutor_de(mascota_id) and estado = 'pendiente_revision')
    or app.puede_tratar_mascota(mascota_id)
  )
  with check (
    (app.es_tutor_de(mascota_id) and estado = 'pendiente_revision')
    or app.puede_tratar_mascota(mascota_id)
  );

create policy leer_alerta on alerta for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy reportar_alerta on alerta for insert to authenticated
  with check (app.puede_ver_mascota(mascota_id));
create policy clasificar_alerta on alerta for update to authenticated
  using (app.puede_tratar_mascota(mascota_id))
  with check (app.puede_tratar_mascota(mascota_id));

-- ---------------------------------------------------------------------------
-- Mensajeria
-- ---------------------------------------------------------------------------

create policy leer_conversacion on conversacion for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy abrir_conversacion on conversacion for insert to authenticated
  with check (app.puede_ver_mascota(mascota_id));
create policy gestionar_conversacion on conversacion for update to authenticated
  using (app.pertenece_a(clinica_id)) with check (app.pertenece_a(clinica_id));

create policy leer_mensaje on mensaje for select to authenticated
  using (exists (select 1 from conversacion c
                 where c.id = conversacion_id and app.puede_ver_mascota(c.mascota_id)));
create policy enviar_mensaje on mensaje for insert to authenticated
  with check (
    autor_id = app.uid()
    and exists (select 1 from conversacion c
                where c.id = conversacion_id and app.puede_ver_mascota(c.mascota_id))
  );
-- Aprobar un borrador de IA o marcar leido: solo del lado de la clinica.
create policy aprobar_mensaje on mensaje for update to authenticated
  using (exists (select 1 from conversacion c
                 where c.id = conversacion_id and app.es_clinico_de(c.clinica_id)))
  with check (exists (select 1 from conversacion c
                      where c.id = conversacion_id and app.es_clinico_de(c.clinica_id)));

-- ---------------------------------------------------------------------------
-- Agenda
-- ---------------------------------------------------------------------------

create policy leer_disponibilidad on disponibilidad for select to authenticated
  using (
    app.pertenece_a(clinica_id)
    or exists (select 1 from mascota m
               where m.clinica_id = disponibilidad.clinica_id and app.es_tutor_de(m.id))
  );
create policy escribir_disponibilidad on disponibilidad for all to authenticated
  using (app.es_admin_de(clinica_id) or profesional_id = app.uid())
  with check (app.es_admin_de(clinica_id) or profesional_id = app.uid());

create policy leer_turno on turno for select to authenticated
  using (app.puede_ver_mascota(mascota_id) or app.pertenece_a(clinica_id));
create policy solicitar_turno on turno for insert to authenticated
  with check (app.puede_ver_mascota(mascota_id));
create policy gestionar_turno on turno for update to authenticated
  using (app.es_tutor_de(mascota_id) or app.pertenece_a(clinica_id))
  with check (app.es_tutor_de(mascota_id) or app.pertenece_a(clinica_id));

create policy leer_procedimiento on procedimiento for select to authenticated
  using (app.puede_ver_mascota(mascota_id));
create policy escribir_procedimiento on procedimiento for all to authenticated
  using (app.es_clinico_de(clinica_id)) with check (app.es_clinico_de(clinica_id));

-- ---------------------------------------------------------------------------
-- Documentos, consentimientos, suscripciones y notificaciones
-- ---------------------------------------------------------------------------

create policy leer_documento on documento for select to authenticated
  using (mascota_id is null or app.puede_ver_mascota(mascota_id));
-- Presupuestos los emite administracion; informes e indicaciones, un clinico.
create policy emitir_documento on documento for insert to authenticated
  with check (
    app.es_clinico_de(clinica_id)
    or (tipo = 'presupuesto' and app.pertenece_a(clinica_id))
  );

create policy leer_consentimiento on consentimiento for select to authenticated
  using (
    usuario_id = app.uid()
    or (mascota_id is not null and app.pertenece_a(app.clinica_de_mascota(mascota_id)))
  );
create policy firmar_consentimiento on consentimiento for insert to authenticated
  with check (usuario_id = app.uid());
create policy revocar_consentimiento on consentimiento for update to authenticated
  using (usuario_id = app.uid()) with check (usuario_id = app.uid());

-- Suscripciones y pagos: lectura para el titular y para la clinica que la
-- origino (§3.4 permite a recepcion consultar el estado). Escritura: solo los
-- webhooks, que corren con service_role. No hay politica de escritura.
create policy leer_suscripcion on suscripcion for select to authenticated
  using (
    usuario_id = app.uid()
    or app.es_superadmin()
    or (clinica_origen_id is not null and app.pertenece_a(clinica_origen_id))
  );

create policy leer_pago on pago for select to authenticated
  using (exists (select 1 from suscripcion s
                 where s.id = suscripcion_id
                   and (s.usuario_id = app.uid() or app.es_superadmin())));

-- `evento_pago_externo` queda sin politicas: nadie con rol `authenticated`
-- lo lee ni lo escribe. Es intencional.

create policy gestionar_preferencias on preferencia_notificacion for all to authenticated
  using (usuario_id = app.uid()) with check (usuario_id = app.uid());

create policy leer_notificacion on notificacion for select to authenticated
  using (usuario_id = app.uid());

-- La auditoria la lee el superadmin y el admin de la clinica auditada. Nadie
-- la escribe: el INSERT lo hace el trigger, que es SECURITY DEFINER.
create policy leer_auditoria on auditoria for select to authenticated
  using (app.es_superadmin() or (clinica_id is not null and app.es_admin_de(clinica_id)));
