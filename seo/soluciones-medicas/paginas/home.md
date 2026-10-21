# Home — Soluciones Médicas

> **URL:** `https://www.solucionesmedicas.com.ar/`
> **Búsqueda objetivo:** soluciones médicas caseros (marca) · centro médico caseros · médico cerca de mí caseros
> **Schema:** `schema/clinica-medicalclinic.json`

La home **no** tiene que intentar rankear para "dermatólogo" ni para "cardiólogo": para eso están
`/dermatologia` y `/cardiologia`. Su trabajo es otro, y es igual de importante:

1. Que quien busca la marca por su nombre encuentre dirección, horario y teléfono en dos segundos
2. Repartir a cada visitante hacia la especialidad que le corresponde, rápido
3. Concentrar la autoridad del sitio y pasársela a las dos ramas por enlace interno

---

## Etiquetas para el `<head>`

**Title** (48 caracteres):
```
Soluciones Médicas | Centro Médico en Caseros
```

**Meta description** (152 caracteres):
```
Centro médico en Caseros, Tres de Febrero. Dermatología y cardiología en Dr. Amadeo Sabattini 4720. Turnos por WhatsApp al {{TELEFONO}}.
```

> Sacá `| Dermatologo | Cardiologo |` del título actual. Esas dos palabras tienen que vivir en
> las páginas de cada especialidad, donde una página entera las respalda. En la home no aportan
> y compiten contra las páginas que sí deberían ganar.

---

## Contenido de la página

### H1
```
Soluciones Médicas — Centro médico en Caseros
```

### Bajada
```
Dermatología y cardiología en Caseros, Tres de Febrero.
Dr. Amadeo Sabattini 4720 · {{HORARIOS}}
```

**[ Pedir turno por WhatsApp ]**   **[ Llamar al {{TELEFONO}} ]**

> Los dos botones arriba de todo, visibles sin hacer scroll, clickeables desde el celular. La
> mayoría de estas búsquedas se hacen desde el teléfono y la mitad de la gente quiere una sola
> cosa: un turno. Si tiene que buscar el teléfono, se va.

### H2 — Las dos especialidades

Dos bloques grandes, uno al lado del otro, cada uno con foto. Son el elemento principal de la
página.

```
DERMATOLOGÍA
Dr. Dante Surachi — {{MATRICULA_DERMA}}
Control de lunares con dermatoscopía, acné, manchas, dermatitis, psoriasis, caída del pelo
y verrugas.
→ Dermatología en Caseros

CARDIOLOGÍA
Dr. Hernán Surachi — {{MATRICULA_CARDIO}}
Consulta cardiológica, electrocardiograma con informe en el momento y evaluación de riesgo
quirúrgico.
→ Cardiología en Caseros
```

> **El texto del enlace importa mucho.** "Dermatología en Caseros" le dice a Google de qué trata
> la página destino; "ver más" o "leé acá" no le dice nada. Esos dos enlaces son la principal vía
> por la que la autoridad de la home llega a las páginas que tienen que rankear.

### H2 — Estudios y procedimientos en el consultorio

```
Dermatoscopía · Criocirugía · Biopsia de piel · Extirpación de lesiones
Electrocardiograma · Evaluación de riesgo quirúrgico · Apto físico deportivo
```

Cada uno enlazado a la página que corresponde, cuando exista.

### H2 — Dónde estamos

```
Dr. Amadeo Sabattini 4720
Caseros, Tres de Febrero, Buenos Aires
{{REFERENCIA_UBICACION}}

{{HORARIOS}}
Tel: {{TELEFONO}} · WhatsApp: {{WHATSAPP}}

[ Cómo llegar ]
```

Mapa de Google embebido, y abajo un párrafo corto con referencias reales del barrio: la estación,
las avenidas cercanas, dónde estacionar. Ese párrafo le da a Google señales geográficas concretas
y a los pacientes les resuelve un problema real.

### H2 — Obras sociales

```
Atendemos {{OBRAS_SOCIALES}}, y también pacientes particulares.
Al pedir el turno conviene confirmar la cobertura, porque los planes cambian.
```

### H2 — Los profesionales

Foto, nombre, especialidad y matrícula de cada uno, con enlace a `/nosotros` y a la página de
su especialidad.

> Esto no es decoración. Google evalúa el contenido de salud con criterios más estrictos de
> experiencia, pericia, autoridad y confianza, y un sitio médico donde no se sabe quién atiende
> compite en desventaja frente a uno donde sí. Nombre, matrícula y formación visibles son un
> factor de posicionamiento además de lo obvio: es lo que un paciente mira antes de decidir.

### H2 — Zona de atención

```
Atendemos a pacientes de Caseros, Santos Lugares, Ciudadela, El Palomar, Sáenz Peña,
Villa Bosch, Martín Coronado, Churruca, José Ingenieros y toda la zona de Tres de Febrero.
```

### Pie de página (idéntico en todas las páginas del sitio)

```
Soluciones Médicas
Dr. Amadeo Sabattini 4720, Caseros, Tres de Febrero, Buenos Aires
Tel: {{TELEFONO}} · WhatsApp: {{WHATSAPP}} · {{EMAIL}}
{{HORARIOS}}

Dermatología: Dr. Dante Surachi, {{MATRICULA_DERMA}}
Cardiología: Dr. Hernán Surachi, {{MATRICULA_CARDIO}}

La información de este sitio tiene fines orientativos y no reemplaza la consulta médica.
```

> Escrito **exactamente igual** que en las tres fichas de Google y en Doctoralia, tilde por tilde.
