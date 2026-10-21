# Acción #1 — La ficha de Google: existe, y tiene un teléfono roto

**Prioridad: máxima. Costo: $0. Esto se arregla hoy.**

> **Corrección.** La primera versión de este documento decía que no había ficha
> de Google. Era falso. Lo que yo había verificado era otra cosa: que **no hay
> ninguna ficha conectada a Wix**. Salté de "no la encuentro" a "no existe".
> La ficha existe, está reclamada, y está mejor de lo que dije.

---

## La ficha real

Leída de la API de Google el 21 de octubre de 2026:

| Campo | Valor actual | Estado |
|---|---|---|
| Nombre | Dermatología Estética Nuva Skin | ✅ |
| **Categoría principal** | **Dermatólogo** | ✅ correcta |
| Categoría secundaria | Esteticista | ✅ |
| Reclamada | Sí | ✅ |
| **Reseñas** | **4,7 ★ con 36 reseñas** | ✅ muy buena |
| Dirección | Carlos Pellegrini 1015 8U, C1009 CABA | ✅ |
| Horarios | Lun–Vie 9:00–20:00 · sáb y dom cerrado | ⚠️ |
| Sitio web | esteticanuvaskin.com | ✅ |
| **Teléfono** | **`+54 4328-5309`** | 🔴 **ROTO** |
| Descripción | "Centro de Dermatología Estética" (32 caracteres) | 🔴 |
| Servicios cargados | **ninguno** | 🔴 |
| Fotos | **6** | 🔴 |
| Preguntas y respuestas | ninguna | 🔴 |
| Atributos | ninguno | 🔴 |
| Botón de reservar | ninguno | 🔴 |

- CID: `10291845774880843375`
- Place ID: `ChIJo2ed1gXLvJURb6bgJjT7044`
- Link directo: https://www.google.com/maps?cid=10291845774880843375

También hay que corregir otra cosa que dije: **las reseñas sí están en Google.**
El "4,7 con 36 reseñas" que yo había encontrado en un directorio era el rating
de Google reflejado. No tienen 0 reseñas: tienen 36 con 4,7, y la distribución
es excelente — **33 de cinco estrellas**, 1 de tres, 2 de una.

---

## 🔴 El teléfono está mal escrito, y es lo más grave del diagnóstico

La ficha tiene como teléfono principal:

```
+54 4328-5309
```

Un número de línea fija de CABA se escribe **`+54 11 4328-5309`**. **Falta el
código de área `11`.**

Lo confirman dos fuentes independientes: la API de Google Business Profile y la
API de búsqueda de ubicaciones de Google devuelven las dos el mismo número
incompleto. Y el teléfono secundario de la misma ficha — `+54 9 11 3638-5709` —
**sí** tiene el `11`, lo que descarta que sea una forma rara en que Google
muestre los números argentinos.

### Por qué esto importa tanto

El botón **Llamar** de Google Maps marca el número principal de la ficha. Si el
número está incompleto, **el botón no completa la llamada**.

El dueño dijo: *"no nos escriben ni llaman"*. Puede ser, literalmente, esto.
Toda la gente que encontró la ficha en el mapa, apretó "Llamar" y escuchó un
número inexistente, no volvió a intentar: se fue a la siguiente ficha.

Y explica una contradicción de los datos que no cerraba: la ficha tiene 36
reseñas con 4,7 — o sea que **la ficha sí trae pacientes** — y al mismo tiempo
el teléfono no suena.

**No puedo verificar desde acá que la llamada falle**, porque no puedo llamar.
Hay que probarlo a mano, y es la primera cosa que hay que hacer hoy:

> **Prueba, ahora mismo:** abrir
> https://www.google.com/maps?cid=10291845774880843375 desde un celular y
> apretar **Llamar**. Si no entra la llamada, ese es el agujero por donde se fue
> el negocio.

**El arreglo:** poner `+54 11 4328-5309` como teléfono principal.

---

## ⚠️ Dos problemas de acceso que hay que resolver primero

### 1. El token de Wix está vencido

Wix tiene una conexión a Google Business Profile registrada (creada el 12 de
junio de 2026) pero **Google está rechazando el token**:

```
Google rejected the stored refresh token (invalid_grant); reconnect required
```

Mientras siga así, el panel de Wix no puede leer ni escribir la ficha. Y eso
también significa que **nadie está viendo las estadísticas de la ficha**:
cuántas llamadas, cuántos mensajes, cuántos pedidos de "cómo llegar". Son
justamente los números que contestan "no nos llaman".

**Arreglo:** Panel de Wix → *Marketing & SEO* → *Google Business Profile* →
reconectar la cuenta de Google.

### 2. La ficha está en otra cuenta de Google

Cuando le pregunté a Google por esta ubicación desde la cuenta conectada a Wix,
respondió:

```
status: "OWNED_ELSEWHERE"
```

La ficha **pertenece a una cuenta de Google distinta** de la que está vinculada
al sitio. Puede ser un Gmail personal viejo, una agencia anterior, quien hizo
la web, un ex empleado.

Esto es un riesgo de negocio aparte del SEO: **quien tenga esa cuenta controla
la ficha** — y con ella las 36 reseñas, que son el activo más difícil de
reconstruir.

**Qué hacer:**

1. **Averiguar si la cuenta es de ustedes.** Entrar a
   https://business.google.com con cada Gmail que se les ocurra (el personal
   del Dr. Surachi, el de la clínica, el de quien hizo el sitio). Si entran y
   ven la ficha, listo: es suya, sólo hay que editarla desde ahí.
2. **Si no es de ustedes**, pedir la propiedad: en la ficha de Maps →
   *¿Sos el dueño de este negocio?* → **Solicitar acceso**. Google le avisa al
   dueño actual, que tiene **7 días** para responder. Si no responde, la
   propiedad pasa a quien la pidió.
   Guía oficial: https://support.google.com/business/answer/4566671
3. **Mientras se resuelve, no crear una ficha nueva.** Se duplicaría, Google
   castiga las dos, y las 36 reseñas se quedan en la vieja.

---

## Lo que falta cargar en la ficha

Con el acceso resuelto, en orden de impacto:

### 1. Teléfono → `+54 11 4328-5309`
Ya explicado. Es lo primero.

### 2. Los servicios (hoy: ninguno)

`services: null`. Cada servicio cargado es una búsqueda más en la que la ficha
puede aparecer. Con 31 páginas de tratamiento en el sitio y **cero servicios en
la ficha**, están desperdiciando el inventario que ya tienen escrito.

Cargar estos 14, que corresponden a páginas reales del sitio:

| Servicio | Descripción corta |
|---|---|
| Toxina botulínica (botox) | Atenuación de arrugas de expresión en frente, entrecejo y zona periocular. |
| Rellenos con ácido hialurónico | Relleno de surcos, pómulos y maxilar con ácido hialurónico. |
| Relleno de labios | Perfilado y volumen labial con ácido hialurónico. |
| Rinomodelación | Corrección del perfil nasal sin cirugía. |
| Armonización facial | Evaluación del rostro y plan que combina técnicas. |
| Peeling | Renovación de la piel para manchas, textura y marcas de acné. |
| Mesoterapia | Nutrición e hidratación profunda de la piel. |
| Plasma rico en plaquetas | Bioestimulación con plasma del propio paciente. |
| Skin booster | Hidratación profunda de la piel. |
| Tratamiento del acné | Diagnóstico y tratamiento del acné activo. |
| Cicatrices de acné | Tratamiento de secuelas y cicatrices del acné. |
| Tratamiento de la rosácea | Control del enrojecimiento y los brotes. |
| Hiperhidrosis | Reducción de la sudoración excesiva. |
| Caída del cabello | Diagnóstico y tratamiento de la pérdida capilar. |
| **Control de lunares** | Revisión de lunares y detección temprana. |
| Depilación definitiva | Depilación con luz pulsada (IPL). |

> **Control de lunares en negrita a propósito.** Es el único de la lista que
> **no** tiene página en el sitio, y es el que más demanda estacional tiene de
> noviembre a febrero en Argentina. Es el hueco más rentable que les queda.

### 3. La descripción (hoy: 32 caracteres de 750 disponibles)

Pegar tal cual:

```
Consultorio de dermatología y medicina estética en Retiro, Buenos Aires, a
cargo del Dr. Dante Surachi, médico dermatólogo. Atendemos consultas de
dermatología clínica y realizamos procedimientos estéticos: toxina botulínica,
rellenos con ácido hialurónico, relleno de labios, rinomodelación, armonización
facial, peelings, mesoterapia, skin booster y plasma rico en plaquetas.

También tratamos acné y sus cicatrices, rosácea, hiperhidrosis, manchas,
estrías, teleangiectasias y caída del cabello, y realizamos control de lunares.

Todo procedimiento empieza con una consulta de evaluación: explicamos el
procedimiento, los resultados esperables, los riesgos y los cuidados
posteriores, sin compromiso de realizarlo ese mismo día.

Estamos en Carlos Pellegrini 1015, oficina 8U, a pocas cuadras del Obelisco y
de la estación Carlos Pellegrini del subte línea B, con acceso desde 9 de Julio.

Turnos por teléfono, WhatsApp o desde nuestro sitio.
```

### 4. Fotos (hoy: 6)

Seis fotos es muy poco: es lo primero que mira alguien que compara dos fichas.

Faltan, en orden de importancia:

1. **Fachada del edificio desde la calle** — crítica: con esto el paciente sabe que llegó
2. Recepción / sala de espera
3. Consultorio, ordenado, con el equipamiento visible
4. El Dr. Surachi, de frente, con guardapolvo
5. Equipamiento (2 o 3)
6. Logo cuadrado 720×720 y portada 1024×576

Reglas: fotos propias, con luz, sin filtros, sin texto encima. **Nada de
antes-y-después sin consentimiento escrito firmado del paciente.**

Meta: llegar a 15 este mes, y 2 o 3 nuevas por mes. Google favorece las fichas
que se actualizan.

### 5. Horarios: el sábado

Hoy figura **cerrado sábados**. En estética, el sábado por la mañana es de los
momentos de mayor demanda, justamente porque la gente no puede ir entre semana.

No digo que abran: digo que es una decisión de negocio que vale la pena mirar,
y que si abren medio sábado hay que reflejarlo en la ficha el mismo día.

Si no abren, igual conviene poner una nota de horarios especiales explicando
cuándo se responden los mensajes del fin de semana. Krug lo llama reponer la
buena voluntad: pedir perdón por lo que no se puede ofrecer.

### 6. Botón de reservar (hoy: ninguno)

`book_online_url: null`. Tienen **Wix Bookings instalado con 6 servicios y
reserva online habilitada** — y la ficha no muestra ningún botón de reservar.

Wix tiene la integración hecha: Panel → *Bookings* → *Integraciones* →
*Google* → conectar. Es gratis y pone un botón **Reservar** en la ficha.

> Ojo: según el dato del CRM, la reserva online **nunca se usó** (0 reservas en
> la historia del sitio). Antes de exponerla en Google hay que probarla de
> punta a punta desde un celular. Ver `04`.

### 7. Preguntas y respuestas (hoy: ninguna)

Si no las cargan ustedes, las carga cualquiera, mal. Cargar estas:

**¿Necesito turno previo?**
> Sí, atendemos con turno. Podés pedirlo al 011 4328-5309, por WhatsApp o desde esteticanuvaskin.com.

**¿Dónde están exactamente?**
> En Carlos Pellegrini 1015, oficina 8U, a pocas cuadras del Obelisco. La estación más cercana es Carlos Pellegrini, línea B.

**¿Cuánto sale la consulta?**
> `{{COMPLETAR}}` — conviene responderla. Es la pregunta que más frena a la gente, y no responderla la manda a otra ficha.

**¿Atienden obra social o prepaga?**
> `{{COMPLETAR}}`

**¿La toxina botulínica duele?**
> Se aplica con agujas muy finas, la molestia es mínima y breve. No requiere anestesia ni reposo.

**¿Cuánto duran los resultados de la toxina botulínica?**
> El efecto se ve entre los 3 y 7 días y dura de 4 a 6 meses, según la zona y cada paciente.

**¿Hacen control de lunares?**
> Sí, con evaluación dermatológica para detección temprana. Es recomendable hacerlo una vez al año.

### 8. Atributos (hoy: ninguno)

Marcar los que correspondan: requiere turno previo · accesible en silla de
ruedas *(sólo si es cierto)* · baño · acepta tarjetas · atiende con obra social
*(si aplica)* · Wi-Fi.

---

## Las reseñas: el activo que ya tienen

**4,7 con 36 reseñas y 33 de cinco estrellas.** Eso es una base sólida. Lo que
falta no es conseguir reseñas desde cero: es **mantener el ritmo** y
**responderlas**.

Los temas que Google detecta en lo que los pacientes ya escriben:
`rinomodelación`, `paciencia`, `turnos`, `dr`, `feliz`. Son buenas señales —
pero conviene que aparezcan más tratamientos nombrados, porque Google usa esos
temas para decidir en qué búsquedas mostrar la ficha.

### Mantener el ritmo

**Meta: 4 o 5 reseñas nuevas por mes.** Con 36 ya tienen credibilidad; lo que
importa ahora es que sean **recientes**: Google pondera la frescura, y una
ficha cuya última reseña es de hace un año parece un negocio que cerró.

1. Ficha → *Pedir reseñas* → copiar el link corto
2. QR con ese link **en el mostrador**
3. Pedirla en persona al final de la consulta — es el momento de mejor respuesta
4. Por WhatsApp el mismo día, una sola vez:

```
Hola {{NOMBRE}}, gracias por venir hoy. Si te sentiste bien atendido/a, nos
ayuda muchísimo que dejes tu opinión en Google — a otras personas les sirve
para decidir. Te dejo el link: {{LINK_CORTO}}
¡Gracias!
```

### Responder las 36

Hay que responder todas, también las viejas, y las nuevas en menos de 48 horas.
Google favorece las fichas que responden.

**Nunca confirmar que la persona es o fue paciente, ni mencionar su
tratamiento** — secreto profesional, art. 156 del Código Penal y Ley 26.529.
Aunque la persona lo haya contado ella misma en la reseña pública, el
profesional no puede confirmarlo.

**Positiva:**
> ¡Muchas gracias por tomarte el tiempo de escribir! Nos alegra mucho leer esto. Saludos del equipo de Nuva Skin.

**Negativa** (hay 2 de una estrella y 1 de tres):
> Gracias por escribirnos. Lamentamos que tu experiencia no haya sido la que esperabas. No podemos tratar casos particulares por este medio, pero queremos escucharte: escribinos a esteticanuvaskin@gmail.com o al 011 4328-5309 y lo vemos en privado.

Nunca discutir, nunca dar detalles clínicos, nunca negar que la persona estuvo.

### Lo que no se puede hacer

| No hacer | Por qué |
|---|---|
| Comprar reseñas | Google suspende la ficha. Viola la Ley 24.240. |
| Ofrecer descuento a cambio | Prohibido por Google. Suspensión. |
| Pedir muchas el mismo día | Un salto brusco activa el filtro y las borra |
| Tablet en recepción para dejar la reseña ahí | Misma IP: se filtran |

---

## Publicaciones semanales

La ficha permite publicar, y hacerlo una vez por semana la mantiene activa.

| Semana | Tema | Botón |
|---|---|---|
| 1 | Estamos en Retiro: dermatología con turno | Llamar |
| 2 | **Control de lunares antes del verano** | Reservar |
| 3 | Toxina botulínica: cómo es la consulta previa | Más info |
| 4 | Acné: por qué tratarlo con dermatólogo | Más info |
| 5 | **Manchas: qué hacer antes del sol fuerte** | Llamar |
| 6 | Rellenos con ácido hialurónico: qué esperar | Más info |
| 7 | Rosácea: desencadenantes del verano | Más info |
| 8 | **Protección solar: qué recomendamos** | Más info |

Las tres en negrita son estacionales y apuntan a la ventana de noviembre a
febrero. Son las que más van a rendir.

---

## Checklist

**Hoy**
- [ ] Probar el botón **Llamar** en https://www.google.com/maps?cid=10291845774880843375 desde un celular
- [ ] Averiguar con qué cuenta de Google se administra la ficha
- [ ] Si no es de ustedes: solicitar acceso (Google da 7 días al dueño actual)
- [ ] Reconectar Google Business Profile en el panel de Wix

**Esta semana, con el acceso resuelto**
- [ ] **Teléfono principal → `+54 11 4328-5309`**
- [ ] Descripción completa (pegar la de arriba)
- [ ] 16 servicios cargados
- [ ] Subir fotos hasta llegar a 15, empezando por la fachada
- [ ] 7 preguntas y respuestas
- [ ] Atributos
- [ ] Decidir el horario del sábado
- [ ] Conectar Wix Bookings a la ficha (después de probar la reserva)
- [ ] Responder las 36 reseñas existentes
- [ ] QR del link de reseñas en el mostrador
- [ ] Primera publicación semanal

**No hacer**
- [ ] ❌ No crear una ficha nueva mientras se resuelve la propiedad
