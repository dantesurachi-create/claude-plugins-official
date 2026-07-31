# DentaPet Care — documentación de diseño

Plataforma de prevención y seguimiento longitudinal de salud dental en perros y gatos: app para tutores, portal profesional, backoffice y landing, con suscripción paga.

| Documento | Contenido |
|---|---|
| [herramientas-open-source.md](herramientas-open-source.md) | Relevamiento de proyectos de GitHub reutilizables, clasificados como USAR / PARTIR DE / ESTUDIAR / EVITAR. Stack recomendado y orden de ataque. |
| [modelo-de-datos.md](modelo-de-datos.md) | Esquema PostgreSQL del MVP: decisiones de diseño, mapa de entidades, límites de rol y lo que todavía no cubre. |
| [odontograma-triadan.md](odontograma-triadan.md) | Especificación del odontograma veterinario: sistema Triadan, fórmulas dentarias, catálogo de hallazgos y el trabajo visual pendiente. |
| [db/](db/) | Migraciones SQL y suite de pruebas. 12 migraciones, 66 aserciones en verde sobre PostgreSQL 16. |

## Estado

- **Investigación de herramientas:** hecha.
- **Modelo de datos:** implementado y probado.
- **Odontograma:** base de datos lista; falta el componente SVG (2–3 semanas).
- **Aplicaciones:** no empezadas.

## Los tres límites clínicos que atraviesan todo

El brief los fija y el esquema los hace inviolables desde cualquier cliente:

1. **La plataforma no diagnostica.** El nivel de riesgo solo se escribe en una evaluación profesional; el cuestionario inicial no tiene columna de puntaje.
2. **Ningún estado clínico se asigna solo.** Fotografías, alertas y planes exigen un profesional de esa clínica para cambiar de estado, por trigger.
3. **Pertenecer a la clínica no es ser clínico.** Recepción y administración quedan fuera de las tablas clínicas por RLS, no por la interfaz.
