# Odontograma veterinario — especificación del esquema Triadan

Componente propio de DentaPet Care. El relevamiento de herramientas ([§4](herramientas-open-source.md)) encontró que **no existe un odontograma veterinario open source**: todos los disponibles usan numeración FDI humana de 32 piezas. Este documento especifica el modelo que reemplaza esa ausencia.

La parte de base de datos está implementada y probada (`db/migrations/0004_odontograma.sql`, `db/migrations/0012_seed_catalogos.sql`). Falta el componente visual.

---

## 1. Sistema Triadan modificado

Cada pieza se identifica con un número de tres dígitos: **cuadrante + posición**.

**Cuadrantes**

| | Derecho | Izquierdo |
|---|---|---|
| Maxilar (permanente) | 1 | 2 |
| Mandibular (permanente) | 4 | 3 |
| Maxilar (deciduo) | 5 | 6 |
| Mandibular (deciduo) | 8 | 7 |

**Posición dentro del cuadrante**

| Posición | Tipo |
|---|---|
| 01, 02, 03 | Incisivos |
| 04 | Canino |
| 05, 06, 07, 08 | Premolares |
| 09, 10, 11 | Molares |

**Reglas mnemotécnicas:** el canino es siempre `04`, el primer molar es siempre `09`. Las dos están verificadas con aserciones en la migración de seed: si alguien toca el bloque de generación y rompe la numeración, la migración falla en vez de sembrar una arcada mal.

---

## 2. Fórmulas dentarias sembradas

Un hemiarcada (lado derecho); el izquierdo es simétrico.

| Especie | Dentición | Arcada | Piezas | Triadan |
|---|---|---|---|---|
| Perro | Permanente | Maxilar | 10 | 101–110 |
| Perro | Permanente | Mandibular | 11 | 401–411 |
| Perro | Deciduo | Maxilar | 7 | 501–504, 506–508 |
| Perro | Deciduo | Mandibular | 7 | 801–804, 806–808 |
| Gato | Permanente | Maxilar | 8 | 101–104, 106–109 |
| Gato | Permanente | Mandibular | 7 | 401–404, 407–409 |
| Gato | Deciduo | Maxilar | 7 | 501–504, 506–508 |
| Gato | Deciduo | Mandibular | 6 | 801–804, 807–808 |

**Totales: perro 42 permanentes + 28 deciduos. Gato 30 permanentes + 26 deciduos. 126 filas en el catálogo.**

Las ausencias no son arbitrarias y son la razón por la que una grilla FDI no sirve:

- El **gato** carece del primer premolar maxilar (`105`/`205`) y del primero y segundo mandibulares (`305`/`306`, `405`/`406`).
- El **perro** tiene tres molares mandibulares (`311`), el gato solo uno.
- Ninguna de las dos especies tiene **molares deciduos**, y el primer premolar deciduo (`505`) no existe.

Cargar piezas que el paciente no tiene haría que la interfaz dibuje dientes inexistentes, y peor: permitiría registrar una extracción de una pieza imposible. El trigger de validación lo impide, y el test lo comprueba con el caso "extracción de la 311 en un gato".

---

## 3. Modelo de almacenamiento

**Relacional, una fila por hallazgo, más un snapshot congelado al firmar.**

```
evaluacion (1) ──── (0..1) odontograma ──── (N) odontograma_hallazgo
                                                    │
                                    pieza_dental ────┤
                                   hallazgo_tipo ────┘
```

Las dos mitades cumplen requisitos distintos:

- **Filas** porque el producto vive del seguimiento longitudinal. Hay que poder preguntar *"todas las piezas 108 con reabsorción en gatos de más de 10 años"*. Contra un blob `jsonb` eso no se consulta.
- **Snapshot** porque un odontograma firmado es un documento clínico y no puede mutar cuando mañana cambie el catálogo de hallazgos.

> Esto refina lo que el relevamiento planteó como "JSON versionado": el requisito real era que fuera consultable y no una imagen. Filas + snapshot cumple las dos cosas.

### Contrato del snapshot

Se materializa solo al firmar, dentro del trigger:

```json
{
  "version_esquema": 1,
  "especie": "perro",
  "fecha": "2026-07-31T14:05:00Z",
  "profesional_id": "…",
  "firmado_por": "…",
  "firmado_at": "2026-07-31T14:22:11Z",
  "hallazgos": [
    {
      "triadan": 108,
      "pieza": "Premolar 4 superior derecho",
      "codigo": "PD",
      "hallazgo": "Enfermedad periodontal",
      "ambito": "pieza",
      "escala": "estadio_0_4",
      "superficies": ["vestibular"],
      "valor_numerico": 2,
      "valor_texto": null,
      "nota": null
    }
  ]
}
```

Una vez firmado, el odontograma es inmutable: cualquier `UPDATE` posterior y cualquier alta de hallazgo se rechazan. Corregir implica una evaluación nueva, que es como funciona una historia clínica.

---

## 4. Validaciones que impone la base

Ninguna de estas se puede expresar con un `CHECK` porque cruzan tablas; todas viven en triggers, y todas tienen test:

| Validación | Ejemplo rechazado |
|---|---|
| La pieza pertenece a la especie del paciente | Pieza felina en odontograma canino |
| La especie del odontograma coincide con la de la mascota | Odontograma felino sobre un perro |
| Superficie palatina solo en maxilar, lingual solo en mandíbula | `palatina` sobre la 309 |
| El valor respeta la escala del hallazgo | Estadio periodontal 7 (la escala es 0–4) |
| Un hallazgo de pieza exige pieza; uno de boca la prohíbe | `PD` sin pieza; halitosis sobre una pieza |
| Hallazgos exclusivos de especie | Gingivoestomatitis felina en un perro |
| Solo un veterinario **de esa clínica** firma | Firma de la asistente o de un colega de otra clínica |
| El odontograma firmado es inmutable | Reabrir a borrador; agregar hallazgos |

---

## 5. Catálogo de hallazgos

37 entradas en `hallazgo_tipo`, agrupadas en periodonto, reabsorción, fracturas, desarrollo, hallazgos de boca y procedimientos.

La tabla tiene **dos columnas de código** a propósito:

- `codigo` — código estable del proyecto. Es el que viaja en la API y en el snapshot.
- `codigo_avdc` — abreviatura oficial del American Veterinary Dental College **cuando existe y es conocida**. Queda `null` cuando el código es propio.

Separarlos evita el error de inventar siglas y presentarlas como estándar. Están marcadas como AVDC solo las que se usan de forma estable: `PD`, `TR`, `GH`, `GR`, `EF`, `UCF`, `CCF`, `UCRF`, `CCRF`, `RF`, `AB`, `AT`, `CA`, `RD`, `SN`, `ONF`, `OM`, `X`, `XS`. Todo lo demás (`GING`, `SOND`, `FUR`, `MOV`, `CALC`, `PLACA`, `DISC`, `ED`, `ROT`, `AUS_C`, `AUS_X`, `HAL`, `MAL`, `FCGS`, `ULC`, `RAD`, `PULI`, `TR_TIPO`) es código del proyecto.

**Antes del primer paciente:** validar la lista completa con la odontóloga del piloto contra el catálogo AVDC vigente. Cambiar el vocabulario con datos ya cargados obliga a migrar historia clínica, y es de las pocas decisiones de este esquema que se vuelven caras rápido.

### Escalas

| Escala | Rango | Usada en |
|---|---|---|
| `presencia` | sin valor | fracturas, ausencias, procedimientos |
| `grado_0_3` | 0–3 | gingivitis, cálculo, placa, movilidad, furcación, halitosis |
| `estadio_0_4` | 0–4 | enfermedad periodontal |
| `estadio_1_5` | 1–5 | reabsorción dentaria |
| `tipo_1_3` | 1–3 | tipo de reabsorción |
| `milimetros` | ≥ 0 | sondaje, recesión gingival |
| `texto` | descriptivo | maloclusión, masa oral |

---

## 6. Lo que falta: el componente visual

La base está lista. El trabajo pendiente, estimado en 2–3 semanas:

1. **Dos SVG de arcada** — canina y felina, con `data-triadan` en cada pieza y geometría separada de la lógica. La arquitectura de estado se puede tomar de [`ZoliQua/React-Odontogram-Modul`](https://github.com/ZoliQua/React-Odontogram-Modul) (cómo modela pieza → superficie → hallazgo → notas), que es lo caro de diseñar; la geometría FDI se descarta entera.
2. **Selector de superficies** por pieza, respetando palatina/lingual según arcada.
3. **Vista de lectura** — la vista `v_odontograma_piezas` ya devuelve la arcada completa incluyendo las piezas sanas, porque la interfaz necesita dibujar toda la boca y no solo lo marcado. Para un perro devuelve 70 filas (42 + 28).
4. **Comparación entre odontogramas** de dos fechas: es la funcionalidad que convierte el registro en seguimiento longitudinal, y es lo que ningún PIMS del mercado hace bien.
5. **Modo tablet** — la carga real ocurre con el paciente sobre la mesa. Objetivo: marcar una pieza en un toque, sin submenús.

**Validar la nomenclatura con la odontóloga antes de escribir la primera línea de interfaz.** Ese es el orden correcto, y el trabajo de base de datos ya está hecho para soportar cualquier vocabulario que ella defina: cambiar el catálogo de hallazgos es un `insert`, no una migración.
