# UX/UI — las decisiones, según *Don't Make Me Think*

Guía: Steve Krug, *Don't Make Me Think* (3ª ed.). No es decoración: cada regla
de abajo apunta a un dato concreto del diagnóstico.

> **Qué pude ver y qué no.** Intenté abrir el sitio con el navegador (hay
> Chromium instalado en este entorno). No se puede: la política de red rechaza
> **todos** los dominios — probé `esteticanuvaskin.com`, `wix.com` y
> `example.com`, y los tres devuelven 403 en el CONNECT del proxy. No es el
> navegador: es el entorno.
>
> **Pero sí pude leer el contenido real de las páginas**, por la API de
> Page Optimization de Wix, que lee la página desde el propio sitio. Así que
> los textos, encabezados y estructura de abajo **no son suposiciones: son lo
> que las páginas dicen hoy.**
>
> Lo que sigue sin ver es **el diseño visual**: paleta, tipografías,
> disposición de los elementos, si el botón de WhatsApp existe y dónde está.
>
> **Regla de diseño que reemplaza lo que no puedo ver:** no introducir ningún
> color, tipografía ni estilo de botón nuevo. Todo lo de abajo se construye
> **reutilizando los tokens que el sitio ya tiene**. Krug es explícito: las
> convenciones propias del sitio son un activo, y romperlas obliga a pensar.
>
> **Si querés que yo pueda abrir el sitio**, hay que habilitar la red del
> entorno: menú del entorno en la barra de título → *Edit* → *Network access*,
> y agregar `esteticanuvaskin.com` en *Allowed domains* dejando tildado
> *Allow package managers*. Instrucciones:
> https://code.claude.com/docs/en/cloud-environments#network-access

---

## El contenido real de las páginas (leído por API)

Esto es lo que las páginas tienen hoy. Cada hallazgo de abajo sale de acá.

### `/procedimientos` — **191 caracteres de texto en total**

La API de Wix se **negó** a analizar esta página:

```
CONTENT_TOO_SHORT: Page text content length 191 is less than
minimum allowed length of 200
```

Es la página que recibe **526 impresiones y 2 clics**. Es el centro del
catálogo —la puerta a los 24 tratamientos— y tiene menos texto que este
párrafo.

Eso explica el CTR de 0,4 % y por qué no posiciona para nada: una página de
191 caracteres no le da a Google nada que rankear ni al visitante nada que
escanear. No es un problema de título: **la página está vacía.**

### `/contacto` — sin texto

| Slot | Contenido real |
|---|---|
| H1 | `Contacto` |
| H2 | `Nuva Skin Medicina Estética` |
| Cuerpo | **vacío** (`null`) |

Un H1 de una palabra y nada más. No está la dirección como texto, ni los
horarios, ni qué pasa después de escribir, ni cuánto tardan en responder.

Con 61 visitantes únicos en dos meses y **3 clics para contactar**, esta página
es el embudo, y está vacía.

### `/tenes-dudas` — 1.900 caracteres en un solo bloque

| Slot | Contenido real |
|---|---|
| H1 | `¿Estás pensando en realizarte un tratamiento estético?` |
| H2 | `Nuva Skin Medicina Estética` |
| Cuerpo | **un único párrafo de ~1.900 caracteres** |

Y acá está lo interesante: **el texto es bueno.** Está escrito en primera
persona por el médico, es empático, honesto, y dice cosas valiosas —
*"recibo pacientes a diario que vienen considerando realizarse tratamientos de
estética hace mucho y postergan la decisión"*, o la recomendación final de
poner los tratamientos en manos de profesionales formados, que es exactamente
el tipo de contenido que Google premia en temas de salud.

**El problema no es el contenido: es el formato.** Krug, capítulo 2: *no
leemos, escaneamos*. Un bloque de 1.900 caracteres sin un subtítulo, sin una
negrita, sin una lista y **sin un botón al final** no se lee: se abandona.

112 impresiones, **0 clics**. Cero. Y quien llega tiene que leer 1.900
caracteres para no encontrar ninguna salida.

### El slot del H2 está desperdiciado en todo el sitio

| Página | H2 real |
|---|---|
| Home | **`Descubrí cómo transformar tu vida`** |
| `/contacto` | `Nuva Skin Medicina Estética` |
| `/tenes-dudas` | `Nuva Skin Medicina Estética` |

El H2 es el segundo texto más importante de una página. En las internas repite
la marca —que ya está en el logo, en el título y en la URL— y en la home dice
*"Descubrí cómo transformar tu vida"*.

Ese es el *happy talk* que Krug manda matar, en el lugar más valioso del sitio.
Y para una práctica médica es además una **promesa de resultado implícita**, lo
cual es un problema de publicidad médica, no sólo de estilo.

El H1 de la home, en cambio, está bien:
`Dermatología estética en Retiro, CABA - Dr. Dante Surachi, médico dermatólogo`.

### ⚠️ No apliques las sugerencias de SEO con IA de Wix

Aproveché que corrí la herramienta de Wix para ver qué propone. Propone esto:

| Slot | Texto actual | Lo que propone Wix |
|---|---|---|
| Título | Medicina estética y dermatología en Retiro, CABA \| Nuva Skin | `dermatólogo en retiro \| Estetica Nuva Skin, Buenos Aires` |
| H1 | Dermatología estética en Retiro, CABA - Dr. Dante Surachi, médico dermatólogo | `Dermatólogo en Retiro: atención dermatológica estética` |
| H2 | Descubrí cómo transformar tu vida | `Descubrí cómo transformar tu vida con un dermatólogo en retiro` |

Es **peor** que lo que hay: minúsculas en "retiro", relleno de palabras clave, y
pega la keyword al final del *happy talk* en lugar de sacarlo. **No lo
apliques.**

---

---

## Ley de Krug nº 1

> *"No me hagas pensar."* Cada página debe ser **autoevidente**. Si no se puede,
> al menos **autoexplicativa**.

Y el hallazgo central del libro: **la gente no lee, escanea.** No elige la mejor
opción: elige **la primera opción razonable** (*satisficing*). No entiende cómo
funciona el sitio: **se arregla** (*muddling through*).

Un paciente que busca "botox en microcentro" desde el celular no va a estudiar
el sitio. Va a barrer la pantalla dos segundos buscando algo que diga "turno".
Si no lo encuentra, vuelve a Google y entra al siguiente.

---

## 1. El test del tronco

Krug: tapate los ojos, que alguien te abra una página cualquiera del sitio al
azar, y abrí los ojos. Tenés que poder contestar **sin pensar**:

| Pregunta | Qué tiene que haber |
|---|---|
| ¿Qué sitio es este? | Logo, arriba a la izquierda, siempre en el mismo lugar |
| ¿En qué página estoy? | Nombre de la página, grande, arriba del contenido |
| ¿Cuáles son las secciones principales? | Navegación persistente, idéntica en todas las páginas |
| ¿Cómo llego a mis opciones acá? | Navegación local o lista de tratamientos relacionados |
| ¿Dónde estoy ahora? | La sección actual, resaltada en el menú |
| ¿Cómo busco? | Buscador, o una página `/procedimientos` evidente |

**Hacer esto hoy:** abrir `/rinomodelacion`, `/peeling` y `/estrias` en el
celular y responder las seis. Cada "no" es una fuga.

Con **31 páginas de tratamientos**, el punto 4 es el que más importa: alguien
que entró a `/acne` tiene que ver, sin volver atrás, que también hay
`/cicatricesacne`.

---

## 2. La acción primaria: una, visible, siempre en el mismo lugar

**El dato:** 3 clics para contactar en 57 días, con 61 visitantes únicos.

Krug: cada página necesita **una** acción primaria evidente. Para un
consultorio, es **pedir turno**. Todo lo demás es secundario.

### Especificación

**Botón flotante de WhatsApp** — fijo, abajo a la derecha, en todas las
páginas, también en celular. Nunca tapando contenido ni otro botón.

- Texto: **`Pedir turno`** (no "Contactanos", no "Escribinos", no sólo el ícono)
- Mensaje pre-cargado: `Hola, quiero consultar por un turno en Nuva Skin.`
- En una página de tratamiento, el mensaje nombra el tratamiento:
  `Hola, quiero consultar por un turno de rinomodelación.`
  Krug: cada clic debe ser "sin pensar" — que el paciente no tenga que redactar.

**Teléfono en el encabezado** — `011 4328-5309`, visible, como link `tel:`.
En celular es un toque y marca.

**Un solo botón primario por pantalla.** Si en la misma vista compiten
"Reservar online", "Enviar formulario" y "WhatsApp", los tres pierden. Krug:
las opciones que compiten se anulan. **WhatsApp es el primario**; la reserva
online, secundaria; el formulario, al final.

---

## 3. "Omití palabras innecesarias" — y el *happy talk* se muere

Krug, citando a Strunk & White: sacale la mitad de las palabras, y después la
mitad de lo que quedó. Y su regla más filosa: **el *happy talk* tiene que
morir** — ese texto de bienvenida que no dice nada y que nadie lee.

El peor caso está en la home, y es el H2 — el segundo texto más importante
del sitio:

> ### `Descubrí cómo transformar tu vida`

No dice qué hacen, ni dónde, ni para quién. Y promete un resultado, que en
publicidad de práctica médica no se puede. **Propuesta:**

> ### `Consultá por tu caso: evaluación médica antes de cualquier tratamiento`

Y esto estaba, textual, en la meta descripción de `/tenes-dudas`:

> *"¿Estás pensando en realizarte un tratamiento estético? Centro de
> Dermatología Estética de alto nivel. Tratamientos estéticos realizados por
> médicos dermatólogos especializados ."*

"De alto nivel" es *happy talk* puro: no es verificable, no diferencia (ningún
consultorio se anuncia como "de nivel medio") y ocupa el lugar donde debería
estar la información que el paciente busca. **Ya lo cambié** por:

> "Resolvé tus dudas antes de decidir: cómo es la consulta de evaluación con el
> Dr. Dante Surachi, dermatólogo, en Retiro, CABA. Turnos por WhatsApp."

Y en `/contacto` estaba:

> *"Enterate todos los medios que tenés para comunicarte con nosotros en esta
> página. Consultas, Turnos telefónicos, WhatsApp."*

Krug: **las instrucciones también tienen que morir.** Nadie necesita que le
expliquen que en la página de contacto hay formas de contactar. **Ya lo cambié**
por el dato concreto:

> "Pedí tu turno por WhatsApp o al 011 4328-5309. Carlos Pellegrini 1015,
> Retiro, CABA, a pasos del Obelisco y del subte línea B."

### La regla para el resto del sitio

| Sacar | Poner |
|---|---|
| "Bienvenidos a nuestro centro…" | el nombre de la página |
| "de alto nivel", "de excelencia", "última tecnología" | el dato: qué equipo, qué técnica |
| "Enterate de todo lo que…" | el dato directamente |
| "Hacé clic aquí para…" | un botón que diga qué hace |

---

## 4. Carteles de calle: los nombres tienen que decir qué hay detrás

Krug: el nombre de la página tiene que coincidir con lo que el usuario
clickeó. Si clickeó "Tratamientos" y llega a una página titulada "Servicios",
duda un instante — y esa duda se paga.

**"¿Tenés dudas?"** es el ejemplo de manual de una etiqueta que no dice nada.
¿Dudas de qué? ¿Precios? ¿Riesgos? ¿Horarios? El visitante tiene que abrirla
para saber: eso es exactamente "hacerme pensar". Y el dato lo confirma: **112
impresiones en Google, 0 clics.** Cero.

### Revisión de etiquetas del menú

| Etiqueta probable | Problema | Propuesta |
|---|---|---|
| ¿Tenés dudas? | No dice qué hay detrás | **Primera consulta** o **Preguntas frecuentes** |
| Procedimientos | Palabra de médico, no de paciente | **Tratamientos** |
| Agregue una reseña | Verbo formal, no es para visitantes nuevos | Sacar del menú principal |
| Contacto | Correcto, pero débil | **Turnos** |

> Un paciente no busca "procedimientos": busca "botox". Krug: usá las palabras
> del usuario, no las de la organización.

---

## 5. La home tiene cinco trabajos

Krug lista lo que una home debe transmitir, y ninguno es opcional:

| # | Trabajo | Para Nuva Skin |
|---|---|---|
| 1 | **Identidad y propósito** | "Dermatología y medicina estética en Retiro, CABA" — visible sin scrollear |
| 2 | **Jerarquía** | Las 6 u 8 consultas más buscadas, como accesos directos |
| 3 | **Búsqueda** | Buscador, o `Ver todos los tratamientos` bien visible |
| 4 | **Anzuelos** | Lo estacional ahora: control de lunares, manchas |
| 5 | **"¿Por dónde empiezo?"** | Un botón primario: `Pedir turno` |

Y el *tagline*: Krug pide una frase corta, concreta, verificable, junto al
logo. No un eslogan.

**Propuesta:** `Dermatología y medicina estética — Retiro, CABA`

Con **31 páginas**, el trabajo nº 2 es el crítico. Nadie va a leer una lista de
31. Hay que elegir **6 u 8 accesos directos**, y el criterio no es el gusto: es
la demanda. Según los datos:

| Acceso directo | Por qué |
|---|---|
| Control de lunares | Estacional, pico nov–feb, **es ahora** |
| Botox / toxina botulínica | Mejor margen, más demanda |
| Rellenos con ácido hialurónico | Alto valor por paciente |
| Acné y cicatrices | Volumen alto, paciente recurrente |
| Manchas | Estacional |
| Rinomodelación | Poca competencia, y aparece en lo que los pacientes ya comentan en Google |
| Caída del cabello | Consulta frecuente, poco cubierta |
| Ver todos los tratamientos | La salida para el otro 23 |

---

## 6. Una sola plantilla para las 31 páginas de tratamiento

Krug: las **convenciones** son lo que permite escanear. Si cada página de
tratamiento tiene otra forma, el paciente vuelve a aprender el sitio cada vez.
Si todas tienen la misma, a la segunda ya sabe dónde mirar.

**Mismo orden, siempre:**

1. **H1 = nombre del tratamiento + barrio** → `Rinomodelación en Retiro, CABA`
2. **Una frase** de qué es y para qué sirve
3. **Botón primario** `Pedir turno` — arriba, sin scrollear
4. **Cómo es la consulta de evaluación** (lo primero que el paciente quiere saber)
5. **Cómo es la sesión** y cuánto dura
6. **Cuándo se ven resultados** y cuánto duran
7. **Cuidados posteriores**
8. **Contraindicaciones** — obligatorio, es contenido médico
9. **Precio o rango**, o decir explícitamente que se define en la consulta
10. **Firma**: Dr. Dante Surachi, médico dermatólogo, matrícula `{{MATRICULA}}`
11. **Tratamientos relacionados** — 3 links (resuelve el punto 4 del test del tronco)
12. **Botón primario otra vez**

**Subtítulos escaneables.** Krug: la gente lee los encabezados, no los
párrafos. `¿Duele?` escanea mejor que `Consideraciones sobre el confort del
procedimiento`.

---

## 7. El precio: el agujero del "depósito de buena voluntad"

Krug describe un **depósito de buena voluntad** que cada visitante trae y que
el sitio va gastando. Y lo primero de su lista de cosas que lo vacían:
**esconder la información que la gente vino a buscar.**

En estética, esa información es **el precio**. Un paciente que no lo encuentra
no llama a preguntar: se va al siguiente consultorio.

No hace falta publicar una lista de precios. Lo que no se puede hacer es
**callar**. Alternativas, de mejor a peor:

1. Rango real: `Toxina botulínica: desde $X por zona`
2. El precio de la consulta: `Consulta de evaluación: $X, se descuenta del tratamiento`
3. Decirlo de frente: `El precio depende de las zonas a tratar y se define en la consulta de evaluación, que sale $X`

Cualquiera de las tres repone buena voluntad. El silencio la gasta.

### Lo demás que vacía el depósito, aplicado acá

| Lo que lo vacía (Krug) | En Nuva Skin |
|---|---|
| Esconder lo que la gente busca | Precios y horarios |
| Castigar por no hacer las cosas a tu manera | Exigir formulario cuando el paciente quiere WhatsApp |
| Pedir datos innecesarios | Cada campo extra del formulario |
| Parecer amateur | Fotos de banco de imágenes, URLs con `%C3%B3` |

### Lo que lo repone

- Decir los horarios y qué hacer si está cerrado
- Ahorrar pasos: **WhatsApp en un toque**
- Anticipar la pregunta obvia: ¿duele? ¿cuánto dura? ¿puedo volver a trabajar?
- Pedir perdón por lo que no se puede: "no atendemos sábados, pero dejá tu mensaje y te respondemos el lunes a primera hora"

---

## 8. Celular: "la usabilidad de lo chico"

Krug dedica un capítulo al móvil, y su advertencia central es que **no se
puede recortar funcionalidad** para que entre en la pantalla: la gente espera
hacer lo mismo.

| Regla | Aplicación |
|---|---|
| El teléfono, un toque | Link `tel:` en el encabezado, no una imagen |
| WhatsApp siempre alcanzable | Botón fijo, no al final de la página |
| Blancos tocables ≥ 44 px | Los botones de turno, en especial |
| Texto legible sin zoom | Mínimo 16 px en el cuerpo |
| Scrollear > tapear | Mejor una página larga y escaneable que 4 pasos |
| La dirección, un link a Maps | `Carlos Pellegrini 1015` tocable → abre Maps |
| Nada de pop-ups al entrar | Krug: vacía el depósito, y Google lo penaliza en móvil |

---

## 9. Probarlo: tres personas, una hora, una vez por mes

Krug es tajante: **probar con un usuario al principio del proyecto vale más que
probar con 50 al final**. Y no hace falta laboratorio ni presupuesto.

**El protocolo, tal cual:**

1. Tres personas. Que **no** sean pacientes ni conozcan el consultorio.
2. El celular de ellos, no el tuyo.
3. Una tarea, dicha así: *"Querés hacerte un tratamiento para el acné.
   Averiguá cómo pedir un turno y cuánto sale."*
4. Pedile que **piense en voz alta**.
5. **No la ayudes.** Si se traba, ese es el hallazgo.
6. Cronometrá cuánto tarda en encontrar cómo pedir el turno.
7. Al final preguntá: *"¿Qué hace este lugar? ¿Dónde está?"*

**Si tarda más de 10 segundos en encontrar cómo pedir turno, el problema es el
sitio, no la persona.**

Y la regla de Krug para después: arreglá **el problema más grave primero**, y
arreglalo **sacando algo**, no agregando. La tentación siempre es agregar un
cartel explicativo. Casi nunca es la respuesta.

---

## 10. Accesibilidad: no es un canje

Krug: hacerlo accesible no empeora el sitio para los demás — lo mejora para
todos. Mínimos:

- [ ] Texto alternativo en todas las imágenes
- [ ] Un solo `H1` por página, y jerarquía real de encabezados
- [ ] Contraste suficiente entre texto y fondo
- [ ] Todo navegable con teclado
- [ ] Formularios con etiquetas de verdad, no sólo texto gris dentro del campo
- [ ] Los links dicen a dónde van ("Ver tratamiento de acné", no "acá")

El último punto es además SEO: Google lee el texto del link.

---

## Checklist de implementación

**En el Editor de Wix, a mano** *(no hay API para el diseño de un sitio Editor)*

- [ ] Botón flotante `Pedir turno` (WhatsApp) en todas las páginas, con mensaje pre-cargado
- [ ] Teléfono `tel:` en el encabezado de todas las páginas
- [ ] Dirección tocable que abra Google Maps
- [ ] Renombrar en el menú: "¿Tenés dudas?" → "Primera consulta"; "Procedimientos" → "Tratamientos"; "Contacto" → "Turnos"
- [ ] Sacar "Agregue una reseña" del menú principal
- [ ] 6 u 8 accesos directos de tratamiento en la home
- [ ] Tagline junto al logo
- [ ] Aplicar la plantilla de 12 puntos a las páginas de tratamiento, empezando por botox, rellenos y acné
- [ ] Decidir y publicar la política de precios
- [ ] Teléfono obligatorio en el formulario + checkbox de consentimiento
- [ ] Revisar blancos tocables y tamaño de texto en celular
- [ ] Pasar el test del tronco en 3 páginas al azar
- [ ] Probar con 3 personas

**Reglas de diseño visual**

- [ ] Cero colores, tipografías o estilos de botón nuevos: reutilizar los del sitio
- [ ] El botón primario usa el acento que ya existe; los secundarios, contorno
- [ ] Un solo botón primario por pantalla
