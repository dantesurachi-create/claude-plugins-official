# Plan de posicionamiento en Google — Soluciones Médicas, Caseros

**Sitio:** [solucionesmedicas.com.ar](https://www.solucionesmedicas.com.ar/)
**Dirección:** Dr. Amadeo Sabattini 4720, Caseros, Tres de Febrero, Buenos Aires
**Dermatología:** Dr. Dante Surachi · **Cardiología:** Dr. Hernán Surachi

Objetivo: aparecer entre los primeros resultados para las búsquedas de **cardiólogo**, **riesgo
quirúrgico** y **electrocardiograma**, y también para las de **dermatólogo**, **control de
lunares** y **acné**, hechas por gente que está a pocos kilómetros del consultorio.

> **Confirmame estos datos.** Los saqué de lo que Google tiene indexado del sitio, porque el
> entorno donde corre este análisis tiene bloqueado el acceso directo al dominio por política de
> red. Si algún nombre, especialidad o dato está mal, decímelo y lo corrijo en todo el material
> de una pasada.

---

## Cómo funciona realmente esta búsqueda

Cuando alguien en Caseros busca *"dermatologo cerca"*, Google muestra tres bloques distintos, y
cada uno se gana de una manera diferente:

| Bloque | Qué es | Cómo se gana | Cuánto tarda |
|---|---|---|---|
| **Local pack** (el mapa con 3 fichas) | Lo primero que se ve y donde se van la mayoría de los clics | Fichas de Google Business Profile + reseñas + cercanía | 4 a 10 semanas |
| **Resultados orgánicos** | Los links de abajo | Páginas del sitio, una por servicio | 2 a 5 meses |
| **Directorios** (Doctoralia) | Suelen ocupar los primeros puestos orgánicos | Tener perfil completo y con reseñas ahí también | 2 a 4 semanas |

**Lo que hay que saber con honestidad:** no se puede *garantizar* el puesto #1. En el local pack,
uno de los tres factores que Google pondera es la **distancia entre quien busca y el
consultorio**, y eso no se optimiza. Alguien que busca desde Santos Lugares va a ver resultados
distintos que alguien parado en Caseros centro. Lo que sí se puede hacer —y es lo que hace este
plan— es ganar los otros dos factores, **relevancia** y **prominencia**, de forma tan clara que
Soluciones Médicas aparezca primero para todo el que esté razonablemente cerca.

**La buena noticia:** Caseros es un mercado chico y mal trabajado. Los que hoy rankean para
"riesgo quirúrgico" son consultorios de Capital que hicieron una landing dedicada, y ninguno está
en Tres de Febrero. Esto es ganable en un trimestre.

---

## Las dos ventajas que tienen y no están usando

### 1. Son dos profesionales en una dirección → tres fichas de Google

Casi todos los centros médicos crean una sola ficha con categoría "Centro médico" y desde ahí
intentan aparecer en todas las búsquedas de especialidad. No funciona, porque la categoría
principal es el factor de relevancia más fuerte de una ficha, y "Centro médico" no es
"Cardiólogo" ni "Dermatólogo".

Las políticas de Google contemplan el caso de los consultorios con más de un profesional: además
de la ficha del establecimiento, se permite **una ficha por profesional** en la misma dirección.

```
Soluciones Médicas                      →  Centro médico
Dr. Hernán Surachi - Cardiólogo         →  Cardiólogo
Dr. Dante Surachi - Dermatólogo         →  Dermatólogo
```

**Tres tiros al local pack desde la misma puerta**, cada uno con la categoría exacta de su
búsqueda. Los detalles y las reglas que hay que respetar están en `02-google-business-profile.md`.

### 2. El sitio ya existe, y casi todo su potencial está sin usar

Cuatro páginas, ninguna dedicada a un servicio, y todas con la palabra "Dermatologo" pegada al
final del título —lo que hace que la página de contacto compita contra la de dermatología por la
misma búsqueda, y que cardiología quede prácticamente invisible.

El diagnóstico completo y la arquitectura propuesta están en `01-auditoria-del-sitio.md`.
**Hay un cambio de quince minutos ahí que es la modificación individual de mayor impacto de todo
el plan.**

---

## Qué hay en esta carpeta

| Archivo | Para qué sirve |
|---|---|
| `01-auditoria-del-sitio.md` | Qué está mal hoy en el sitio y la estructura que hay que armar |
| `02-google-business-profile.md` | Las tres fichas de Google. **Es el 60% del resultado.** |
| `03-resenas.md` | Cómo conseguir reseñas de forma sostenida y sin violar las políticas de Google |
| `04-directorios.md` | Doctoralia y el resto de los perfiles externos |
| `05-medicion.md` | Cómo saber si está funcionando |
| `paginas/home.md` | La home, reescrita |
| `paginas/cardiologia/` | Tres páginas: cardiólogo, riesgo quirúrgico, electrocardiograma |
| `paginas/dermatologia/` | Tres páginas: dermatólogo, control de lunares, acné |
| `schema/` | Datos estructurados (JSON-LD) para las siete páginas |

Todas las páginas están escritas enteras —title, meta description, encabezados, textos y
preguntas frecuentes— listas para copiar y pegar.

---

## Datos que faltan

Todo el material usa marcadores entre llaves dobles. Pasame estos valores y te devuelvo el
material completo, sin marcadores:

| Marcador | Qué poner |
|---|---|
| `{{TELEFONO}}` · `{{WHATSAPP}}` · `{{EMAIL}}` | Teléfono de turnos, WhatsApp en formato internacional, mail |
| `{{HORARIOS}}` | Días y horas de atención de cada especialidad |
| `{{OBRAS_SOCIALES}}` | Listado de coberturas |
| `{{CP}}` | Código postal |
| `{{MATRICULA_CARDIO}}` · `{{MATRICULA_DERMA}}` | Matrícula nacional y/o provincial de cada uno |
| `{{ESPECIALIDAD_CARDIO}}` · `{{ESPECIALIDAD_DERMA}}` | Certificación y dónde se formó cada uno |
| `{{UNIVERSIDAD_CARDIO}}` · `{{UNIVERSIDAD_DERMA}}` | Universidad de cada uno |
| `{{REFERENCIA_UBICACION}}` | Referencia del barrio: "a X cuadras de la estación de Caseros" |
| `{{LAT}}` / `{{LNG}}` | Clic derecho sobre la puerta del consultorio en Google Maps |
| `{{INSTAGRAM}}` · `{{FACEBOOK}}` | Usuarios de redes |
| `{{PERFIL_DOCTORALIA_CARDIO}}` · `{{..._DERMA}}` | Final de la URL de cada perfil de Doctoralia, si existen |
| `{{CID_DE_LA_FICHA}}` | El número después de `cid=` en la URL de la ficha en Google Maps |

Lo que sí está ya completado en todo el material: el dominio, la dirección, los nombres de los
profesionales y la asignación de especialidades.

**Regla de oro — consistencia NAP:** el nombre, la dirección y el teléfono (*Name, Address,
Phone*) tienen que estar escritos **exactamente igual** en las tres fichas de Google, en el
sitio, en Doctoralia y en todos lados. Si en un lugar dice "Dr. Amadeo Sabattini 4720" y en otro
"Amadeo Sabattini 4720", Google duda de que sean el mismo consultorio y eso baja el
posicionamiento. Elegí una forma y respetala tilde por tilde.

---

## Orden de ejecución

Ordenado por retorno sobre esfuerzo. No saltees el orden: las fichas de Google rinden mucho más
que el sitio en los primeros dos meses.

### Esta semana — lo que no puede esperar
- [ ] **Sacar el sufijo "| Dermatologo" de los títulos de las páginas internas** y escribir cada
      título a mano. Quince minutos, y es el cambio individual de mayor impacto.
- [ ] Buscar fichas duplicadas o viejas del consultorio y de cada profesional, y reclamarlas
- [ ] Crear o reclamar las tres fichas de Google y lanzar la verificación, que puede tardar una
      o dos semanas

### Semana 1-2 — las fichas
- [ ] Categorías, servicios, descripción, horarios y zona de atención en las tres
- [ ] 15 fotos reales por ficha
- [ ] Preguntas frecuentes publicadas y respondidas
- [ ] Los tres links de reseñas generados, impresos como QR e identificados

### Semanas 2-4 — el sitio
- [ ] Publicar `/dermatologia/control-de-lunares` **primero** (ver abajo por qué)
- [ ] Publicar `/cardiologia`, `/dermatologia` y el resto de las páginas de servicio
- [ ] Insertar los JSON-LD de `schema/` en cada página
- [ ] Enlaces internos con texto descriptivo, y el mismo pie de página en todas
- [ ] Dar de alta Google Search Console y enviar el sitemap

### Semana 2-3 — los perfiles externos
- [ ] Un perfil de Doctoralia por profesional
- [ ] Apple Maps, Bing Places, Waze y el resto de la lista

### Permanente
- [ ] Pedir reseñas de forma sistemática, cada profesional para su ficha
- [ ] Un post por semana en cada ficha
- [ ] Responder el 100% de las reseñas, buenas y malas
- [ ] Revisar las métricas una vez por mes

---

## ⏰ Una cosa tiene fecha: el control de lunares

La página de control de lunares es la de mayor retorno de todo el plan, y tiene ventana.

Es la búsqueda dermatológica con más intención —quien la hace se vio algo que lo preocupa y
quiere turno esta semana— y además es **estacional**: las búsquedas sobre lunares y cáncer de
piel arrancan con la primavera, trepan durante noviembre, cuando la campaña nacional de
prevención instala el tema en los medios, y se sostienen alto todo el verano.

Hoy es **16 de septiembre**. La primavera empieza en cinco días. Una página nueva tarda entre
tres y ocho semanas en asentarse en Google. Si esa página se publica en las próximas dos semanas,
llega posicionada justo al pico; si se publica en noviembre, llega tarde y hay que esperar al año
que viene.

**Está escrita y lista en `paginas/dermatologia/control-de-lunares.md`.** Es lo primero que
publicaría de todo el sitio.

---

## Expectativa realista

| Momento | Qué esperar |
|---|---|
| Semana 2-3 | Las fichas aparecen en Maps para búsquedas de marca |
| Mes 1-2 | Entrada al local pack para "cardiólogo Caseros" y "dermatólogo Caseros" desde ubicaciones cercanas |
| Mes 2-3 | Las páginas de servicio empiezan a rankear — son las más fáciles, porque casi nadie compite localmente por ellas |
| Nov-Ene | Pico de temporada de control de lunares, si la página se publicó a tiempo |
| Mes 3-6 | Top 3 estable del local pack en Caseros, en las dos especialidades |

---

## Dos advertencias importantes

**1. No compren reseñas y no las incentiven.** Google detecta patrones de reseñas compradas y la
sanción típica es la suspensión de la ficha, que es exactamente el activo que este plan
construye. Además, en Argentina, ofrecer un beneficio a cambio de una reseña positiva puede
encuadrar como publicidad engañosa bajo la Ley de Defensa del Consumidor. `03-resenas.md`
explica cómo conseguirlas de forma legítima, que además funciona mejor.

**2. Google es exigente con el contenido médico.** Las búsquedas de salud entran en la categoría
que Google llama *YMYL* ("tu dinero o tu vida") y se evalúan con estándares más altos de
experiencia, pericia, autoridad y confianza. En la práctica: **firmar las páginas con nombre,
matrícula y formación no es un detalle de diseño, es un factor de posicionamiento**. Todas las
páginas de `paginas/` están redactadas con eso en mente —informan sin prometer resultados, sin
diagnosticar a distancia, sin nombrar fármacos ni dosis, y aclarando siempre que la consulta es
necesaria.
