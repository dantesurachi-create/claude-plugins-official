# Datos estructurados (JSON-LD)

Los datos estructurados son un bloque de código invisible para el visitante que le explica a
Google, sin ambigüedad, qué es el consultorio: que es un médico, que la especialidad es
cardiología, dónde queda exactamente, qué horarios tiene y qué estudios realiza.

No garantizan una mejor posición por sí solos, pero sí habilitan los **resultados enriquecidos**
—las preguntas desplegables, el horario, la ubicación destacada— que ocupan más espacio en la
pantalla y se llevan más clics. En una búsqueda local, ocupar más pantalla que el competidor
de al lado es medio partido ganado.

## Qué va en cada página

| Página | Archivos a insertar |
|---|---|
| Home (`/`) | `physician-localbusiness.json` |
| `/riesgo-quirurgico-caseros` | `physician-localbusiness.json` + `faq-riesgo-quirurgico.json` |
| `/electrocardiograma-caseros` | `physician-localbusiness.json` + `faq-electrocardiograma.json` |

El bloque `physician-localbusiness.json` va en **todas** las páginas: repite la identidad del
consultorio en cada una y refuerza la señal geográfica.

## Cómo se inserta

Envolvé el contenido del archivo en una etiqueta `<script>` dentro del `<head>`:

```html
<script type="application/ld+json">
{ ...acá va todo el contenido del archivo .json... }
</script>
```

**En Wix:** Configuración → SEO → Herramientas avanzadas de SEO → elegí la página → pestaña
"Structured data markup" → agregá el bloque. También se puede poner desde Configuración →
Código personalizado, eligiendo "Head" y las páginas donde aplica.

**En WordPress:** con el plugin Yoast o Rank Math desde el editor de la página, o pegando el
`<script>` en el `header.php` del tema hijo.

**En un sitio a medida:** directamente en el `<head>` del HTML.

## Antes de publicar

1. **Reemplazá todos los `{{marcadores}}`.** Un JSON-LD con marcadores sin completar es peor que
   no tenerlo: Google registra datos falsos sobre el negocio.
2. **Validá cada página** con la [Prueba de resultados enriquecidos de Google](https://search.google.com/test/rich-results).
   Pegá la URL y revisá que no haya errores en rojo. Las advertencias amarillas sobre campos
   opcionales se pueden ignorar.
3. **Verificá la coherencia.** La dirección, el teléfono y los horarios del JSON-LD tienen que
   coincidir exactamente con los de la ficha de Google Business Profile y con los del pie de
   página. Una contradicción entre las tres fuentes anula el beneficio.

## Marcadores específicos de estos archivos

| Marcador | Dónde conseguirlo |
|---|---|
| `{{TELEFONO_SIN_ESPACIOS}}` | El teléfono en formato internacional sin espacios ni guiones. Para `011 4759-0000` va `1147590000`, y queda `+541147590000`. |
| `{{LAT}}` / `{{LNG}}` | Clic derecho sobre la puerta del consultorio en Google Maps: los números aparecen arriba de todo. |
| `{{CID_DE_LA_FICHA}}` | Buscá la ficha en Google Maps: el número largo después de `cid=` en la URL. Si no lo encontrás, borrá la línea `hasMap` entera. |
| `{{PERFIL_DOCTORALIA}}` | La parte final de la URL del perfil de Doctoralia. |

Si algún dato no existe todavía —por ejemplo, si no hay Instagram— **borrá esa línea completa**
en lugar de dejar el marcador. Un campo ausente no es un problema; un campo con basura sí.

> Cuidado con las comas al borrar líneas: si sacás el último elemento de una lista o de un
> objeto, la coma anterior sobra y el JSON deja de ser válido. Después de editar, pegá el
> resultado en [jsonlint.com](https://jsonlint.com) para confirmar que sigue estando bien
> formado antes de publicarlo.
