# Acción #2 — Los 351 contactos que nadie trabajó

**Prioridad: alta. Costo: $0. Primeros resultados: 2 a 7 días.**

---

## El número que explica todo

Miré los 351 contactos del CRM y los agrupé por el año en que entraron:

| Año | Contactos nuevos | Por mes |
|---|---|---|
| 2022 | 53 | 4,4 |
| **2023** | **146** | **12,2** |
| 2024 | 118 | 9,8 |
| 2025 | 24 | 2,0 |
| **2026** (10 meses) | **10** | **1,0** |

**El flujo de consultas cayó un 92 % entre 2023 y 2026.**

De 12 personas por mes dejando sus datos, a 1. Eso no es una mala racha: es
una caída sostenida de tres años. Y coincide exactamente con lo que vimos en
Search Console — el sitio hoy capta casi exclusivamente a gente que ya busca
el nombre del doctor.

Esto es importante por dos razones:

1. **No es que el negocio nunca funcionó.** En 2023 entraban 12 consultas por
   mes desde el sitio. El canal funcionaba. Se apagó.
2. **Los 351 no son una base muerta.** Son 351 personas que en algún momento
   levantaron la mano.

---

## Qué son realmente estos 351 contactos

Hay que ser preciso acá, porque cambia cómo se les escribe:

| Origen | Cantidad |
|---|---|
| Formularios del sitio | 343 |
| Chat del sitio | 7 |
| Miembro del sitio | 1 |

| Etiqueta | Cantidad |
|---|---|
| `suscripciones` | 216 |
| `contacto` | 127 |
| `contactanos` | 7 |

**No son todos pacientes.** Son personas que dejaron su mail en el sitio: unas
pidiendo información, otras suscribiéndose. Algunas habrán venido a la
consulta, otras no.

Eso significa que **127 personas usaron el formulario de contacto** —
preguntaron por un tratamiento— y están sentadas en una base de datos. No sé
cuántas recibieron respuesta. Si una parte no la recibió, ahí hay turnos
perdidos que se pueden recuperar esta semana.

### Cómo se les puede llegar

| Canal | Alcance |
|---|---|
| Email | **351 de 351** |
| Teléfono / WhatsApp | **21 de 351** |

Esto es un problema de diseño del formulario: **pide mail pero casi nunca
teléfono.** En Argentina, para estética, WhatsApp convierte muchísimo mejor
que el mail. Hay que corregir el formulario ya (ver `04`), pero para esta
campaña el canal es el mail.

---

## Antes de mandar nada: el límite legal

**Ninguno de los 351 figura con consentimiento de marketing registrado**
(Wix los tiene todos en estado "sin definir", no en "suscripto").

Eso no significa que no se les pueda escribir, pero sí cambia **qué** se les
puede escribir y **cómo**:

**Sí se puede:** responder o retomar la consulta que esa persona inició. Dejó
su mail en un formulario del consultorio pidiendo información. Retomar ese
hilo es atender una consulta, no hacer publicidad no solicitada.

**No se puede:** mandar una promoción masiva tipo "20 % off en botox" a 351
direcciones como si fuera una lista de marketing consentida.

Reglas obligatorias para toda la campaña:

| Regla | Por qué |
|---|---|
| Mandar **de a uno o con copia oculta (CCO)** | Poner 351 direcciones en "Para" expone datos personales de todos a todos. Ley 25.326. |
| **Nunca el tratamiento en el asunto** | Los datos de salud son *datos sensibles*. El asunto se ve en la notificación del celular, que puede ver un tercero. |
| **Siempre cómo darse de baja**, y respetarlo | Ley 25.326, y además evita que caiga en spam. |
| **Sin promesas de resultados** | Publicidad de práctica médica. |
| **Sin antes-y-después** sin consentimiento escrito firmado | Igual. |
| Mandar en tandas de 40–60 por día | Un envío de 351 de golpe desde una cuenta sin historial va a spam. |

---

## La campaña: tres mensajes

No es un newsletter. Son tres mensajes distintos para tres grupos distintos.

### Grupo A — Los 127 del formulario de contacto

Son los más valiosos: preguntaron activamente por un tratamiento.

**Asunto:**
```
Consulta en Nuva Skin — seguimos a disposición
```

**Cuerpo:**
```
Hola {{NOMBRE}},

Te escribo del consultorio de dermatología del Dr. Dante Surachi, en Carlos
Pellegrini 1015, Microcentro.

En algún momento nos dejaste tus datos para consultarnos y quería retomar el
contacto, por si todavía te interesa.

Atendemos consultas de dermatología clínica y procedimientos estéticos. La
primera consulta es de evaluación: vemos el caso, explicamos qué se puede
hacer, qué resultados son esperables y qué cuidados requiere, sin compromiso
de hacer el tratamiento ese día.

Si querés un turno, podés escribirme a este mail o llamarnos al 011 4328-5309.

Saludos,
Dr. Dante Surachi
Nuva Skin Dermatología Estética
Carlos Pellegrini 1015, CABA
esteticanuvaskin.com

Si no querés recibir más mensajes nuestros, respondé "BAJA" y te damos de baja.
```

### Grupo B — Los 216 suscriptos

Estos se anotaron para recibir información. Hay que darles información real,
con una puerta de entrada al final. No un aviso.

**Asunto (estacional, y funciona):**
```
Chequeo anual de lunares: por qué conviene hacerlo antes del verano
```

**Cuerpo:**
```
Hola {{NOMBRE}},

Estamos entrando en la época del año de más exposición al sol, así que va un
recordatorio que suele pasarse por alto: el control de lunares conviene hacerlo
una vez al año, y el mejor momento es antes del verano, no después.

Qué mirar en casa, como referencia general:

- Un lunar que cambió de tamaño, de forma o de color
- Bordes irregulares o mal definidos
- Más de un color en el mismo lunar
- Más de 6 mm de diámetro
- Que pique, sangre o no termine de cicatrizar

Si algo de esto aparece, no es motivo de alarma, pero sí de consulta. La
mayoría de las lesiones de piel detectadas temprano se resuelven de forma
simple.

En el consultorio hacemos control de lunares con evaluación dermatológica.
Turnos al 011 4328-5309 o respondiendo este mail.

Saludos,
Dr. Dante Surachi
Nuva Skin Dermatología Estética
Carlos Pellegrini 1015, CABA

Si no querés recibir más mensajes, respondé "BAJA".
```

> **Por qué este tema y no botox:** el chequeo de lunares tiene demanda
> estacional real de noviembre a febrero, es una consulta médica (no un
> tratamiento estético), y por eso se puede comunicar a una base sin
> consentimiento de marketing sin que suene a publicidad. Es la mejor puerta
> de entrada que tienen en este momento del año. Y el paciente que entra por
> un control de lunares después consulta por lo demás.

### Grupo C — Los 21 con teléfono

Acá sí WhatsApp, uno por uno, a mano. No una difusión.

```
Hola {{NOMBRE}}, ¿cómo estás? Te escribo del consultorio del Dr. Surachi
(Nuva Skin, Carlos Pellegrini 1015). Nos habías consultado hace un tiempo y
quería saber si seguís interesado/a en una consulta. Estamos dando turnos esta
semana. Si no te interesa, decime y no te molesto más.
```

> **Importante:** por WhatsApp, uno por uno. **Nunca** usar lista de difusión
> con 21 contactos para un tema de salud, y nunca mencionar el tratamiento
> específico en el primer mensaje.

---

## Cronograma

| Día | Qué |
|---|---|
| 1 | Grupo C completo (21 WhatsApp, a mano) |
| 1 | Grupo A, tanda 1 (40 mails) |
| 2 | Grupo A, tanda 2 (40) |
| 3 | Grupo A, tanda 3 (47) |
| 4 | Grupo B, tanda 1 (50) |
| 5 | Grupo B, tanda 2 (50) |
| 8 | Grupo B, tanda 3 (50) |
| 9 | Grupo B, tanda 4 (66) |
| 15 | A quienes abrieron y no respondieron: un solo recordatorio |

**Una sola insistencia. Nada más.** Un segundo recordatorio a quien no
contestó convierte poco y genera bajas y denuncias de spam.

---

## Qué esperar, con honestidad

Una base de 2022–2024 sin contacto previo, con un mensaje bien escrito:

| Métrica | Rango realista |
|---|---|
| Apertura (mail) | 15–30 % |
| Respuesta (Grupo A) | 3–8 % → **4 a 10 consultas** |
| Respuesta (Grupo B) | 1–3 % → **2 a 6 consultas** |
| Respuesta (WhatsApp, Grupo C) | 20–40 % → **4 a 8 consultas** |
| **Total de consultas** | **10 a 24** |
| Turnos efectivos | 40–60 % de eso → **4 a 14 turnos** |

**4 a 14 turnos en dos semanas, con costo cero.** No salva el negocio solo,
pero es caja esta quincena y es lo más rápido que tienen disponible.

Y lo más valioso no es el turno: es que **cada persona que vuelve es una
reseña de Google potencial**, que es lo que hace funcionar la acción #1.

---

## Lo que hay que arreglar para que esto no vuelva a pasar

| Problema | Arreglo |
|---|---|
| El formulario pide mail pero casi nunca teléfono (21 de 351) | Hacer el teléfono **obligatorio**. Ver `04`. |
| Nadie tiene consentimiento de marketing registrado | Agregar un checkbox claro de "quiero recibir información" en el formulario. |
| Las consultas que entran no tienen seguimiento sistemático | Regla fija: responder toda consulta en menos de 2 horas hábiles. En estética, el que contesta primero se queda con el paciente. |
| No hay registro de quién vino y quién no | Etiquetar en el CRM: `consulta-pedida`, `turno-dado`, `vino`, `no-vino`. Sin esto no se puede reactivar nada el año que viene. |
