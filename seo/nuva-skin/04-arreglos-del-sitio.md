# Acción #3 — Arreglos del sitio

Esto se divide en dos: lo que hay que arreglar **ya** porque bloquea contactos,
y lo que hay que arreglar **en 2 semanas** porque aprovecha visibilidad que ya
está pagada.

> **Nota:** no pude abrir el sitio desde este entorno (la política de red
> bloquea el dominio), así que no vi cómo se ve en pantalla. Todo lo de abajo
> sale de Search Console, de la configuración de Wix y del CRM. Los puntos
> marcados con 👁 hay que verificarlos a ojo antes de tocar.

---

## PARTE A — Urgente: el camino al contacto

### A1. WhatsApp fijo en todas las páginas 👁

En Argentina, para estética, **WhatsApp es el canal**. Hoy el sitio registró
**3 clics para contactar en 57 días** y tiene **4 formularios enviados**.

Poner el botón flotante de WhatsApp, visible en todas las páginas, fijo abajo
a la derecha, también en celular. Wix lo tiene nativo (*Agregar → Contacto →
Chat de WhatsApp*).

Con mensaje pre-cargado, que baja mucho la fricción:
```
Hola, quiero consultar por un turno en Nuva Skin.
```

### A2. El formulario tiene que pedir teléfono 👁

**21 de 351 contactos tienen teléfono.** El formulario pide mail y el teléfono
es opcional o no está. Eso es el 94 % de los contactos imposibles de llamar.

- Campo **Teléfono: obligatorio**
- Campo Mail: obligatorio
- Agregar un checkbox: `Quiero recibir información sobre tratamientos y
  novedades del consultorio` *(sin esto no hay consentimiento de marketing —
  ver `03`)*
- Quitar todo campo que no sea nombre, teléfono, mail y mensaje. Cada campo
  extra baja la tasa de envío.

### A3. Teléfono visible y clickeable arriba de todo 👁

`011 4328-5309` tiene que estar en el encabezado de todas las páginas, como
link `tel:` para que desde el celular se marque con un toque.

### A4. Revisar la reserva online 👁

6 servicios publicados, reserva habilitada, **0 reservas en la historia del
sitio**. Hay que sentarse y hacer el camino completo desde un celular, como si
fuera un paciente:

- [ ] ¿Se llega al botón de reservar desde la home en un toque?
- [ ] ¿Hay horarios cargados y disponibles en el calendario?
- [ ] ¿Los servicios tienen precio o dice "consultar"?
- [ ] ¿Pide pago anticipado? *(si pide, probablemente sea el freno — sacarlo)*
- [ ] ¿Pide crear cuenta? *(si pide, sacarlo: mata la conversión)*
- [ ] ¿Llega la notificación al consultorio cuando alguien reserva?

Si el camino tiene más de tres pasos, conviene reemplazarlo por WhatsApp como
canal principal y dejar la reserva online como alternativa.

### A5. Desinstalar Wix Hotels

Está instalada y no tiene nada que ver con una clínica. Suma peso y puede
generar páginas indexables sin sentido.

---

## PARTE B — En 2 semanas: la visibilidad que ya tienen

Estas correcciones **no requieren posicionar nada nuevo.** Google ya muestra
estas páginas; el problema es que nadie las clickea. Es la mejor relación
esfuerzo/resultado del sitio.

### B1. `/procedimientos` — la corrección más rentable

**Hoy: 526 impresiones, 2 clics, 0,4 % de CTR, posición 5,8.**

Google la muestra 526 veces y la clickean dos veces. En posición 5,8 debería
traer 25–30 clics. El problema es el título y la descripción.

| | |
|---|---|
| **Título** | `Tratamientos Dermatológicos y Estéticos en CABA \| Nuva Skin` |
| **Meta descripción** | `Botox, rellenos con ácido hialurónico, rinomodelación, peelings, mesoterapia y plasma rico en plaquetas. Consultorio del Dr. Dante Surachi en Microcentro, Carlos Pellegrini 1015. Turnos al 011 4328-5309.` |

La descripción nombra los tratamientos, el barrio y el teléfono. Eso es lo que
hace que alguien clickee.

### B2. `/` (home)

**Hoy: 1.342 impresiones, 41 clics, 3,1 % de CTR, posición 4,9.**
Lo esperable en esa posición es 5–7 %. Están perdiendo la mitad de los clics
que les corresponden.

| | |
|---|---|
| **Título** | `Dermatólogo en Microcentro CABA \| Nuva Skin - Dr. Dante Surachi` |
| **Meta descripción** | `Consultorio de dermatología y medicina estética en Carlos Pellegrini 1015, a pasos del Obelisco. Dermatología clínica, botox, rellenos y tratamiento del acné. Turnos al 011 4328-5309.` |

El título lleva **"Dermatólogo en Microcentro CABA"** adelante, no el nombre
de la marca. Nadie busca "Nuva Skin" — buscan "dermatólogo". El nombre del
doctor va igual porque es lo único que hoy les trae clics (41 % del total).

### B3. `/contacto`

**Hoy: 108 impresiones, 2 clics, posición 9,5.**

| | |
|---|---|
| **Título** | `Turnos y Contacto \| Nuva Skin Dermatología - Microcentro CABA` |
| **Meta descripción** | `Pedí tu turno al 011 4328-5309 o por WhatsApp. Carlos Pellegrini 1015, Microcentro, CABA, a pasos del Obelisco y de la estación Carlos Pellegrini (línea B).` |

### B4. `/agregue-una-resena` — sacarla del índice

**Hoy: 385 impresiones, 3 clics.** Es la 3ª página más mostrada del sitio.

Una página para dejar reseñas no debería ser una puerta de entrada desde
Google: son 385 impresiones por mes que no sirven para captar a nadie.

Ponerla en **`noindex`** (en Wix: *SEO de la página → Avanzado → No permitir
que esta página aparezca en los resultados de búsqueda*). Que siga existiendo
para mandarle el link a los pacientes, pero fuera del índice.

Lo mismo con **`/tenes-dudas`** (112 impresiones, **0 clics**): o se convierte
en una página de preguntas frecuentes real y útil, o va a `noindex`.

### B5. Arreglar las URLs con tildes

| URL actual | Cómo le llega a Google | Cambiar a |
|---|---|---|
| `/depilacióndefinitiva` | `/depilaci%C3%B3ndefinitiva` | `/depilacion-definitiva` |
| `/estrías` | `/estr%C3%ADas` | `/estrias` |

Se ven mal en el resultado de búsqueda y bajan el clic. **Importante:** al
cambiar la URL, poner la redirección 301 de la vieja a la nueva (Wix lo hace
en *Configuración → SEO → Redirecciones de URL*), si no se pierde lo poco que
tienen posicionado.

### B6. `/tratamiento-toxina-botulinica` — posición 58

El procedimiento con mejor margen y más demanda del consultorio **no existe
para Google**. Esta página necesita reescribirse completa, no retocar el
título.

| | |
|---|---|
| **URL** | `/botox-toxina-botulinica-caba` |
| **Título** | `Botox en CABA \| Toxina Botulínica - Dr. Dante Surachi` |
| **Meta descripción** | `Aplicación de toxina botulínica para arrugas de expresión en Microcentro, CABA. Consulta previa de evaluación con dermatólogo. Carlos Pellegrini 1015. Turnos al 011 4328-5309.` |

> **Por qué "Botox" en el título:** es marca registrada de Allergan, así que
> el texto de la página tiene que decir "toxina botulínica" y aclarar que
> Botox® es una marca comercial. Pero es lo que la gente escribe en Google, y
> usarlo de forma descriptiva y honesta en el título es legítimo. Nunca
> presentarlo como que son distribuidores oficiales de la marca.

Contenido mínimo de la página:
- Qué es y cómo actúa la toxina botulínica
- Qué zonas se tratan (frente, entrecejo, patas de gallo)
- Cómo es la consulta previa de evaluación
- Cómo es la sesión y cuánto dura
- A los cuántos días se ve el efecto (3–7) y cuánto dura (4–6 meses)
- Cuidados posteriores
- Contraindicaciones *(obligatorio: es contenido médico)*
- Preguntas frecuentes
- Matrícula del profesional visible

---

## PARTE C — Lo que falta estructuralmente

El sitio tiene páginas por patología (`/acne`, `/rosacea`, `/estrías`) pero
**casi ninguna tiene intención comercial local**. Les falta la combinación que
busca la gente: **tratamiento + ciudad/barrio**.

Páginas a crear, en este orden de prioridad:

| # | URL | Título | Por qué |
|---|---|---|---|
| 1 | `/control-de-lunares-caba` | `Control de Lunares en CABA \| Dermatólogo - Nuva Skin` | **Demanda estacional nov–feb. Es la ventana, ahora.** |
| 2 | `/botox-toxina-botulinica-caba` | `Botox en CABA \| Toxina Botulínica - Dr. Dante Surachi` | Mejor margen, más demanda |
| 3 | `/dermatologo-microcentro` | `Dermatólogo en Microcentro, CABA \| Nuva Skin` | Captura la búsqueda por barrio |
| 4 | `/acido-hialuronico-caba` | `Rellenos con Ácido Hialurónico en CABA \| Nuva Skin` | Alto valor por paciente |
| 5 | `/tratamiento-acne-caba` | `Tratamiento del Acné en CABA \| Dermatólogo - Nuva Skin` | Volumen alto, paciente joven, recurrente |
| 6 | `/rinomodelacion-caba` | `Rinomodelación sin Cirugía en CABA \| Nuva Skin` | Poca competencia local |

**Regla:** una página = una intención de búsqueda. No meter todos los
tratamientos en `/procedimientos` y esperar que posicione para todos. Eso es
exactamente lo que está pasando hoy y es por eso que no posiciona para
ninguno.

---

## Contenido médico: requisitos no negociables

Todo el sitio es contenido de salud. Google lo evalúa con criterios más
estrictos (YMYL), y además hay obligaciones legales:

- [ ] **Nombre completo y matrícula** del Dr. Surachi visible en toda página de tratamiento
- [ ] **Especialidad y formación** (universidad, títulos) en una página de perfil
- [ ] **Contraindicaciones y riesgos** en cada página de procedimiento
- [ ] Nada que prometa resultados
- [ ] Nada de antes-y-después sin consentimiento escrito firmado del paciente
- [ ] Dejar claro que todo procedimiento requiere consulta previa de evaluación
- [ ] Dirección, teléfono y horarios iguales en el sitio, en Google y en los directorios

---

## Checklist

**Esta semana (bloquea contactos)**
- [ ] A1 — Botón flotante de WhatsApp en todas las páginas
- [ ] A2 — Teléfono obligatorio en el formulario + checkbox de consentimiento
- [ ] A3 — Teléfono clickeable en el encabezado
- [ ] A4 — Probar la reserva online de punta a punta desde un celular
- [ ] A5 — Desinstalar Wix Hotels

**Semana 2 (visibilidad ya pagada)**
- [ ] B1 — Título y descripción de `/procedimientos`
- [ ] B2 — Título y descripción de la home
- [ ] B3 — Título y descripción de `/contacto`
- [ ] B4 — `noindex` en `/agregue-una-resena` y `/tenes-dudas`
- [ ] B5 — URLs sin tildes + redirecciones 301
- [ ] B6 — Reescribir la página de toxina botulínica

**Semanas 3 a 6 (crecimiento)**
- [ ] C1 — `/control-de-lunares-caba` *(primero: es la ventana estacional)*
- [ ] C2 — `/dermatologo-microcentro`
- [ ] C3 — `/acido-hialuronico-caba`
- [ ] C4 — `/tratamiento-acne-caba`
- [ ] C5 — `/rinomodelacion-caba`
- [ ] Matrícula y formación visibles en todo el sitio
