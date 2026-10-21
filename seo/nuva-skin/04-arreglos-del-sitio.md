# Acción #3 — El sitio: lo que ya cambié y lo que queda

> **Corrección importante.** La primera versión de este documento proponía
> reescribir los títulos y descripciones de las páginas principales. **Estaba
> desactualizado.** Al leer los 31 títulos reales por API encontré que
> **casi todos ya están bien escritos y bien localizados** — alguien hizo ese
> trabajo (el sitio se actualizó el 20 de octubre de 2026). Varios de mis
> cambios propuestos habrían sido laterales o peores.
>
> Así que apliqué **sólo los 4 que los datos de Search Console muestran que
> están fallando**, y descarté el resto.

---

## Lo que ya está bien hecho (no tocar)

El sitio tiene **31 páginas estáticas**, y el inventario de tratamientos es
mucho más amplio de lo que yo creía. Títulos reales, tal como están hoy:

| Página | Título actual |
|---|---|
| Home | Medicina estética y dermatología en Retiro, CABA \| Nuva Skin |
| Botox | Toxina botulínica (botox) en Retiro, CABA \| Nuva Skin |
| Rellenos | Rellenos con ácido hialurónico en Retiro, CABA \| Nuva Skin |
| Labios | Relleno de labios con ácido hialurónico \| Nuva Skin Retiro |
| Rinomodelación | Rinomodelación en Retiro, CABA \| Nuva Skin |
| Armonización facial | Armonización facial en Retiro, CABA \| Nuva Skin |
| Fox eye | Fox eye look en Retiro, CABA \| Nuva Skin |
| Skin booster | Skin booster en Retiro, CABA \| Nuva Skin |
| Peeling | Peeling en Retiro, CABA \| Nuva Skin |
| Mesoterapia | Mesoterapia en Retiro, CABA \| Nuva Skin |
| PRP | Plasma rico en plaquetas en Retiro, CABA \| Nuva Skin |
| Microdermoabrasión | Microdermoabrasión en Retiro, CABA \| Nuva Skin |
| Acné | Acné en Retiro, CABA \| Dermatólogo - Nuva Skin |
| Cicatrices de acné | Cicatrices de acné en Retiro, CABA \| Nuva Skin |
| Rosácea | Rosácea en Retiro, CABA \| Dermatólogo - Nuva Skin |
| Hiperhidrosis | Hiperhidrosis en Retiro, CABA \| Nuva Skin |
| Estrías | Estrías en Retiro, CABA \| Nuva Skin |
| Teleangiectasias | Teleangiectasias y arañitas en Retiro, CABA \| Nuva Skin |
| Caída del cabello | Caída del cabello en Retiro, CABA \| Nuva Skin |
| Depilación definitiva | Depilación definitiva en Retiro, CABA \| Nuva Skin |
| Dr. Surachi | Dr. Dante Surachi, médico dermatólogo en Retiro \| Nuva Skin |
| Pacientes del exterior | English-Speaking Aesthetic Doctor in Buenos Aires \| Nuva Skin |
| Evaluación facial | Evaluación facial y bioestimuladores \| Retiro \| Nuva Skin |
| Post bajada de peso | Recomposición facial tras bajar de peso \| Nuva Skin Retiro |

Esto está bien: **tratamiento + barrio + ciudad + marca**, con el nombre del
profesional donde corresponde. No hay nada que mejorar ahí.

**Consecuencia para las expectativas:** si estos títulos son nuevos, los datos
de Search Console que leí (21/7 al 19/10) reflejan el estado *anterior*. Un
cambio de títulos tarda **3 a 8 semanas** en verse. Es decir: parte del trabajo
ya está hecho y **todavía no rindió**. Eso es una buena noticia, y también
significa que la respuesta no es volver a tocar los títulos.

---

## ✅ Los 5 cambios que apliqué por API

Aplicados y publicados el 21 de octubre de 2026 con la API de SEO de Wix.
Los 5 se confirmaron en la respuesta del servidor; preservé en cada página las
etiquetas que ya tenía (la meta `keywords` de cada una quedó intacta).

### 1. `/procedimientos` — el de mayor retorno del sitio

Recibía **526 impresiones y 2 clics** (CTR 0,4 %) en posición 5,8. A esa
posición le corresponden 25–30 clics. El problema era que la descripción no
nombraba **ni un solo tratamiento**.

| | |
|---|---|
| Título antes | Procedimientos de dermatología estética \| Nuva Skin Retiro |
| **Título ahora** | **Tratamientos: botox, rellenos y más \| Nuva Skin Retiro** |
| Descripción antes | Procedimientos de dermatología estética en Retiro, CABA, realizados por dermatólogos. Turnos por WhatsApp. |
| **Descripción ahora** | **Botox, rellenos, rinomodelación, peelings y mesoterapia en Retiro, CABA. Consulta con el Dr. Dante Surachi, dermatólogo. Turnos por WhatsApp.** |

Razón: nadie busca "procedimientos" — buscan "botox". Ahora el resultado de
Google muestra las palabras que la persona acaba de tipear, que es lo que hace
que clickee.

> **Pero el título no alcanza, y esto lo descubrí después.** Leí el contenido
> real de la página por API y tiene **191 caracteres de texto en total** — tan
> poco que la herramienta de análisis de Wix se niega a procesarla
> (`CONTENT_TOO_SHORT: 191 is less than minimum allowed length of 200`).
>
> Es el centro del catálogo, la puerta a los 24 tratamientos, y está
> prácticamente vacía. Con 191 caracteres no hay nada que Google pueda rankear
> ni nada que el visitante pueda escanear. **El título que acabo de corregir
> ayuda a que clickeen; la página vacía los va a devolver a Google.**
>
> Esta página necesita contenido, no un título. Es la tarea nº 1 de la
> Parte C. Detalle en `05`.

### 2. `/contacto`

Recibía 108 impresiones y 2 clics. El texto explicaba que en la página de
contacto hay formas de contactar — y tenía un salto de línea en medio de la
meta descripción.

| | |
|---|---|
| Título antes | Contacto \| Dermatología Estética Nuva Skin \| Buenos Aires |
| **Título ahora** | **Turnos y contacto \| Nuva Skin Retiro, CABA** |
| Descripción antes | Enterate todos los medios que tenés para comunicarte con nosotros en esta página. ⏎ Consultas, Turnos telefónicos, WhatsApp. |
| **Descripción ahora** | **Pedí tu turno por WhatsApp o al 011 4328-5309. Carlos Pellegrini 1015, Retiro, CABA, a pasos del Obelisco y del subte línea B.** |

Razón: *Don't Make Me Think*, capítulo 5 — "las instrucciones tienen que
morir". Ahora el resultado de Google da el teléfono y la ubicación directamente,
así que alguien puede llamar **sin entrar al sitio**.

### 3. `/tenes-dudas`

**112 impresiones y 0 clics.** Cero. El título no decía qué había detrás y la
descripción era *happy talk*: "Centro de Dermatología Estética de alto nivel".

| | |
|---|---|
| Título antes | ¿Tenés dudas? \| Dermatología Estética Nuva Skin |
| **Título ahora** | **¿Pensás hacerte un tratamiento? \| Nuva Skin Retiro** |
| Descripción antes | ¿Estás pensando en realizarte un tratamiento estético? ⏎ Centro de Dermatología Estética de alto nivel. Tratamientos estéticos realizados por médicos dermatólogos especializados . |
| **Descripción ahora** | **Resolvé tus dudas antes de decidir: cómo es la consulta de evaluación con el Dr. Dante Surachi, dermatólogo, en Retiro, CABA. Turnos por WhatsApp.** |

> No le puse "Preguntas frecuentes" a propósito: **no vi la página**, y
> ponerle un nombre que no coincida con el contenido es el error que Krug
> advierte en el capítulo de los carteles de calle. El título nuevo refleja lo
> que la descripción original dejaba entrever, sin inventar.

### 4. `/agregue-una-resena` — sacada del índice

Era la **3ª página más mostrada del sitio**: 385 impresiones, 3 clics. Y su
título era literalmente el nombre de la marca —
"Dermatología Estética Nuva Skin | Buenos Aires"— así que **competía con la home
por las búsquedas de marca**.

| | |
|---|---|
| Título antes | Dermatología Estética Nuva Skin \| Buenos Aires |
| **Título ahora** | **Dejá tu reseña \| Nuva Skin Retiro, CABA** |
| **Agregado** | **`<meta name="robots" content="noindex">`** |

La página sigue funcionando: se le puede seguir mandando el link a los
pacientes. Lo que dejó de hacer es aparecer en Google compitiendo con la home.

> **Es reversible.** Si en 6 semanas las impresiones de marca de la home no
> suben, se saca el `noindex` y volvemos atrás. Pero 385 impresiones que
> producen 3 clics no están captando a nadie.

### 5. `/politica-de-privacidad` — sacada del índice

Agregado `<meta name="robots" content="noindex">`. Es lo estándar para una
página legal: no tiene valor de búsqueda y no debería ser puerta de entrada.

---

## Lo que NO cambié, y por qué

| Página | Por qué no la toqué |
|---|---|
| Home y las 24 páginas de tratamiento | Los títulos ya están bien. Cambiarlos sería lateral o peor. |
| URLs con tilde (`/estrías`, `/depilacióndefinitiva`) | Cambiar una URL **sin** la redirección 301 pierde lo que tiene posicionado, y las redirecciones no se pueden crear desde la API de SEO. Hay que hacerlo desde el panel: *Configuración → SEO → Redirecciones*. Es una mejora menor, no urgente. |
| La meta `keywords` de cada página | Google la ignora desde 2009. Es inofensiva. No vale el riesgo de una escritura masiva por un tag que no hace nada. |
| `/blog`, `/international-patients` y el resto | Están razonables y no son el cuello de botella. |

---

## PARTE A — Lo que bloquea contactos (a mano, en el Editor)

**Esto no se puede hacer por API.** Un sitio hecho con el Editor de Wix no
tiene API para mover ni estilar elementos: hay que hacerlo en el editor visual.
El detalle de diseño y las razones de UX están en `05-ux-dont-make-me-think.md`.

| Cambio | El dato que lo justifica |
|---|---|
| Botón flotante `Pedir turno` (WhatsApp) en todas las páginas | **3 clics para contactar en 57 días** |
| Teléfono `tel:` clickeable en el encabezado | En celular es un toque y marca |
| **Teléfono obligatorio en el formulario** | **21 de 351 contactos tienen teléfono** |
| Checkbox de consentimiento de marketing | **0 de 351 lo tienen registrado** |
| Probar la reserva online de punta a punta desde un celular | **6 servicios habilitados, 0 reservas en la historia** |
| Desinstalar Wix Hotels | No tiene nada que ver con una clínica |

### Cómo probar la reserva online

Hacer el camino completo desde un celular, como si fueras un paciente:

- [ ] ¿Se llega al botón de reservar desde la home en un toque?
- [ ] ¿Hay horarios cargados y disponibles en el calendario?
- [ ] ¿Los servicios tienen precio, o dicen "a consultar"?
- [ ] ¿Pide pago anticipado? *(si pide, probablemente sea el freno — sacarlo)*
- [ ] ¿Pide crear cuenta? *(si pide, sacarlo: mata la conversión)*
- [ ] ¿Llega la notificación al consultorio cuando alguien reserva?

Si el camino tiene más de tres pasos, dejar WhatsApp como canal principal y la
reserva online como alternativa.

---

## PARTE C — Las tres páginas vacías o ilegibles

Leí el contenido real de las páginas por API (no pude abrir el sitio: la
política de red del entorno bloquea todos los dominios). Tres páginas tienen un
problema de contenido que ningún título puede arreglar:

| Página | Problema real | Qué necesita |
|---|---|---|
| `/procedimientos` | **191 caracteres de texto** · 526 impresiones, 2 clics | Contenido: una frase por tratamiento, agrupados por zona o por objetivo, cada uno con su link. Es la tarea más rentable del sitio. |
| `/contacto` | H1 = "Contacto" · **cuerpo vacío** · 108 impresiones, 2 clics | Dirección como texto, horarios, cómo llegar, en cuánto responden, y el botón de WhatsApp |
| `/tenes-dudas` | **1.900 caracteres en un solo bloque**, sin subtítulos ni botón · 112 impresiones, **0 clics** | El texto es bueno: hay que **partirlo** en subtítulos escaneables y cerrar con un botón |

Y en todo el sitio: el **H2** repite la marca en las internas
(`Nuva Skin Medicina Estética`) y en la home dice
`Descubrí cómo transformar tu vida` — *happy talk* en el segundo texto más
importante del sitio, y una promesa de resultado implícita que en publicidad
médica no corresponde.

El diagnóstico está en `05-ux-dont-make-me-think.md`, y **el contenido ya
escrito y listo para pegar, en `06-contenido-para-pegar.md`**.

> ⚠️ **No apliques las sugerencias de SEO con IA de Wix.** Las corrí para ver
> qué propone y son peores que lo que hay: minúsculas en "retiro", relleno de
> palabras clave, y le pega la keyword al final del *happy talk* en lugar de
> sacarlo. Comparación en `05`.

---

## PARTE B — La página que falta

El sitio tiene 31 páginas y cubre casi todo el catálogo. Falta **una**, y es la
que más demanda estacional tiene en este momento del año:

| URL | Título | Por qué |
|---|---|---|
| `/control-de-lunares-caba` | `Control de Lunares en Retiro, CABA \| Dermatólogo - Nuva Skin` | **Demanda estacional nov–feb. La ventana es ahora.** Una página nueva tarda 3–8 semanas en asentarse, así que tiene que publicarse ya para llegar posicionada al pico, no durante. |

Es además una **consulta médica**, no un tratamiento estético: entra mejor en
comunicaciones a la base de contactos y atrae un paciente que después consulta
por lo demás. Usar la plantilla de 12 puntos de `05`.

---

## Contenido médico: requisitos no negociables

Todo el sitio es contenido de salud. Google lo evalúa con criterios más
estrictos (YMYL), y además hay obligaciones profesionales:

- [ ] **Nombre completo y matrícula** del Dr. Surachi visible en cada página de tratamiento
- [ ] **Especialidad y formación** (universidad, títulos) en `/drsurachi`
- [ ] **Contraindicaciones y riesgos** en cada página de procedimiento
- [ ] Nada que prometa resultados
- [ ] Nada de antes-y-después sin consentimiento escrito firmado
- [ ] Dejar claro que todo procedimiento requiere consulta previa de evaluación
- [ ] Dirección, teléfono y horarios iguales en el sitio, en Google y en los directorios

> Este último punto tiene un error concreto hoy: el teléfono de la ficha de
> Google está mal escrito. Ver `02`.

---

## Checklist

**Hecho por API** ✅
- [x] `/procedimientos` — título y descripción
- [x] `/contacto` — título y descripción
- [x] `/tenes-dudas` — título y descripción
- [x] `/agregue-una-resena` — título + `noindex`
- [x] `/politica-de-privacidad` — `noindex`

**A mano en el Editor, esta semana**
- [ ] Botón flotante `Pedir turno` (WhatsApp)
- [ ] Teléfono `tel:` en el encabezado
- [ ] Teléfono obligatorio en el formulario + checkbox de consentimiento
- [ ] Probar la reserva online desde un celular
- [ ] Desinstalar Wix Hotels
- [ ] Renombrar etiquetas del menú (ver `05`)

**Semanas 2 a 4**
- [ ] **Escribir el contenido de `/procedimientos`** (hoy: 191 caracteres) — lo más rentable
- [ ] **Escribir el contenido de `/contacto`** (hoy: vacío)
- [ ] **Partir el texto de `/tenes-dudas`** en subtítulos + botón al final
- [ ] Reemplazar el H2 de la home (`Descubrí cómo transformar tu vida`)
- [ ] Reemplazar el H2 repetido de las internas (`Nuva Skin Medicina Estética`)
- [ ] Publicar `/control-de-lunares-caba`
- [ ] Aplicar la plantilla de 12 puntos a botox, rellenos y acné (ver `05`)
- [ ] Decidir y publicar la política de precios (ver `05`)
- [ ] URLs sin tilde + redirecciones 301 desde el panel
- [ ] Matrícula visible en todo el sitio
