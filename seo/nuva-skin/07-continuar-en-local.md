# Continuar en local

Este trabajo empezó en una sesión de Claude Code **en la nube**, que tiene dos
límites que ya nos frenaron:

| Límite | Consecuencia |
|---|---|
| La política de red del contenedor bloquea **todo** el tráfico saliente | No se puede abrir `esteticanuvaskin.com`. Probado también con `wix.com` y `example.com`: 403 en el CONNECT del proxy |
| Claude in Chrome no está disponible en la sesión | No se puede manejar el Chrome del dueño ni, por lo tanto, trabajar dentro del Editor de Wix |

Corriendo en local los dos desaparecen: red abierta y control del Chrome con
las sesiones del dueño ya abiertas.

---

## Lo que NO se pierde al cambiar

Los cambios ya aplicados **están vivos en los servicios reales**, no en un
sandbox. El contenedor es efímero; los cambios no.

| Cambio | Dónde |
|---|---|
| Títulos y descripciones de 5 páginas | Wix, publicado |
| `noindex` en `/agregue-una-resena` y la política de privacidad | Wix, publicado |
| Teléfono del negocio → `+5491136385709` | Propiedades del sitio en Wix (v154) |
| Palabras clave objetivo en 4 páginas | Wix |
| Teléfono de la ficha de Google → `+54 9 11 3638-5709` | Hecho por el dueño, verificado |

Y toda la documentación está en esta rama, pusheada.

---

## Cómo arrancar la sesión local

### 1. Instalar Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

Hay otras formas de instalarlo (incluido un instalador nativo) en
https://code.claude.com/docs — si el `npm` da problemas, mirá ahí.

### 2. Traer el repo y la rama

```bash
git clone https://github.com/dantesurachi-create/claude-plugins-official.git
cd claude-plugins-official
git checkout claude/google-seo-cardiology-caseros-rm7lq1
```

Todo el material está en `seo/nuva-skin/`.

### 3. Conectar lo que hace falta

| Qué | Para qué | Nota |
|---|---|---|
| **Conector de Wix** | Leer y escribir el sitio | Es el que hizo todos los cambios de arriba. Hay que vincular la cuenta de Wix de Nuva Skin |
| **Claude in Chrome** | Trabajar en el Editor de Wix y ver el sitio | La extensión de Chrome. Tiene que estar corriendo y conectada |
| OpenSEO *(opcional)* | Leer la ficha de Google | Cuenta `esteticanuvaskin@gmail.com`, quedaban ~495 créditos. Proyecto: `8d660573-5005-415f-be06-994429c6ea36` |

### 4. Abrir Claude Code y pegarle esto

```
Leé seo/nuva-skin/README.md y seo/nuva-skin/07-continuar-en-local.md.

Venimos de una sesión en la nube que no podía abrir el sitio ni usar Chrome.
Ahora sí. Lo que falta hacer, en orden:

1. Abrir https://www.esteticanuvaskin.com/ en Chrome y mirar el diseño:
   paleta, tipografías, dónde están los botones, cómo se ve en celular.
   Después completá la parte visual de seo/nuva-skin/05-ux-dont-make-me-think.md,
   que hoy sólo tiene estructura y textos porque no se pudo ver el diseño.

2. Verificar si existe el botón de WhatsApp y dónde está. El dato: 3 clics
   para contactar en 57 días con 61 visitantes únicos.

3. En el Editor de Wix, agregar el botón flotante de WhatsApp en todas las
   páginas, con este link:
   https://wa.me/5491136385709?text=Hola,%20quiero%20consultar%20por%20un%20turno%20en%20Nuva%20Skin

4. Pegar el contenido de seo/nuva-skin/06-contenido-para-pegar.md en
   /procedimientos (hoy tiene 191 caracteres), /contacto (hoy está vacía) y
   /tenes-dudas (hoy tiene 1.900 caracteres en un solo bloque).

5. Probar la reserva online de punta a punta desde un celular: 6 servicios
   habilitados, 0 reservas en la historia del sitio.

No rehagas los títulos de las 24 páginas de tratamiento: ya están bien.
No apliques las sugerencias de SEO con IA de Wix: son peores que lo que hay.
```

---

## Lo que la sesión local tiene que verificar primero

Cosas que yo afirmé **sin poder comprobarlas**, y que con Chrome se comprueban
en dos minutos:

- [ ] ¿Existe el botón de WhatsApp en el sitio? ¿Dónde?
- [ ] ¿El teléfono del encabezado es un link `tel:` o una imagen?
- [ ] ¿Cómo se ve todo en celular?
- [ ] ¿La dirección es tocable y abre Maps?
- [ ] ¿Cuántos pasos tiene la reserva online? ¿Pide pago anticipado? ¿Pide crear cuenta?
- [ ] ¿Qué paleta y tipografías usa el sitio? *(hace falta para que lo nuevo no desentone)*
- [ ] ¿Los links `/estrias` y `/depilaciondefinitiva` funcionan sin tilde, o hay que usar las URLs con tilde?

---

## Lo que sigue pendiente del dueño

| Pendiente | Por qué lo necesito |
|---|---|
| **Matrícula del Dr. Surachi** | Va en cada página de tratamiento. En contenido médico no es opcional |
| **Decisión de precios** | Hay tres opciones redactadas en `06`. El silencio es la peor de las cuatro |
| ¿El fijo se atiende? | Si no, conviene sacarlo de la ficha en lugar de dejarlo como secundario |

---

## Lo que queda pendiente en la ficha de Google

El teléfono ya está corregido. Falta (detalle en `02`):

- [ ] Cargar los 16 servicios — hoy: **ninguno**
- [ ] Descripción completa — hoy: **32 caracteres de 750**
- [ ] Fotos hasta 15 — hoy: **6**
- [ ] 7 preguntas y respuestas — hoy: **ninguna**
- [ ] Atributos — hoy: **ninguno**
- [ ] Link `wa.me` como link de turnos — hoy: **ninguno**
- [ ] Responder las 36 reseñas existentes (4,7 ★)
- [ ] Decidir el horario del sábado — hoy cerrado, y es el día de más demanda
- [ ] Reconectar Google Business Profile en Wix (el token está vencido: `invalid_grant`)

> **Ojo con esto:** la ficha pertenece a una cuenta de Google **distinta** de
> la vinculada al sitio (`OWNED_ELSEWHERE`). Quien tenga esa cuenta controla la
> ficha y las 36 reseñas. Vale la pena resolver la propiedad aunque la ficha ya
> se pueda editar.

---

## El estado del negocio, en una tabla

Para que la sesión local no tenga que releer todo:

| Dato | Valor |
|---|---|
| Consultas nuevas 2023 → 2026 | 146/año → 10 en 10 meses (**−92 %**) |
| Visitas al sitio | 1,4 por día |
| Clics desde Google (90 días) | 198, de los cuales **41 % son búsquedas del nombre del doctor** |
| Conversión del sitio | 11 % de los visitantes únicos contacta — **el sitio no está roto** |
| Contactos en el CRM | 351, el 90 % de 2022–2024 · sólo 21 con teléfono · 0 con consentimiento de marketing |
| Reservas online en la historia | **0**, con 6 servicios habilitados |
| Ficha de Google | 4,7 ★ · 36 reseñas (33 de cinco) · sin servicios, sin Q&A, 6 fotos |

**El diagnóstico en una línea:** el sitio convierte bien, pero no llega nadie.
El problema es de visibilidad y de canal, no de conversión.
