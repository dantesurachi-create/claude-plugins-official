# Las fichas de Google Business Profile

**Esta es la pieza que más importa.** Para "cardiólogo en Caseros" o "dermatólogo en Caseros",
el bloque del mapa se lleva la mayoría de los clics, y ese bloque se alimenta exclusivamente de
las fichas. Un sitio perfecto con fichas mediocres pierde contra fichas excelentes sin sitio.

Se administra desde [business.google.com](https://business.google.com).

---

## La jugada principal: tres fichas, no una

Casi todos los centros médicos con varios profesionales cometen el mismo error: crean una sola
ficha para la clínica, con categoría "Centro médico", y desde ahí intentan aparecer en todas
las búsquedas de especialidad.

No funciona, porque la **categoría principal** es el factor de relevancia más fuerte de una
ficha, y "Centro médico" no es "Cardiólogo" ni "Dermatólogo". Cuando alguien busca "dermatólogo
caseros", Google prefiere mostrar fichas cuya categoría principal sea exactamente esa.

Las políticas de Google contemplan este caso: en un consultorio con **más de un profesional**,
además de la ficha del establecimiento se permite **una ficha por profesional** en la misma
dirección. Es lo que Google llama *practitioner listings*, y es el escenario exacto de Soluciones
Médicas.

```
Ficha 1 — Soluciones Médicas                    categoría: Centro médico
Ficha 2 — Dr. Hernán Surachi - Cardiólogo       categoría: Cardiólogo
Ficha 3 — Dr. Dante Surachi - Dermatólogo       categoría: Dermatólogo
```

Tres fichas, una dirección, tres categorías distintas. Para "cardiólogo caseros" compite la
ficha del cardiólogo con la categoría exacta; para "dermatólogo caseros", la del dermatólogo;
y para "centro médico caseros" o "médico cerca", la de la clínica. **Tres tiros al local pack
desde la misma puerta**, en lugar de uno solo mal apuntado.

### Las reglas que hay que respetar

Esto se hace bien o no se hace: una ficha de profesional mal armada puede terminar suspendida
o fusionada con la de la clínica, y se pierde el trabajo.

- **Una sola ficha por profesional y por dirección.** Dos fichas del mismo médico en el mismo
  lugar es duplicado, y Google las fusiona o las suspende.
- **El nombre de la ficha es el nombre real de la persona**, con la especialidad si así figura
  en la cartelería. `Dr. Hernán Surachi - Cardiólogo` está bien;
  `Cardiólogo Caseros Riesgo Quirúrgico Electrocardiograma` no.
- **El profesional tiene que ser contactable en esa dirección.** Es el caso.
- **Cada ficha con su propia categoría específica.** Nunca dos fichas con la misma categoría
  principal en la misma dirección: eso sí es duplicación.
- **Las reseñas no se transfieren entre fichas.** Cada una junta las suyas. Es el costo de la
  estrategia y hay que planificarlo: cada profesional pide reseñas para su propia ficha.
- **El teléfono puede ser el mismo** en las tres. La dirección debe ser idéntica, carácter por
  carácter.
- **El sitio web de cada ficha apunta a su rama**, no todas a la home:
  la de la clínica a `/`, la del cardiólogo a `/cardiologia`, la del dermatólogo a
  `/dermatologia`. Esto refuerza la correspondencia entre ficha y página.

> **Antes de crear nada:** buscá en Google `"Soluciones Medicas" Caseros`, `"Dante Surachi"`,
> `"Hernán Surachi"` y la dirección entre comillas. Es habitual que ya existan fichas viejas
> creadas por terceros o generadas automáticamente, con teléfonos desactualizados. Cada
> duplicado divide la autoridad y manda pacientes a un número que no atiende. Reclamalos y
> unificalos antes de empezar.

---

## Ficha 1 — Soluciones Médicas

**Nombre:** `Soluciones Médicas`
**Categoría principal:** `Centro médico`
**Categorías secundarias:** `Clínica médica` · `Consultorio médico`
**Sitio web:** `https://www.solucionesmedicas.com.ar`

**Descripción** (750 caracteres máximo):
```
Centro médico en Caseros, Tres de Febrero, con consultorios de dermatología y cardiología en
Dr. Amadeo Sabattini 4720.

Atendemos consultas dermatológicas —control de lunares con dermatoscopía, acné, manchas,
psoriasis y afecciones de la piel— y consultas cardiológicas, con electrocardiograma con informe
en el momento y evaluación de riesgo quirúrgico para cirugías programadas.

Atendemos a pacientes de Caseros, Santos Lugares, Ciudadela, El Palomar, Sáenz Peña, Villa
Bosch, Martín Coronado y alrededores.

Turnos por WhatsApp o teléfono al {{TELEFONO}}. {{HORARIOS}}.
Obras sociales: {{OBRAS_SOCIALES}}.
```

---

## Ficha 2 — Cardiología

**Nombre:** `Dr. Hernán Surachi - Cardiólogo`
**Categoría principal:** `Cardiólogo`
**Categorías secundarias:** `Médico`
**Sitio web:** `https://www.solucionesmedicas.com.ar/cardiologia`

**Descripción:**
```
Consultorio de cardiología en Caseros, Tres de Febrero. Dr. Hernán Surachi,
{{ESPECIALIDAD_CARDIO}}, {{MATRICULA_CARDIO}}, atiende consultas cardiológicas, controles de
presión arterial, colesterol y arritmias.

En el consultorio realizamos electrocardiograma con informe en el momento y evaluación de riesgo
quirúrgico para cirugías programadas, con entrega del apto en el día cuando el caso lo permite.

Atendemos en Soluciones Médicas, Dr. Amadeo Sabattini 4720, Caseros. Pacientes de Caseros,
Santos Lugares, Ciudadela, El Palomar, Sáenz Peña, Villa Bosch y Martín Coronado.

Turnos al {{TELEFONO}}. {{HORARIOS}}. Obras sociales: {{OBRAS_SOCIALES}}.
```

**Servicios a cargar:**

| Servicio | Descripción |
|---|---|
| Consulta cardiológica | Evaluación clínica completa, control de factores de riesgo cardiovascular, seguimiento de hipertensión, colesterol y arritmias. |
| Electrocardiograma (ECG) | Electrocardiograma de 12 derivaciones realizado en el consultorio, con informe médico en el momento. Indoloro, dura alrededor de 10 minutos y no requiere ayuno. |
| Riesgo quirúrgico cardiológico | Evaluación prequirúrgica para cirugías programadas: consulta, electrocardiograma e informe de apto. En muchos casos se entrega el mismo día. |
| Apto médico prequirúrgico | Certificado de aptitud cardiológica para cirugías programadas y procedimientos odontológicos o estéticos. |
| Control de presión arterial | Diagnóstico y seguimiento de hipertensión arterial, ajuste de medicación y pautas de control domiciliario. |
| Chequeo cardiológico preventivo | Evaluación de riesgo cardiovascular en personas sin síntomas, con examen clínico y electrocardiograma. |
| Apto físico deportivo | Evaluación cardiológica para la práctica de actividad física y deporte recreativo. |

**Preguntas y respuestas a publicar:**

**P: ¿Hacen electrocardiograma en el consultorio?**
R: Sí. Realizamos electrocardiograma de 12 derivaciones y entregamos el informe en el momento.
No hace falta ayuno ni preparación previa.

**P: ¿Cuánto tarda el apto de riesgo quirúrgico?**
R: En la mayoría de los casos la evaluación se resuelve en una sola consulta y el apto se entrega
el mismo día. Si el caso requiere estudios complementarios, se te indica en esa misma consulta.

**P: ¿Qué tengo que llevar a la consulta de riesgo quirúrgico?**
R: El pedido del cirujano, los estudios cardiológicos previos, la lista de la medicación que
tomás con las dosis, el DNI y el carnet de la obra social.

**P: ¿Dónde queda el consultorio?**
R: En Soluciones Médicas, Dr. Amadeo Sabattini 4720, Caseros, Tres de Febrero.
{{REFERENCIA_UBICACION}}

---

## Ficha 3 — Dermatología

**Nombre:** `Dr. Dante Surachi - Dermatólogo`
**Categoría principal:** `Dermatólogo`
**Categorías secundarias:** `Médico`
**Sitio web:** `https://www.solucionesmedicas.com.ar/dermatologia`

**Descripción:**
```
Consultorio de dermatología en Caseros, Tres de Febrero. Dr. Dante Surachi,
{{ESPECIALIDAD_DERMA}}, {{MATRICULA_DERMA}}, atiende afecciones de la piel, el pelo y las uñas.

Control de lunares con dermatoscopía, tratamiento del acné en adolescentes y adultos, manchas,
dermatitis, psoriasis, caída del pelo y verrugas. Realizamos criocirugía, biopsia de piel y
extirpación de lesiones en el consultorio.

Atendemos en Soluciones Médicas, Dr. Amadeo Sabattini 4720, Caseros. Pacientes de Caseros,
Santos Lugares, Ciudadela, El Palomar, Sáenz Peña, Villa Bosch y Martín Coronado.

Turnos al {{TELEFONO}}. {{HORARIOS}}. Obras sociales: {{OBRAS_SOCIALES}}.
```

**Servicios a cargar:**

| Servicio | Descripción |
|---|---|
| Control de lunares | Examen completo de la piel con dermatoscopía para detectar lesiones sospechosas a tiempo. No duele y no requiere preparación. |
| Dermatoscopía | Examen de lunares con dermatoscopio, que permite ver estructuras no visibles a simple vista. |
| Tratamiento del acné | Acné adolescente y adulto, acné severo y tratamiento de las marcas que deja. |
| Consulta dermatológica | Diagnóstico y tratamiento de afecciones de la piel, el pelo y las uñas. |
| Criocirugía | Tratamiento con frío de verrugas, queratosis y lesiones superficiales, en el consultorio. |
| Biopsia de piel | Toma de muestra para análisis con anestesia local, cuando el diagnóstico lo requiere. |
| Extirpación de lesiones | Extracción quirúrgica de lunares y lesiones de piel con estudio posterior. |
| Tratamiento de manchas | Melasma, manchas solares y alteraciones de la pigmentación. |
| Psoriasis y dermatitis | Diagnóstico, tratamiento y seguimiento a largo plazo. |
| Caída del pelo | Estudio y tratamiento de la alopecia y la caída difusa. |
| Dermatología pediátrica | Afecciones de la piel en chicos. |

**Preguntas y respuestas a publicar:**

**P: ¿Cada cuánto conviene controlarse los lunares?**
R: Una vez al año alcanza para la mayoría de las personas. Con más frecuencia si tenés piel muy
clara, muchos lunares, antecedentes familiares de cáncer de piel o quemaduras solares en la
infancia.

**P: ¿La dermatoscopía duele?**
R: No. El dermatoscopio se apoya sobre la piel y solo mira con aumento y luz polarizada. No corta,
no pincha y no emite radiación.

**P: ¿Tratan acné en adultos?**
R: Sí. El acné del adulto es más frecuente de lo que se cree, sobre todo en mujeres, y tiene
tratamiento específico.

**P: ¿Tengo que ir sin maquillaje?**
R: Para una consulta de piel de la cara, sí. Y si la consulta es por las uñas, vení sin esmalte:
una uña pintada no se puede evaluar.

**P: ¿Dónde queda el consultorio?**
R: En Soluciones Médicas, Dr. Amadeo Sabattini 4720, Caseros, Tres de Febrero.
{{REFERENCIA_UBICACION}}

---

## Lo que va igual en las tres fichas

### Atributos
Accesible para sillas de ruedas · Se requiere turno · Acepta pacientes nuevos · Baño ·
Estacionamiento en la calle · Wi-Fi · Atiende obras sociales · Consultas online (si hacen
telemedicina)

### Horarios
Cargá `{{HORARIOS}}` con precisión, incluyendo el corte del mediodía si lo hay. **Y cargá los
feriados:** Google marca con un cartel amarillo las fichas con horario no confirmado en feriados,
y eso baja la confianza.

### Zona de servicio
```
Caseros · Santos Lugares · Ciudadela · El Palomar · Sáenz Peña · Villa Bosch
Martín Coronado · Churruca · José Ingenieros · Pablo Podestá · Loma Hermosa
Villa Raffo · Ramos Mejía · Haedo · Villa Devoto
```

### Fotos
Mínimo 15 por ficha, idealmente 25. **Nada de banco de imágenes:** se nota, y no genera la
confianza que genera ver el lugar real.

| Tipo | Cuántas | Qué mostrar |
|---|---|---|
| Fachada | 3 | La entrada desde la vereda con el número 4720 visible. Reduce las llamadas de "no lo encuentro". |
| Interior | 5 | Sala de espera, recepción, pasillo |
| Consultorio | 4 | Escritorio, camilla, y el equipamiento de cada especialidad |
| Equipamiento | 3 | Electrocardiógrafo y tensiómetro en la ficha de cardiología; dermatoscopio y equipo de criocirugía en la de dermatología |
| Retrato | 3 | Cada profesional con guardapolvo, buena luz, mirando a cámara |
| Logo y portada | 2 | Logo cuadrado y portada horizontal |

Las fichas de cada profesional llevan **sus propias fotos**, no las mismas. Comparten la fachada
y la sala de espera; el consultorio y el equipamiento son distintos.

Subí 2 o 3 fotos nuevas por mes: la actividad reciente es señal de que la ficha está viva.

### Publicaciones
Una por semana y por ficha, de 150 a 300 palabras, con foto y botón de acción.

**Cardiología — 12 semanas:**
1. Qué incluye la evaluación de riesgo quirúrgico y cuánto tarda
2. Electrocardiograma: en qué consiste y por qué no duele
3. Presión arterial: valores normales y cada cuánto controlarse
4. Qué llevar a la primera consulta cardiológica
5. Señales de alarma cardiovascular
6. Diferencia entre electrocardiograma, Holter y ergometría
7. Colesterol: qué significa cada valor
8. A partir de qué edad conviene el chequeo cardiológico
9. Apto físico para gimnasio y deporte
10. Cómo medirse la presión en casa
11. Arritmias: cuáles requieren consulta
12. Actividad física después de los 50

**Dermatología — 12 semanas** (arrancar en octubre, para llegar posicionados al pico de verano):
1. La regla del ABCDE para revisarte los lunares
2. Cada cuánto hay que controlarse los lunares
3. Protector solar: cuál, cuánto y cada cuánto
4. Cómo es un control de lunares, paso a paso
5. Acné: por qué no es un problema de higiene
6. Manchas en la cara: por qué aparecen
7. Qué es la dermatoscopía
8. Mitos sobre sacarse un lunar
9. Cuidado de la piel de los chicos en verano
10. Acné del adulto: por qué aparece después de los 25
11. Caída del pelo: cuándo preocuparse
12. Noviembre: campaña de prevención del cáncer de piel

Cada post cierra con el botón **"Llamar ahora"** o **"Reservar"** apuntando al WhatsApp.

---

## Checklist por ficha

- [ ] Ficha verificada
- [ ] Nombre sin palabras clave agregadas artificialmente
- [ ] Categoría principal correcta y **distinta** a la de las otras dos fichas
- [ ] Descripción cargada
- [ ] Servicios cargados con descripción
- [ ] Horarios cargados, incluidos feriados
- [ ] 15 fotos reales como mínimo, propias de esa ficha
- [ ] Preguntas frecuentes publicadas y respondidas
- [ ] Sitio web apuntando a la página que corresponde, no siempre a la home
- [ ] Botón de WhatsApp o teléfono configurado
- [ ] Zona de servicio con las localidades vecinas
- [ ] Mensajería activada y con respuesta en menos de 24 h
