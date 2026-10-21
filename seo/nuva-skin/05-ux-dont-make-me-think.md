# UX/UI — las decisiones, según *Don't Make Me Think*

Guía: Steve Krug, *Don't Make Me Think* (3ª ed.). No es decoración: cada regla
de abajo apunta a un dato concreto del diagnóstico.

> **Límite honesto de este documento.** No pude abrir el sitio desde este
> entorno (la política de red bloquea el dominio), así que **no vi el diseño**:
> ni paleta, ni tipografías, ni la disposición real de los elementos. Por eso
> este documento especifica **estructura, jerarquía y textos** —que sí pude
> derivar del inventario real de 31 páginas y de los datos de Search Console— y
> **no** inventa colores ni fuentes.
>
> **Regla de diseño que reemplaza lo que no puedo ver:** no introducir ningún
> color, tipografía ni estilo de botón nuevo. Todo lo de abajo se construye
> **reutilizando los tokens que el sitio ya tiene** — el color de acento que ya
> usan los botones, la tipografía de títulos, el radio de bordes, el espaciado.
> Krug es explícito: las convenciones propias del sitio son un activo, y
> romperlas obliga a pensar. Si me pasás una captura de la home y de una página
> de tratamiento, completo la parte visual con la paleta real.

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

Esto estaba, textual, en la página `/tenes-dudas`:

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
