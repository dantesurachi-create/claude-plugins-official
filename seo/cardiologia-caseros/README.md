# Plan de posicionamiento en Google — Cardiología en Caseros

Objetivo: aparecer entre los primeros resultados de Google para búsquedas como
**"cardiólogo en Caseros"**, **"riesgo quirúrgico Caseros"** y **"electrocardiograma Caseros"**,
hechas por gente que está a pocos kilómetros del consultorio.

---

## Antes de empezar: cómo funciona realmente esta búsqueda

Cuando alguien en Caseros busca *"cardiologo cerca"*, Google muestra tres bloques distintos,
y cada uno se gana de una manera diferente:

| Bloque | Qué es | Cómo se gana | Cuánto tarda |
|---|---|---|---|
| **Local pack** (el mapa con 3 fichas) | Lo primero que se ve y donde se van la mayoría de los clics | Ficha de Google Business Profile + reseñas + cercanía | 4 a 10 semanas |
| **Resultados orgánicos** | Los links de abajo | Páginas del sitio propio, una por servicio | 2 a 5 meses |
| **Directorios** (Doctoralia, Turnosalud) | Suelen ocupar los primeros puestos orgánicos | Tener perfil completo y con reseñas ahí también | 2 a 4 semanas |

**Lo que hay que saber con honestidad:** no se puede *garantizar* el puesto #1. En el local pack,
uno de los tres factores que Google pondera es la **distancia entre quien busca y el consultorio**,
y eso no se optimiza. Alguien que busca desde Santos Lugares va a ver resultados distintos que
alguien que busca desde Caseros centro. Lo que sí se puede hacer —y es lo que hace este plan— es
ganar los otros dos factores (**relevancia** y **prominencia**) de forma tan clara que el
consultorio aparezca primero para todo el que esté razonablemente cerca.

La buena noticia: Caseros es un mercado chico y mal trabajado. Hoy la mayoría de los cardiólogos
de la zona no tienen ficha optimizada ni páginas de servicio propias, y los que rankean para
"riesgo quirúrgico" son consultorios de CABA que ni siquiera están en el partido. **Esto es
ganable en un trimestre.**

---

## Qué hay en esta carpeta

| Archivo | Para qué sirve |
|---|---|
| `01-google-business-profile.md` | La ficha de Google. **Es el 60% del resultado. Empezá por acá.** |
| `02-resenas.md` | Cómo conseguir reseñas de forma sostenida y sin violar las políticas de Google |
| `paginas/cardiologo-en-caseros.md` | Página principal del sitio, lista para copiar y pegar |
| `paginas/riesgo-quirurgico.md` | Landing de riesgo quirúrgico / apto prequirúrgico |
| `paginas/electrocardiograma.md` | Landing de electrocardiograma |
| `schema/*.json` | Datos estructurados (JSON-LD) para que Google entienda el consultorio |
| `03-directorios.md` | Doctoralia y el resto de los perfiles externos |
| `04-medicion.md` | Cómo saber si está funcionando |

---

## Datos que hay que completar antes de publicar

Todo el material usa marcadores entre llaves dobles. Buscá y reemplazá estos valores
una sola vez en todos los archivos:

| Marcador | Qué poner | Ejemplo |
|---|---|---|
| `{{NOMBRE_MEDICO}}` | Nombre completo con título | Dr. Juan Pérez |
| `{{MATRICULA}}` | Matrícula nacional y/o provincial | MN 123456 / MP 78910 |
| `{{ESPECIALIDAD_TITULO}}` | Certificación y dónde se formó | Especialista en Cardiología (UBA), Hospital Italiano |
| `{{DIRECCION}}` | Calle y número | Av. San Martín 2345, piso 1, dto. B |
| `{{LOCALIDAD}}` | Localidad y partido | Caseros, Tres de Febrero, Buenos Aires |
| `{{CP}}` | Código postal | B1678 |
| `{{TELEFONO}}` | Teléfono de turnos | 011 4759-0000 |
| `{{WHATSAPP}}` | WhatsApp en formato internacional | 5491122334455 |
| `{{EMAIL}}` | Mail de contacto | turnos@ejemplo.com.ar |
| `{{DOMINIO}}` | Dominio del sitio | https://cardiologocaseros.com.ar |
| `{{HORARIOS}}` | Días y horas de atención | Lunes a viernes de 9 a 19, sábados de 9 a 13 |
| `{{OBRAS_SOCIALES}}` | Listado de coberturas | OSDE, Swiss Medical, Galeno, PAMI, particular |
| `{{LAT}}` / `{{LNG}}` | Coordenadas exactas del consultorio | -34.6058 / -58.5627 |

> Para sacar `{{LAT}}` y `{{LNG}}`: abrí Google Maps, hacé clic derecho sobre la puerta del
> consultorio y copiá los números que aparecen arriba de todo.

**Regla de oro — consistencia NAP:** el nombre, la dirección y el teléfono (*Name, Address, Phone*)
tienen que estar escritos **exactamente igual** en la ficha de Google, en el sitio, en Doctoralia
y en todos lados. Si en un lugar dice "Av. San Martín 2345" y en otro "Avenida San Martin 2345",
Google duda de que sean el mismo consultorio y eso baja el posicionamiento. Elegí una forma y
respetala en todos lados, tilde por tilde.

---

## Orden de ejecución

Está ordenado por retorno sobre esfuerzo. No saltees el orden: la ficha de Google rinde mucho
más que el sitio en los primeros dos meses.

### Semana 1 — La ficha de Google (lo más importante)
- [ ] Crear o reclamar la ficha de Google Business Profile → `01-google-business-profile.md`
- [ ] Verificar la ficha (Google manda un video-verificación o una postal; puede tardar 1-2 semanas)
- [ ] Cargar categoría principal, servicios, descripción, horarios y zona de atención
- [ ] Subir 15-20 fotos reales (fachada, sala de espera, consultorio, equipo de ECG, retrato)
- [ ] Publicar las 6 preguntas frecuentes en la sección Q&A

### Semana 2 — Los perfiles externos
- [ ] Completar o reclamar el perfil de Doctoralia → `03-directorios.md`
- [ ] Cargar el resto de los directorios de la lista
- [ ] Verificar que el NAP sea idéntico en todos

### Semanas 2 a 4 — El sitio
- [ ] Publicar las tres páginas de `paginas/` (una por servicio, no todo en una sola)
- [ ] Insertar los JSON-LD de `schema/` en cada página
- [ ] Verificar que el sitio cargue rápido en celular (la mayoría busca desde el teléfono)
- [ ] Dar de alta Google Search Console y enviar el sitemap

### Permanente — Lo que sostiene el resultado
- [ ] Pedir reseñas de forma sistemática → `02-resenas.md` (**el factor que más mueve la aguja**)
- [ ] Publicar 1 post en la ficha de Google por semana
- [ ] Responder el 100% de las reseñas, buenas y malas
- [ ] Revisar las métricas una vez por mes → `04-medicion.md`

---

## Expectativa realista de resultados

| Momento | Qué esperar |
|---|---|
| Semana 2-3 | La ficha aparece en Maps para búsquedas de marca (el nombre propio) |
| Mes 1-2 | Entrada al local pack para "cardiólogo Caseros" desde ubicaciones cercanas |
| Mes 2-3 | Las páginas de "riesgo quirúrgico" y "electrocardiograma" empiezan a rankear —
son las más fáciles, porque casi nadie compite localmente por ellas |
| Mes 3-6 | Top 3 estable del local pack en Caseros y consultas entrantes por Google |

---

## Dos advertencias importantes

**1. No compres reseñas y no las incentives.** Google detecta patrones de reseñas compradas y
la sanción típica es la suspensión de la ficha, que es exactamente el activo que este plan
construye. Además, en Argentina, ofrecer un beneficio a cambio de una reseña positiva puede
encuadrar como publicidad engañosa bajo la Ley de Defensa del Consumidor. `02-resenas.md`
explica cómo conseguirlas de forma legítima y sostenida, que además funciona mejor.

**2. Google es exigente con el contenido médico.** Las búsquedas de salud entran en la categoría
que Google llama *YMYL* ("tu dinero o tu vida") y se evalúan con estándares más altos de
experiencia, pericia, autoridad y confianza. En la práctica esto significa que **firmar las
páginas con nombre, matrícula y formación no es un detalle de diseño: es un factor de
posicionamiento**. Todo el contenido de `paginas/` está redactado con eso en mente: informa sin
prometer resultados, sin diagnosticar a distancia y aclarando siempre que la consulta es
necesaria.
