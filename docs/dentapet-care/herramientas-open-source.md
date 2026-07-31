# DentaPet Care — Inventario de herramientas open source para acelerar la construcción

**Fecha de relevamiento:** 31 de julio de 2026
**Alcance:** búsqueda en GitHub de proyectos, librerías y plantillas reutilizables para el MVP definido en el brief de DentaPet Care (app móvil para tutores, portal profesional, backoffice y landing).
**Qué no es este documento:** no es la arquitectura del producto ni el plan de implementación. Es la respuesta a "qué ya existe y no hay que escribir".

---

## 0. Cómo leer este informe

Cada candidato está clasificado con un veredicto explícito:

| Veredicto | Significado |
|---|---|
| **USAR** | Se integra como dependencia o servicio. No se toca el código ajeno. |
| **PARTIR DE** | Se clona/forkea una plantilla como punto de partida y se adapta. |
| **ESTUDIAR** | No se integra, pero su modelo de datos o su UX resuelve un problema que vamos a tener. Se lee y se descarta. |
| **EVITAR** | Parece encajar y no encaja. Se documenta el motivo para no volver a evaluarlo. |

Criterios aplicados en ese orden:

1. **Riesgo clínico.** Nada que produzca, insinúe o automatice interpretación diagnóstica entra al MVP, por bueno que sea el código.
2. **Licencia.** Copyleft fuerte (AGPL) en el núcleo del producto obliga a abrir el código propio. Se prefiere MIT/Apache-2.0 para todo lo que se linkea; el copyleft se tolera solo en herramientas que corren *al lado* (analítica, BI) y no dentro del binario.
3. **Mantenimiento.** Último push, issues abiertos y si el repo está archivado.
4. **Costo de adaptación.** Una plantilla que hay que desarmar entera es más cara que empezar de cero.

> **Advertencia sobre licencias.** Las estrellas y fechas de este informe se verificaron contra la API de GitHub el 31/07/2026. Las licencias **no se verificaron una por una**: se confirmaron solo las dos marcadas como tal. Antes de integrar cualquier componente, leer el `LICENSE` del repo — varios proyectos de esta lista cambiaron de licencia en su historia (Cal.com pasó de AGPL a MIT; Novu declara licencia "Other" con directorio `ee/` propietario). Tratar toda otra mención de licencia acá como *hipótesis a confirmar*, no como dato.

---

## 1. Resumen ejecutivo — el stack que recomiendo

La conclusión corta: **el 80% del MVP es ensamblaje, el 20% es código propio, y ese 20% es exactamente donde está el valor clínico del producto.**

| Capa | Elección | Veredicto | Por qué |
|---|---|---|---|
| Backend / DB / Auth / Storage | [supabase/supabase](https://github.com/supabase/supabase) (107k★) | USAR | Postgres + RLS + Auth + Storage + Edge Functions en una pieza. RLS es el mecanismo natural para la separación por clínica que pide el punto 30 del brief. |
| Migraciones y entornos | [supabase/cli](https://github.com/supabase/cli) (2.3k★) | USAR | Migraciones versionadas, tipos TypeScript generados desde el esquema, dev/staging/prod. |
| App móvil | [expo/expo](https://github.com/expo/expo) (51k★) | USAR | Un solo código para iOS/Android + build en la nube (EAS) sin Mac. |
| UI móvil | [founded-labs/react-native-reusables](https://github.com/founded-labs/react-native-reusables) (8.5k★) | PARTIR DE | shadcn/ui portado a React Native: mismo lenguaje de componentes en app y portal, lo que hace viable un sistema de diseño único. |
| Portal + backoffice + landing | Next.js + [shadcn-ui/ui](https://github.com/shadcn-ui/ui) (120k★) | USAR | Copy-paste de componentes accesibles (Radix) — cumple el requisito AA del punto 29 sin construir primitivas. |
| Turnos | [calcom/cal.diy](https://github.com/calcom/cal.diy) (47k★, **MIT confirmada**) | ESTUDIAR / integrar por API | Ver §5: forkear Cal.com entero es una trampa; usar su modelo de disponibilidad como referencia. |
| Suscripciones (tiendas) | [RevenueCat/react-native-purchases](https://github.com/RevenueCat/react-native-purchases) (1.2k★) | USAR | Apple y Google **exigen** IAP para suscripciones de contenido digital in-app. Esto no es opcional. |
| Cobros web (AR) | [mercadopago/sdk-nodejs](https://github.com/mercadopago/sdk-nodejs) (483★, oficial) | USAR | Suscripciones con débito automático en Argentina. |
| Notificaciones | Expo Push (incluido) → [novuhq/novu](https://github.com/novuhq/novu) (39k★) en fase 2 | USAR / DIFERIR | Ver §7: Novu es la respuesta correcta a las reglas de fatiga, pero es infraestructura de más para 100 pacientes. |
| Jobs y automatizaciones | `pg_cron` (en Supabase) → [triggerdotdev/trigger.dev](https://github.com/triggerdotdev/trigger.dev) (15.8k★) | USAR / DIFERIR | Los recordatorios del piloto son un cron sobre Postgres. |
| Cuestionario inicial | [surveyjs/survey-library](https://github.com/surveyjs/survey-library) (4.8k★) | USAR | El cuestionario de 17 preguntas del punto 5 es JSON versionable, no formularios hardcodeados. |
| Biblioteca educativa | [payloadcms/payload](https://github.com/payloadcms/payload) (43.9k★) | USAR | CMS sobre Postgres/Next.js. Los contenidos necesitan autor profesional y fecha de revisión: eso es un CMS, no una tabla. |
| Analítica de producto | [PostHog/posthog](https://github.com/PostHog/posthog) (37.4k★) | USAR (cloud) | Adherencia, retención 30/60/90, embudo de conversión post-consulta. |
| BI / métricas clínicas | [metabase/metabase](https://github.com/metabase/metabase) (48.5k★) | USAR (al lado) | Dashboards SQL sobre la misma Postgres para la clínica piloto. Corre como servicio separado: el copyleft no contamina. |
| Cámara guiada | [mrousavy/react-native-vision-camera](https://github.com/mrousavy/react-native-vision-camera) (9.5k★) | USAR | Overlay de silueta, control de foco/exposición. `expo-camera` alcanza si no se necesita procesamiento de frames. |
| Comparación de fotos | [nerdyman/react-compare-slider](https://github.com/nerdyman/react-compare-slider) (376★) | USAR (portal) | Comparación cronológica antes/después en la ficha profesional. |
| E2E móvil | [mobile-dev-inc/Maestro](https://github.com/mobile-dev-inc/Maestro) (15.1k★) | USAR | Tests de flujo en YAML. El flujo de signos de alarma **debe** tener test automatizado. |
| **Odontograma veterinario** | **— no existe —** | **CONSTRUIR** | Ver §4. Es el hallazgo más importante del relevamiento. |

---

## 2. Plantillas de arranque (esqueleto del monorepo)

| Repo | ★ | Veredicto | Notas |
|---|---|---|---|
| [Razikus/supabase-nextjs-template](https://github.com/Razikus/supabase-nextjs-template) | 318 | **PARTIR DE** | Next.js 15 + Supabase + auth + gestión de usuarios + storage + **políticas RLS ya escritas** + plantilla React Native/Expo incluida. Es lo más cercano a la forma del proyecto: web y móvil compartiendo backend. Traer las políticas RLS como referencia, no como verdad — hay que reescribirlas para el modelo clínica/profesional/tutor. |
| [roninoss/create-expo-stack](https://github.com/roninoss/create-expo-stack) | 2.6k | **USAR** | CLI que genera el proyecto Expo con las decisiones ya tomadas (Expo Router + NativeWind + Supabase). Ahorra el día 1 de configuración. |
| [antoineross/Hikari](https://github.com/antoineross/Hikari) | 388 | ESTUDIAR | Next.js + Supabase + Stripe. Útil por el modelado de suscripciones y webhooks; el proveedor de pago no aplica en Argentina. |
| [tamagui/starter-free](https://github.com/tamagui/starter-free) | 315 | ESTUDIAR | Monorepo Expo + Next.js + Solito para compartir pantallas entre web y móvil. Elegante, pero el acoplamiento web/móvil complica más de lo que ahorra cuando las dos superficies tienen usuarios distintos (tutor vs. profesional). |
| [gluestack/gluestack-ui](https://github.com/gluestack/gluestack-ui) | 5.2k | Alternativa | Si react-native-reusables no convence. Buen soporte de accesibilidad. |
| [tamagui/tamagui](https://github.com/tamagui/tamagui) | 14.1k | Alternativa | Compilador optimizador y paridad web/nativo. Curva de aprendizaje real; no lo elegiría para un MVP de 90 días. |

**Recomendación:** monorepo (Turborepo) con `apps/mobile` (Expo), `apps/portal` (Next.js), `apps/web` (landing) y `packages/ui`, `packages/db-types`, `packages/design-tokens`. La paleta del punto 28 (`#18204A`, `#4FC3A1`, `#8C83D5`, `#FAFAF8`, `#F2F4F7`) vive en `packages/design-tokens` como fuente única y se consume desde Tailwind (portal) y NativeWind (app).

---

## 3. Dominio veterinario — lo que existe y qué sacarle

Ningún proyecto de esta sección se integra. Todos se leen.

| Repo | ★ | Veredicto | Qué aporta |
|---|---|---|---|
| [YosemiteCrew/Yosemite-Crew](https://github.com/YosemiteCrew/Yosemite-Crew) | 2.0k | **ESTUDIAR** | El PIMS open source de salud animal más activo. Su modelo de datos (mascota, tutor, clínica, profesional, visita) es la mejor referencia gratuita disponible para el punto 31 del brief. Leer el esquema antes de escribir el propio. |
| [evangauer/openvpm](https://github.com/evangauer/openvpm) | 17 | ESTUDIAR | PIMS veterinario API-first en Next.js + Postgres + Drizzle. Joven, pero el stack es idéntico al nuestro: sirve para ver decisiones de modelado en TypeScript. |
| [oldauntie/ababu](https://github.com/oldauntie/ababu) | 26 | ESTUDIAR | PIMS veterinario "orientado a problemas" (Laravel). Interesante conceptualmente: el problema clínico como entidad de primera clase, que es exactamente cómo funciona un seguimiento longitudinal dental. |
| [carlosribas/medvet](https://github.com/carlosribas/medvet) | 19 | ESTUDIAR | Django. Historia clínica veterinaria mínima. |
| [pjborowiecki/ARKA-Veterinary-Clinic...](https://github.com/pjborowiecki/ARKA-Veterinary-Clinic-Page-and-Appointment-Booking-System) | 160 | **PARTIR DE** (solo landing) | Landing + sistema de reservas + panel admin para una clínica veterinaria real, en Next.js + Drizzle + shadcn. La landing y el flujo de reserva son directamente reaprovechables para el punto 27. |
| [medplum/medplum](https://github.com/medplum/medplum) | 2.6k | ESTUDIAR | Plataforma de salud humana con FHIR, auditoría y controles de acceso. **No adoptar FHIR en el MVP** (el estándar apenas cubre veterinaria y el costo de modelado es enorme), pero su implementación de audit log y RBAC es material de lectura obligatoria para el punto 30. |
| [Vetdatahub/VetDataHub](https://github.com/Vetdatahub/VetDataHub) | 46 | ESTUDIAR | Datasets veterinarios abiertos. Relevante solo para la fase 4 (inteligencia), no para el MVP. |
| [martinezsalmeron/dentalpin](https://github.com/martinezsalmeron/dentalpin) | 32 | ESTUDIAR | Software dental (humano) open source con odontograma, FastAPI + Vue. Ver cómo persisten el odontograma. |
| [PatBad/DentaVet](https://github.com/PatBad/DentaVet) | 0 | ESTUDIAR | **El único** proyecto de odontograma veterinario para perros y gatos que encontré en todo GitHub. Extensión de Chrome que integra con EzyVet. Sin estrellas, sin comunidad. Vale como prueba de que la necesidad existe y nadie la resolvió en abierto. |

---

## 4. El odontograma veterinario: hay que construirlo

Este es el hallazgo central del relevamiento, y conviene tenerlo claro antes de planificar.

**Existen odontogramas open source, pero todos son humanos.** Los mejores candidatos:

| Repo | ★ | Stack |
|---|---|---|
| [biomathcode/react-odontogram](https://github.com/biomathcode/react-odontogram) | 70 | React + TypeScript |
| [ZoliQua/React-Odontogram-Modul](https://github.com/ZoliQua/React-Odontogram-Modul) | 47 | React + TS + Tailwind, notaciones FDI/ISO-3950/Zsigmondy-Palmer |
| [bardurt/odontograma](https://github.com/bardurt/odontograma) | 75 | JavaScript / canvas |
| [jacobwalkr/dental-chart](https://github.com/jacobwalkr/dental-chart) | 29 | SVG |

Ninguno sirve tal cual, y la razón no es cosmética:

- La dentadura humana adulta tiene **32 piezas** con numeración FDI de cuadrantes 1-4.
- El **perro** adulto tiene **42 piezas**; el **gato**, **30**. La numeración estándar es el **sistema Triadan modificado** (cuadrantes 1-4 en permanentes, 5-8 en deciduos, con la regla del 04 = canino y 08 = primer molar). Nada de eso es representable en una grilla FDI.
- Las patologías a marcar son distintas: **lesiones resortivas felinas** (tipo 1/2/3), **gingivoestomatitis crónica felina**, **fracturas complicadas/no complicadas**, **maloclusiones**, **persistencia de deciduos**. El vocabulario de un odontograma humano (caries, obturaciones, endodoncias) no aplica.

**Conclusión:** el odontograma es componente propio, y es un diferencial defendible del producto — no hay alternativa abierta en el mercado. La recomendación concreta:

1. Tomar la **arquitectura de estado** de `ZoliQua/React-Odontogram-Modul` (cómo modela pieza → superficie → hallazgo → notas), que es lo caro de diseñar.
2. Reemplazar la geometría por un **SVG de arcada canina y otro de arcada felina**, con `data-triadan` en cada pieza.
3. Persistir como JSON versionado (`{ triadan: 108, hallazgos: [...], superficies: {...}, profesional_id, fecha }`), nunca como imagen. Un odontograma que no es consultable no sirve para seguimiento longitudinal, que es la premisa del producto.
4. Validar la nomenclatura de hallazgos con la odontóloga del piloto **antes** de escribir la primera línea. Cambiar el vocabulario después de tener datos cargados es carísimo.

**Estimación:** 2-3 semanas de una persona. Es la pieza propia más grande del MVP y debe empezar temprano, en paralelo con el resto.

---

## 5. Agenda y turnos: por qué no forkear Cal.com

[calcom/cal.diy](https://github.com/calcom/cal.diy) (47.1k★, licencia **MIT confirmada**, ex `cal.com`) resuelve disponibilidad, husos horarios, buffers, reprogramación y recordatorios. Es tentador.

**No lo forkearía para el MVP.** Es un monorepo de ~1.1 GB con su propio esquema Prisma, su auth y su modelo de organizaciones. Integrar el modelo de pacientes de DentaPet dentro de ese esquema, o mantener dos bases sincronizadas, cuesta más que construir la agenda que el brief pide — que es acotada: turnos de una clínica, con 7 tipos de consulta, sin marketplace ni pagos complejos de reserva.

**Recomendación por fases:**

- **MVP:** tabla `disponibilidad` (profesional × día × franja) + `turno` en Postgres, con exclusión por rango (`tstzrange` + constraint `EXCLUDE USING gist`) para impedir sobreturnos a nivel de base de datos, no de aplicación. Leer el modelo de disponibilidad de Cal.com como referencia de diseño.
- **Fase 3 (multi-clínica):** reevaluar. Ahí sí aparecen calendarios externos (Google Calendar), round-robin entre profesionales y reglas por sucursal, y Cal.com — o sus *atoms* embebibles ([calcom/atoms-examples](https://github.com/calcom/atoms-examples)) — empieza a pagar su costo.
- [UretzkyZvi/planner](https://github.com/UretzkyZvi/planner) (443★): componente React de agenda con drag-and-drop, integrado con shadcn/ui. **USAR** para la vista de agenda del portal profesional. Esto sí es reutilizable directo.

---

## 6. Suscripciones y pagos

Hay una restricción que condiciona toda la arquitectura de cobro y conviene decirla antes que nada: **si la app de iOS/Android vende la suscripción dentro de la app, Apple y Google exigen su sistema de compras in-app** (y su comisión). Mercado Pago dentro de la app móvil para una suscripción de contenido digital es motivo de rechazo en la revisión de App Store.

| Herramienta | ★ | Veredicto | Rol |
|---|---|---|---|
| [RevenueCat/react-native-purchases](https://github.com/RevenueCat/react-native-purchases) | 1.2k | **USAR** | Abstrae StoreKit + Google Play Billing, valida recibos, maneja renovaciones, reembolsos y períodos de gracia, y expone webhooks. Escribir esto a mano es semanas de trabajo y una fuente permanente de bugs de estado. |
| [mercadopago/sdk-nodejs](https://github.com/mercadopago/sdk-nodejs) | 483 | **USAR** | SDK oficial. Suscripciones (*preapproval*) con débito automático para el canal **web**: alta desde la landing o desde el portal, con la app solo consumiendo el estado. Esta ruta evita la comisión de tiendas y es la que conviene empujar comercialmente. |
| [BlackBoxVision/react-native-mercadopago-px](https://github.com/BlackBoxVision/react-native-mercadopago-px) | 104 | **EVITAR** en MVP | Puente a MercadoPago PX en React Native. Además del riesgo de rechazo en tiendas, tiene 33 issues abiertos. Si se necesita cobrar *dentro* de la app, que sea por IAP. |

**Arquitectura de cobro sugerida:** una tabla `suscripcion` propia como fuente de verdad, alimentada por dos webhooks (RevenueCat y Mercado Pago) que normalizan a los mismos estados (`activa`, `en_gracia`, `vencida`, `cancelada`, `pago_fallido`). El resto del sistema nunca consulta al proveedor: consulta la tabla. Eso mantiene las automatizaciones del punto 25 (avisos a 15 y 3 días, alerta por pago fallido) independientes del medio de pago.

---

## 7. Notificaciones, recordatorios y automatizaciones

El punto 10 del brief (reglas de fatiga, insistencia configurable, modo silencioso, resumen semanal) es más sofisticado de lo que parece: es un motor de preferencias por usuario y por canal, con supresión.

| Herramienta | ★ | Veredicto | Cuándo |
|---|---|---|---|
| Expo Push Notifications (parte de [expo/expo](https://github.com/expo/expo)) | 51k | **USAR** | MVP. Una API para APNs y FCM, sin configurar cada plataforma por separado. |
| `pg_cron` + Edge Functions (en Supabase) | — | **USAR** | MVP. Los recordatorios diarios son una consulta programada: "actividades cuya hora llegó y no tienen registro". No hace falta un orquestador. |
| [novuhq/novu](https://github.com/novuhq/novu) | 39.4k | **DIFERIR a fase 2** | Licencia declarada "Other" — verificar el modelo `ee/` antes de comprometerse. Aporta exactamente lo que el brief pide: workflows multicanal, **digest** (agrupar para no saturar), preferencias por suscriptor y centro de notificaciones in-app. Cuando haya 300+ pacientes y 3 canales, escribirlo a mano deja de ser razonable. |
| [triggerdotdev/trigger.dev](https://github.com/triggerdotdev/trigger.dev) | 15.8k | **DIFERIR a fase 2** | Workflows con estado y reintentos. Las automatizaciones posprocedimiento (24 h → 72 h → 7 días → foto) son un caso de libro. En el MVP, cron + tabla de estado alcanza. |
| [inngest/inngest](https://github.com/inngest/inngest) | 5.7k | Alternativa | Equivalente, orientado a eventos. |

**Regla de diseño que ninguna herramienta te va a dar:** el brief prohíbe mensajes culpabilizadores y limita a dos recordatorios diarios "salvo indicación clínica". Eso es una política del dominio y va en el código propio, en una única función `puede_notificar(usuario, tipo, momento)` que **toda** notificación atraviesa. Si la política queda dispersa en cada punto de envío, se viola sola en tres meses.

---

## 8. Mensajería tutor ↔ clínica

| Herramienta | ★ | Veredicto | Notas |
|---|---|---|---|
| Supabase Realtime ([supabase/realtime](https://github.com/supabase/realtime), 7.6k★) | — | **USAR** | Mensajería propia sobre tablas con RLS + suscripción en vivo. Para hilos por paciente con adjuntos y responsable asignado, es suficiente y mantiene los datos clínicos en una sola base. |
| [chatwoot/chatwoot](https://github.com/chatwoot/chatwoot) | 35k | **EVITAR** en MVP | Excelente producto, mal encaje: es un helpdesk omnicanal con su propio modelo de contactos y conversaciones. Mantener la identidad del tutor sincronizada entre Chatwoot y la base clínica es trabajo permanente, y los mensajes clínicos deben vivir en la historia del paciente, no en una bandeja aparte. Reevaluar en fase 3, si aparece un equipo de soporte real. |

**Punto no negociable del brief (§24):** la mensajería no puede presentarse como canal de emergencias. Eso se implementa como interfaz, no como copy: horario de atención visible, tiempo estimado de respuesta y derivación explícita al flujo de signos de alarma cuando el mensaje contiene indicios de urgencia.

---

## 9. Fotografías dentales seriadas

| Herramienta | ★ | Veredicto | Rol |
|---|---|---|---|
| [mrousavy/react-native-vision-camera](https://github.com/mrousavy/react-native-vision-camera) | 9.5k | **USAR** | Captura guiada con overlay de silueta por posición (frontal, lateral D/I, superior, inferior). Control de foco y exposición, que es lo que diferencia una foto útil de una borrosa. |
| `expo-camera` | — | Alternativa | Si no se necesita procesamiento de frames, evita una dependencia nativa pesada. Empezar por acá y migrar si hace falta. |
| Supabase Storage ([supabase/storage](https://github.com/supabase/storage), 1.3k★) | — | **USAR** | Buckets privados con políticas de acceso por rol. Las fotos clínicas **nunca** en bucket público ni en URL adivinable. |
| [nerdyman/react-compare-slider](https://github.com/nerdyman/react-compare-slider) | 376 | **USAR** | Comparación cronológica en el portal (§22). |
| [tam315/react-compare-image](https://github.com/tam315/react-compare-image) | 406 | Alternativa | Equivalente, API más simple. |
| [react-native-camera/react-native-camera](https://github.com/react-native-camera/react-native-camera) | 9.6k | **EVITAR** | **Archivado**. Aparece primero en muchas búsquedas; está deprecado. |

**Restricción del brief que hay que codificar, no solo documentar (§12):** los estados de una foto son `pendiente_revision`, `revisada`, `repetir`, `requiere_consulta`, `seguimiento_habitual`, y **ninguno se asigna automáticamente**. La transición de estado exige `profesional_id`. Si el esquema permite que una foto cambie de estado sin profesional, el producto puede terminar dando una señal diagnóstica sin supervisión — que es justamente lo que el brief prohíbe.

---

## 10. Cuestionarios y formularios clínicos

| Herramienta | ★ | Veredicto | Notas |
|---|---|---|---|
| [surveyjs/survey-library](https://github.com/surveyjs/survey-library) | 4.8k | **USAR** | El cuestionario inicial (17 preguntas), la evaluación dental del profesional y los formularios de signos de alarma son JSON. Versionable, comparable entre visitas y modificable por la odontóloga sin desplegar código. |
| [surveyjs/survey-creator](https://github.com/surveyjs/survey-creator) | 1.3k | ESTUDIAR | Editor drag-and-drop para el backoffice. Bueno para fase 2, cuando el equipo clínico quiera autonomía. |
| [formbricks/formbricks](https://github.com/formbricks/formbricks) | 12.7k | ESTUDIAR | Encuestas in-app. Encaje real: **medir NPS** (§35), no formularios clínicos. |
| `react-hook-form` + `zod` | — | **USAR** | Todo lo que no sea cuestionario dinámico. Un esquema Zod compartido entre app, portal y Edge Functions evita que las validaciones se dupliquen y se desincronicen. |

**Cuidado con la presentación del resultado (§5).** El cuestionario inicial no arroja puntaje visible al tutor. El texto exacto que pide el brief — *"el nivel de riesgo será definido por un profesional"* — debe estar en el componente, no en un documento de contenido que alguien pueda "mejorar" después.

---

## 11. Portal profesional, backoffice y landing

| Herramienta | ★ | Veredicto | Notas |
|---|---|---|---|
| [shadcn-ui/ui](https://github.com/shadcn-ui/ui) | 120k | **USAR** | Componentes accesibles sobre Radix, copiados al repo (no una dependencia que dicta el diseño). Es lo que hace alcanzable el look "premium, simple, sereno" del §28 sin diseñador full-time. |
| [refinedev/refine](https://github.com/refinedev/refine) | 35.4k | **PARTIR DE** (solo backoffice) | Framework para paneles internos con proveedor de datos para Supabase incluido. El backoffice del §26 es CRUD sobre 15 entidades: clínicas, sucursales, usuarios, planes, precios, cupones, contenidos. Escribirlo a mano es semanas tiradas. **No usarlo para el portal profesional**, cuya UX es a medida. |
| [marmelab/react-admin](https://github.com/marmelab/react-admin) | 26.9k | Alternativa | Más maduro, estética Material Design que choca con la paleta del brief. |
| [UretzkyZvi/planner](https://github.com/UretzkyZvi/planner) | 443 | **USAR** | Agenda con drag-and-drop compatible con shadcn/ui. |
| [ZoliQua/React-Odontogram-Modul](https://github.com/ZoliQua/React-Odontogram-Modul) | 47 | **ESTUDIAR** | Ver §4 — se toma la arquitectura, no el código. |
| [payloadcms/payload](https://github.com/payloadcms/payload) | 43.9k | **USAR** | Biblioteca educativa (§17): autor profesional, fecha de revisión, nivel, duración, relación con el plan. Eso es un CMS con workflow de publicación. Corre dentro de Next.js sobre la misma Postgres. |
| [pjborowiecki/ARKA-Veterinary-Clinic...](https://github.com/pjborowiecki/ARKA-Veterinary-Clinic-Page-and-Appointment-Booking-System) | 160 | **PARTIR DE** | Landing veterinaria real en Next.js + shadcn. Estructura y secciones directamente aprovechables para el §27. |

---

## 12. Analítica, métricas y BI

| Herramienta | ★ | Veredicto | Rol |
|---|---|---|---|
| [PostHog/posthog](https://github.com/PostHog/posthog) | 37.4k | **USAR** (cloud) | Eventos, embudos, retención por cohorte, session replay en web, feature flags. Cubre casi todo el §35: conversión post-consulta, retención 30/60/90, activos mensuales. SDK para React Native disponible. Autohospedarlo en el piloto es desperdiciar tiempo de infraestructura. |
| [metabase/metabase](https://github.com/metabase/metabase) | 48.5k | **USAR** (al lado) | Dashboards SQL sobre la Postgres de producción (réplica de lectura) para métricas clínicas y comerciales: MRR, adherencia promedio, pacientes sin actividad, controles vencidos. Corre como servicio separado — no se linkea, así que su licencia no afecta al producto. |
| [PostHog/posthog-foss](https://github.com/PostHog/posthog-foss) | 686 | Alternativa | Espejo sin código propietario, si se exige autohospedaje. |

**Sobre los eventos:** definir el diccionario de eventos **antes** de instrumentar (`actividad_registrada`, `foto_enviada`, `alerta_reportada`, `control_confirmado`, `plan_creado`, `suscripcion_activada`...) con propiedades estables. Instrumentar sobre la marcha produce datos que no se pueden comparar entre semanas, y el piloto de 90 días es corto: no hay margen para perder el primer mes de datos.

---

## 13. Seguridad, auditoría y privacidad (§30)

| Herramienta | ★ | Veredicto | Notas |
|---|---|---|---|
| **Supabase RLS** (Postgres) | — | **USAR** | Separación por clínica a nivel de fila. Es la única forma de garantizar el aislamiento sin depender de que cada consulta filtre bien. Escribir tests de RLS: por cada tabla, un test que verifique que el profesional de la clínica A **no** puede leer al paciente de la clínica B. |
| [supabase/supa_audit](https://github.com/supabase/supa_audit) | 672 | **ESTUDIAR** — **está archivado** | Auditoría genérica de tablas por triggers, guardando el registro anterior y el nuevo. Es exactamente el requisito del §30 ("versión anterior / versión nueva"). Como el repo está archivado, tomarlo como **referencia de implementación** y mantener los triggers propios en las migraciones del proyecto. |
| [medplum/medplum](https://github.com/medplum/medplum) | 2.6k | ESTUDIAR | Su audit log y su RBAC son la mejor referencia abierta en salud. |
| Supabase Auth ([supabase/auth](https://github.com/supabase/auth), 2.5k★) | — | **USAR** | MFA/TOTP incluido: el brief exige doble factor para profesionales (§30). Activarlo por rol desde el día uno, no "después del piloto". |

**Lo que ninguna herramienta resuelve:** el consentimiento informado y la exportación/eliminación de datos son requisitos legales (en Argentina, Ley 25.326 de Protección de Datos Personales) y son código propio. Modelar `consentimiento` como entidad con versión de texto, fecha, IP y usuario — no como un booleano en la tabla de usuarios. Un booleano no prueba nada frente a un reclamo.

---

## 14. Calidad, testing y CI

| Herramienta | ★ | Veredicto | Notas |
|---|---|---|---|
| [mobile-dev-inc/Maestro](https://github.com/mobile-dev-inc/Maestro) | 15.1k | **USAR** | E2E móvil en YAML, sin la fragilidad histórica de Detox. Cubrir como mínimo: onboarding completo, registro de actividad, captura de foto y **el flujo de signos de alarma de punta a punta**. |
| Playwright | — | **USAR** | E2E del portal y del backoffice. |
| [supabase/cli](https://github.com/supabase/cli) | 2.4k | **USAR** | Base local en CI, migraciones aplicadas en cada PR, tipos regenerados. Sin esto, los tipos y el esquema se desincronizan en la semana 3. |
| `pgTAP` | — | **USAR** | Tests de las políticas RLS dentro de la base. Es la única forma seria de probar aislamiento multi-clínica. |
| [expo/skills](https://github.com/expo/skills) | 2.3k | **USAR** | Skills de agente oficiales de Expo para trabajar con proyectos Expo y EAS. Acelera el trabajo asistido por IA sobre este repo. |
| [supabase/agent-skills](https://github.com/supabase/agent-skills) | 2.5k | **USAR** | Equivalente para Supabase: migraciones, RLS, Edge Functions. |

---

## 15. Lo que hay que construir sí o sí

Después de todo el ensamblaje, esto queda como código propio — y no es casualidad: es el producto.

1. **Odontograma canino y felino con numeración Triadan** (§4). 2-3 semanas. Sin equivalente abierto.
2. **Motor de planes dentales**: plantillas (preventivo adulto, raza pequeña, gato adulto, senior, poslimpieza, posextracción, periodontal previa, habituación, diente fracturado) → instancia por paciente → actividades con frecuencia → recordatorios → registro de adherencia. Es el corazón del §8 y del §23.
3. **Programa de habituación al cepillado en 5 etapas** con avance/retroceso controlado por el profesional (§9).
4. **Motor de adherencia**: registro con motivos de incumplimiento, cálculo de racha, tendencia semanal, detección de abandono a los 7 días.
5. **Flujo de signos de alarma con derivación a guardia** (§13). Es el componente con más riesgo clínico del producto: sin promesa de respuesta, con teléfono y mapa de la guardia siempre visibles, y con test E2E obligatorio.
6. **Capa de política de notificaciones** (§7): la regla anti-fatiga en un solo lugar.
7. **Normalizador de estados de suscripción** entre RevenueCat y Mercado Pago (§6).
8. **Reglas de permisos por rol** (§3), en particular las **negativas**: la asistente no diagnostica, no prescribe, no modifica indicaciones clínicas, no interpreta fotos, no firma. Eso se prueba con tests, no se confía a la interfaz — ocultar un botón no es un control de acceso.

---

## 16. Herramientas que descarté y por qué

| Herramienta | Motivo del descarte |
|---|---|
| [mhson-kyle/awesome-ai-in-dentistry](https://github.com/mhson-kyle/awesome-ai-in-dentistry) (56★) | Segmentación dental y análisis de imagen odontológica con IA. Es *exactamente* lo que el brief prohíbe en el MVP (§1). Guardar el enlace para una eventual fase 4 con validación clínica formal; no tocarlo antes. |
| [abhi-abhi86/disease-predictor](https://github.com/abhi-abhi86/disease-predictor) (11★) | Predicción de enfermedad por imagen, incluye veterinaria. Riesgo clínico inaceptable, sin validación. |
| [OpenVet-Projects/VetClaw](https://github.com/OpenVet-Projects/VetClaw) (25★) | Librería de skills veterinarias de IA. Interesante para asistencia administrativa en fase 4; fuera del alcance del MVP. |
| [chatwoot/chatwoot](https://github.com/chatwoot/chatwoot) (35k★) | Ver §8: modelo de datos paralelo al clínico. |
| [react-native-camera/react-native-camera](https://github.com/react-native-camera/react-native-camera) (9.6k★) | Archivado/deprecado. |
| Odontogramas humanos FDI (§4) | Numeración y patologías inaplicables a perros y gatos. |
| Fork completo de [calcom/cal.diy](https://github.com/calcom/cal.diy) (47k★) | Ver §5: el costo de integración supera al de construir la agenda acotada del MVP. |
| FHIR / HL7 como modelo base | El estándar cubre mal la veterinaria y el costo de modelado no se justifica con una clínica piloto. Reevaluar en fase 3 si aparece integración con PIMS de terceros. |

---

## 17. Orden de ataque sugerido

No es el plan de proyecto — es la secuencia que se desprende de las dependencias entre estas herramientas.

| Semana | Foco | Herramientas |
|---|---|---|
| 1 | Monorepo, esquema, RLS, auth, tokens de diseño | create-expo-stack, supabase/cli, supabase-nextjs-template (referencia RLS) |
| 2 | Onboarding tutor + registro de mascota + cuestionario | Expo, react-native-reusables, SurveyJS |
| 2-4 | **Odontograma veterinario** (en paralelo, empieza ya) | SVG propio + arquitectura de ZoliQua |
| 3 | Ficha profesional + listado de pacientes + planes | Next.js, shadcn/ui |
| 4 | Motor de plan + actividades + adherencia | Código propio |
| 5 | Recordatorios y notificaciones | Expo Push, pg_cron |
| 5 | Fotografías con captura guiada | vision-camera, Supabase Storage |
| 6 | Signos de alarma + mensajería | Supabase Realtime, código propio |
| 6 | Agenda y turnos | planner, tablas propias |
| 7 | Suscripciones (dos canales) | RevenueCat, Mercado Pago SDK |
| 7 | Backoffice | Refine |
| 8 | Landing + biblioteca educativa | ARKA (base), Payload CMS |
| 8 | Métricas, auditoría, E2E, despliegue | PostHog, Metabase, Maestro, pgTAP |

---

## 18. Advertencias sobre el método de este relevamiento

Para que se pueda auditar y repetir:

- Las búsquedas se hicieron con la API de búsqueda de GitHub, que devuelve resultados **por relevancia y de forma inconsistente**: varias consultas con filtros combinados (`stars:>N` + múltiples términos) devolvieron cero resultados y hubo que reformularlas. **No se puede concluir "no existe" a partir de una búsqueda vacía.** La afirmación del §4 sobre la ausencia de odontogramas veterinarios se sostiene en múltiples consultas independientes (por término, por tema y en español), pero conviene revalidarla antes de invertir las 3 semanas.
- Estrellas, fechas de actualización y estado de archivado son del **31/07/2026**.
- **Las licencias no están verificadas salvo dos** (Cal.com/cal.diy MIT, Novu "Other"). Leer el `LICENSE` de cada repo antes de integrarlo, especialmente en los que corren dentro del producto.
- El acceso directo a la API REST de GitHub estaba restringido en este entorno, así que los metadatos provienen de la API de búsqueda.
