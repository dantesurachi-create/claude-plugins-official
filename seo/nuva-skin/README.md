# Nuva Skin — Plan de recuperación de pacientes

**Negocio:** Dermatología Estética Nuva Skin
**Sitio:** https://www.esteticanuvaskin.com/
**Dirección:** Carlos Pellegrini 1015, Retiro, CABA
**Profesional:** Dr. Dante Surachi
**Fecha del diagnóstico:** 21 de octubre de 2026

---

## El diagnóstico en una frase

**No es un problema de conversión. El negocio se volvió invisible, y pasó de
a poco durante tres años.**

Este es el número que lo explica todo — contactos nuevos que entraron al sitio,
por año:

| Año | Contactos nuevos | Por mes |
|---|---|---|
| 2022 | 53 | 4,4 |
| **2023** | **146** | **12,2** |
| 2024 | 118 | 9,8 |
| 2025 | 24 | 2,0 |
| **2026** (10 meses) | **10** | **1,0** |

**El flujo de consultas cayó un 92 % desde 2023.** De 12 personas por mes
dejando sus datos, a 1.

Hoy llegan **1,4 visitas por día** al sitio, y **4 de cada 10 clics son de
alguien que ya escribió "Dante Surachi" en Google** — gente que ya los conocía.
Pacientes nuevos captados por Google: casi ninguno.

"No nos escriben ni llaman" es exactamente lo que se espera con estos números.
**El embudo no tiene una fuga: está vacío.**

Y acá está la otra cara: el sitio **sí convierte**. De 61 visitantes únicos en
dos meses, 7 hicieron contacto — un 11 %, que es una buena tasa. El problema no
es el sitio. Es que no hay nadie a quien convertir.

La buena noticia que esconde este cuadro: **en 2023 esto funcionaba.** Entraban
12 consultas por mes. No hay que inventar un canal nuevo, hay que volver a
prender el que se apagó.

---

## Los agujeros, en orden de tamaño

### 1. 🔴 El teléfono de la ficha de Google está mal escrito

La ficha de Google tiene como teléfono principal:

```
+54 4328-5309
```

Un fijo de CABA se escribe **`+54 11 4328-5309`**. **Falta el código de área
`11`.** Dos APIs distintas de Google devuelven el mismo número incompleto, y el
teléfono secundario de la misma ficha sí lo tiene — así que no es una rareza de
cómo Google muestra los números argentinos.

El botón **Llamar** de Google Maps marca el número principal. Si está
incompleto, **el botón no completa la llamada.**

"No nos escriben ni llaman" puede ser, literalmente, esto. Y explica la
contradicción que no cerraba en los datos: la ficha tiene **36 reseñas con
4,7 ★** —o sea que sí trae pacientes— y al mismo tiempo el teléfono no suena.

> **Primera cosa a hacer hoy:** abrir
> https://www.google.com/maps?cid=10291845774880843375 desde un celular y
> apretar **Llamar**. No pude verificarlo yo porque no puedo llamar por
> teléfono desde acá.

→ Ver `02-google-business-profile.md`

### 2. La ficha existe, está buena, y está medio vacía

**Corrección a mi primer diagnóstico:** yo dije que no había ficha de Google.
Era falso. Lo que había verificado era que **no hay ninguna conectada a Wix**, y
salté de "no la encuentro" a "no existe".

La ficha existe, está reclamada, tiene la categoría principal correcta
(`Dermatólogo`) y **4,7 ★ con 36 reseñas**, 33 de ellas de cinco estrellas. Las
reseñas sí están en Google: también me equivoqué en eso.

Lo que le falta:

| Campo | Estado |
|---|---|
| Teléfono | 🔴 roto (ver arriba) |
| Servicios cargados | 🔴 **ninguno** |
| Descripción | 🔴 32 caracteres de 750 |
| Fotos | 🔴 6 |
| Preguntas y respuestas | 🔴 ninguna |
| Atributos | 🔴 ninguno |
| Botón de reservar | 🔴 ninguno, con Wix Bookings instalado |
| Sábados | ⚠️ cerrado (es el día de más demanda en estética) |

Y dos problemas de acceso: **el token de Google en Wix está vencido**
(`invalid_grant`), así que nadie está viendo las estadísticas de la ficha; y la
ficha **pertenece a otra cuenta de Google** (`OWNED_ELSEWHERE`), distinta de la
vinculada al sitio. Eso último es un riesgo de negocio aparte: quien tenga esa
cuenta controla la ficha y las 36 reseñas.

### 3. Hay 351 contactos sin trabajar, de los años buenos

El CRM tiene **351 contactos**, y el 90 % entró entre 2022 y 2024 — los años en
que el canal funcionaba. Son personas que dejaron su mail en el sitio: **127 por
el formulario de contacto** (preguntaron activamente por un tratamiento) y
**216 suscribiéndose** para recibir información.

No son todos pacientes, y eso importa para cómo se les escribe. Pero son 351
personas que en algún momento levantaron la mano y hoy están quietas en una
base de datos.

**Dos límites que hay que respetar:**
- Solo **21 de 351 tienen teléfono** cargado. El formulario pide mail y casi
  nunca teléfono — hay que corregirlo ya. Para esta campaña, el canal es el mail.
- **Ninguno figura con consentimiento de marketing registrado.** Eso no impide
  escribirles, pero cambia qué se les puede mandar: se retoma su consulta, no se
  les hace publicidad masiva. Detalle legal en `03`.

→ Ver `03-reactivacion-base.md`

### 4. El sistema de turnos online nunca se usó

Wix Bookings está instalado con **6 servicios publicados y reserva online
habilitada** en todos. **Reservas registradas: cero.** Nunca entró ninguna.

O nadie llega a esa pantalla (coherente con 1,4 visitas/día), o el camino está
roto, o no es el que el paciente argentino usa. En Argentina, para estética,
**el canal es WhatsApp** — no un formulario.

→ Ver `04-arreglos-del-sitio.md`

### 5. El sitio ya está bien optimizado — y eso cambia el plan

**Segunda corrección.** Yo iba a reescribir los títulos de las páginas. Al
leer los 31 títulos reales encontré que **ya están bien hechos**: tratamiento +
barrio + ciudad + marca, en las 24 páginas de tratamiento. Alguien hizo ese
trabajo, y el sitio se actualizó el 20 de octubre de 2026.

Eso significa dos cosas:

1. Varios de los cambios que yo proponía habrían sido laterales o peores. Los
   descarté.
2. Si esos títulos son nuevos, los datos de Search Console que leí reflejan el
   estado *anterior*. Un cambio de títulos tarda **3 a 8 semanas** en verse:
   **parte del trabajo ya está hecho y todavía no rindió.**

Apliqué sólo los **5 cambios** que los datos muestran fallando de verdad, y
están hechos y publicados. Detalle en `04`.

## Lo que tengo que decirles antes de seguir

Ustedes me pidieron SEO. **El SEO no va a salvar este negocio en el plazo que
tienen.** Posicionar términos comerciales competitivos en CABA ("botox",
"ácido hialurónico", "dermatólogo caba") lleva de 4 a 8 meses. Hoy el sitio
está en posición 82 para "botox caba" y 48 para "dermatologia buenos aires".
Eso no se da vuelta en semanas.

Si el cierre está a semanas o a un par de meses, hay que atacar en este orden:

| # | Acción | Primeros resultados | Costo |
|---|---|---|---|
| 1 | **Arreglar el teléfono de la ficha de Google** | inmediato | $0 |
| 2 | Recuperar el acceso a la ficha + reconectar Wix | 1–7 días | $0 |
| 3 | Completar la ficha: servicios, descripción, fotos | 3–14 días | $0 |
| 4 | Campaña a los 351 contactos de la base | 2–7 días | $0 |
| 5 | WhatsApp y teléfono visibles en todo el sitio | inmediato | $0 |
| 6 | Página de control de lunares (ventana estacional) | 3–8 semanas | $0 |
| 7 | Pauta (Google/Meta) si hay caja para sostenerla | días | $$ |
| 8 | Esperar que rindan los títulos ya corregidos | 3–8 semanas | $0 |

El SEO de términos nuevos no está en los primeros seis puestos, y el trabajo
de títulos ya está hecho y sólo falta esperarlo. Sigue valiendo la pena — es lo que hace
que esto no vuelva a pasar — pero no es lo que paga el alquiler de este mes.

---

## Orden de ejecución

**Hoy**
1. Probar el botón **Llamar** de la ficha desde un celular (`02`)
2. Averiguar con qué cuenta de Google se administra la ficha (`02`)
3. Reconectar Google Business Profile en el panel de Wix (`02`)

**Esta semana**
4. Corregir el teléfono a `+54 11 4328-5309` (`02`)
5. Cargar los 16 servicios y la descripción completa en la ficha (`02`)
6. Botón flotante de WhatsApp y teléfono clickeable en el sitio (`04`, `05`)
7. Teléfono obligatorio en el formulario (`04`)
8. Primera tanda de reactivación (`03`)

**Semana 2**
9. Fotos de la ficha hasta llegar a 15 (`02`)
10. Responder las 36 reseñas existentes (`02`)
11. Probar la reserva online de punta a punta (`04`)
12. Renombrar las etiquetas del menú (`05`)

**Semanas 3 y 4**
13. Publicar `/control-de-lunares-caba` (`04`)
14. Segunda tanda de reactivación (`03`)
15. Plantilla de 12 puntos en botox, rellenos y acné (`05`)
16. Probar el sitio con 3 personas (`05`)

## Advertencias que no son negociables

**Datos de pacientes (Ley 25.326).** Los datos de salud son *datos sensibles*.
Al contactar a los 351:
- Nunca poner el tratamiento en el asunto del mail ni en una vista previa que
  pueda leer un tercero.
- Mandar **individualmente o con copia oculta** — jamás un "para" con 351
  direcciones visibles.
- Incluir siempre cómo dejar de recibir mensajes, y respetarlo.

**Secreto profesional (art. 156 Código Penal, Ley 26.529).** Al responder
reseñas públicas, **nunca confirmar que alguien es o fue paciente**, ni
mencionar su tratamiento. Agradecer en general y ofrecer el canal privado.

**Publicidad de prácticas médicas.** No prometer resultados, no usar
"antes y después" sin consentimiento escrito del paciente, no presentar
procedimientos médicos como si no tuvieran riesgo.

**Reseñas.** Ya tienen 36 con 4,7: el objetivo no es juntar desde cero sino
mantener el ritmo (4 o 5 por mes) y responderlas todas. No comprar reseñas ni
ofrecer descuentos a cambio. Google
suspende la ficha y además configura infracción a la Ley 24.240.

---

## Los archivos

| Archivo | Contenido |
|---|---|
| `01-diagnostico-datos.md` | Todos los números, con su fuente, y las dos correcciones a mi primer diagnóstico |
| `02-google-business-profile.md` | La ficha real, el teléfono roto, el problema de propiedad, y todo lo que falta cargar |
| `03-reactivacion-base.md` | Campaña a los 351: segmentación, tres mensajes redactados, cronograma y límites legales |
| `04-arreglos-del-sitio.md` | Los 5 cambios ya aplicados por API, lo que no toqué y por qué, y lo que queda a mano |
| `05-ux-dont-make-me-think.md` | Las decisiones de UX/UI según *Don't Make Me Think*: test del tronco, acción primaria, textos, plantilla de páginas, celular y cómo probarlo |

## Qué está hecho y qué no

**Hecho** (aplicado y publicado por API el 21/10/2026)
- Título y descripción de `/procedimientos`, `/contacto` y `/tenes-dudas`
- `noindex` + título nuevo en `/agregue-una-resena`
- `noindex` en la política de privacidad

**No se puede hacer desde acá, y por qué**
- **La ficha de Google:** pertenece a otra cuenta de Google y el token de Wix
  está vencido. Hay que recuperar el acceso a mano. Nadie más puede.
- **El diseño del sitio:** es un sitio hecho con el Editor de Wix, que no tiene
  API para mover ni estilar elementos. El botón de WhatsApp, el encabezado, el
  formulario y el menú se hacen en el editor visual.
- **Ver el sitio:** la política de red de este entorno bloquea el dominio, así
  que no vi el diseño. Por eso `05` especifica estructura y textos, y **no
  inventa colores ni tipografías**: la regla es reutilizar los tokens que el
  sitio ya tiene.
