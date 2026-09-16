# Auditoría de solucionesmedicas.com.ar

> **Cómo se hizo:** el entorno donde corre este análisis tiene bloqueado el acceso directo al
> dominio por política de red, así que no pude abrir el sitio y leer el HTML. Lo que sigue está
> hecho sobre **lo que Google tiene indexado** del sitio: las URLs, los títulos y las
> descripciones tal como los ve el buscador.
>
> Para el objetivo de este trabajo eso alcanza y sobra, porque el título indexado *es* el activo
> que posiciona. Pero significa que no vi el contenido interno de las páginas: si algo de lo que
> sigue no coincide con lo que hay, avisame y lo corrijo.

---

## Lo que hay hoy

| URL | Título indexado |
|---|---|
| `/` | Soluciones Medicas \| Dermatologo \| Cardiologo \| Caseros |
| `/especialidades` | ESPECIALIDADES - Soluciones Medicas \| Dermatologo |
| `/nosotros` | NOSOTROS - Soluciones Medicas \| Dermatologo |
| `/contacto` | CONTACTO - Soluciones Medicas \| Dermatologo |

Cuatro páginas. Estructura de folleto institucional: quiénes somos, qué hacemos, cómo
contactarnos.

---

## Problema 1 — Una sola página intenta rankear para todo

El título de la home apila cuatro conceptos: la marca, dermatólogo, cardiólogo y Caseros.

La intuición dice que así se cubren todas las búsquedas. Funciona exactamente al revés. Google
necesita entender **de qué trata cada página** para decidir en qué búsqueda mostrarla, y una
página que dice "somos dermatología y cardiología y estética y todas las especialidades" no
tiene un tema claro. Compite contra un consultorio que tiene una página entera dedicada a
"cardiólogo en Caseros" y pierde, porque el otro tiene toda la página apuntando a esa búsqueda
y ustedes tienen un cuarto de título.

**La regla es una búsqueda, una página.** Hoy hay cuatro páginas para cubrir dos especialidades
y una decena de servicios con intención de búsqueda propia. Faltan páginas, no sobran.

## Problema 2 — Todas las páginas internas dicen "Dermatologo"

El sitio agrega `- Soluciones Medicas | Dermatologo` al final del título de cada página. Eso
hace que la página de contacto y la de "nosotros" compitan por la búsqueda "dermatólogo", que
es una búsqueda que ninguna de las dos puede satisfacer.

Dos consecuencias concretas:

- **Canibalización:** cuatro páginas del mismo sitio compiten entre sí por el mismo término.
  Google tiene que elegir una y suele elegir mal, o repartir la fuerza entre todas.
- **Cardiología queda invisible:** solo la home menciona "Cardiologo", y lo hace en cuarto lugar
  del título. Para las tres búsquedas que trajeron este pedido —cardiólogo, riesgo quirúrgico,
  electrocardiograma— **el sitio hoy no tiene ninguna página dedicada**.

## Problema 3 — No existen las páginas que generan turnos

Las búsquedas que traen pacientes con intención inmediata no son "dermatólogo" o "cardiólogo"
a secas. Son las específicas: alguien que tiene fecha de cirugía y necesita el apto, alguien
con una orden de electrocardiograma en la mano, alguien que se vio un lunar raro.

Ninguna de esas búsquedas tiene hoy una página en el sitio a la que llegar. Y son, justamente,
las de menor competencia local: para "riesgo quirúrgico" quienes rankean son consultorios de
Capital que hicieron una landing dedicada, y ninguno está en Tres de Febrero.

## Problema 4 — Dos especialidades bajo una sola identidad

Dermatología y cardiología no comparten paciente, ni búsqueda, ni estacionalidad. Mezclarlas en
la misma página hace que ninguna de las dos quede clara.

Esto **no** significa separar el sitio en dos. La marca compartida es una ventaja: una sola
dirección, una sola reputación, un solo esfuerzo técnico. Lo que hace falta es que cada
especialidad tenga su propia rama.

---

## La arquitectura propuesta

Estructura de eje y radios: cada especialidad tiene una página madre que concentra la búsqueda
genérica, y debajo las páginas de servicio que capturan la búsqueda específica.

```
/                                  Soluciones Médicas — la clínica
│                                  → "centro médico caseros", marca
│
├── /cardiologia                   → "cardiólogo caseros"
│   ├── /cardiologia/riesgo-quirurgico      → "riesgo quirúrgico caseros"
│   └── /cardiologia/electrocardiograma     → "electrocardiograma caseros"
│
├── /dermatologia                  → "dermatólogo caseros"
│   ├── /dermatologia/control-de-lunares    → "control de lunares caseros"
│   └── /dermatologia/acne                  → "tratamiento acné caseros"
│
├── /nosotros                      → los profesionales, matrículas, formación
├── /contacto                      → dirección, mapa, horarios, obras sociales
└── /turnos                        → (opcional) reserva online
```

Las páginas actuales `/especialidades`, `/nosotros` y `/contacto` se conservan. `/especialidades`
pasa a ser un índice que enlaza a las dos ramas, en lugar de intentar describirlo todo.

### Los títulos corregidos

| Página | Title propuesto |
|---|---|
| `/` | Soluciones Médicas \| Centro Médico en Caseros |
| `/cardiologia` | Cardiólogo en Caseros \| Soluciones Médicas |
| `/cardiologia/riesgo-quirurgico` | Riesgo Quirúrgico en Caseros \| Apto en el Día |
| `/cardiologia/electrocardiograma` | Electrocardiograma en Caseros \| ECG con Informe |
| `/dermatologia` | Dermatólogo en Caseros \| Soluciones Médicas |
| `/dermatologia/control-de-lunares` | Control de Lunares en Caseros \| Dermatoscopía |
| `/dermatologia/acne` | Tratamiento del Acné en Caseros \| Dermatología |
| `/nosotros` | Nuestros Profesionales \| Soluciones Médicas Caseros |
| `/contacto` | Turnos y Contacto \| Soluciones Médicas Caseros |

**Fijate que ninguna página interna repite la palabra "Dermatologo" al final.** Hay que
desactivar ese sufijo automático en la configuración del sitio y escribir cada título a mano.
Es un cambio de quince minutos y es la modificación individual de mayor impacto de toda esta
auditoría.

### Los enlaces internos

Google descubre la importancia de una página por cuántos enlaces internos apuntan a ella.

- La home enlaza a `/cardiologia` y `/dermatologia` de forma destacada, con texto de enlace
  descriptivo: **"Cardiología en Caseros"**, no "ver más" ni "leé acá"
- Cada página madre enlaza a sus dos páginas de servicio
- Cada página de servicio enlaza de vuelta a su página madre y a la otra de servicio
- Todas enlazan a `/contacto`
- `/nosotros` enlaza a cada especialidad desde la biografía de cada profesional

### El pie de página, en todas las páginas

```
Soluciones Médicas
Dr. Amadeo Sabattini 4720, Caseros, Tres de Febrero, Buenos Aires
Tel: {{TELEFONO}} · WhatsApp: {{WHATSAPP}}
{{HORARIOS}}
```

Escrito **exactamente igual** que en las fichas de Google y en Doctoralia, tilde por tilde.

---

## Revisión técnica pendiente

Estas cosas no las pude verificar sin acceder al sitio. Comprobalas o pasame el acceso y las
reviso:

- [ ] **Velocidad en celular.** La mayoría de estas búsquedas se hacen desde el teléfono.
      Medila en [PageSpeed Insights](https://pagespeed.web.dev/). Si el puntaje móvil está por
      debajo de 50, es prioridad: las fotos sin comprimir suelen ser la causa.
- [ ] **Google Search Console dado de alta** y con el sitemap enviado. Sin esto no hay forma de
      saber en qué posición está el sitio.
- [ ] **HTTPS con certificado válido** en todo el sitio, sin contenido mixto.
- [ ] **Botón de WhatsApp flotante**, visible en todas las páginas sin hacer scroll.
- [ ] **Teléfono como enlace `tel:`**, para que se pueda llamar con un toque desde el celular.
- [ ] **Texto alternativo en las imágenes**, describiendo lo que se ve.
- [ ] **Una sola versión del dominio.** Que `solucionesmedicas.com.ar` redirija a
      `www.solucionesmedicas.com.ar` (o al revés), nunca que las dos respondan por separado.
- [ ] **Sin contenido duplicado** entre `/especialidades` y las nuevas páginas de especialidad.

## Una pregunta sobre Nuva Skin

En la cuenta de Wix aparece **esteticanuvaskin.com.ar**, de medicina estética, y el sitio de
Soluciones Médicas menciona un equipo de estética. Si las dos marcas funcionan en la misma
dirección, hay que decidirlo explícitamente: pueden convivir como negocios distintos en Google,
pero conviene que estén enlazadas entre sí y que quede claro cuál atiende qué. Contame cómo está
armado y lo resolvemos.
