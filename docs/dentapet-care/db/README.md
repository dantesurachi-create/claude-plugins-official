# Esquema de base de datos — DentaPet Care

PostgreSQL 16, pensado para Supabase. Ver [`../modelo-de-datos.md`](../modelo-de-datos.md) para las decisiones de diseño y [`../odontograma-triadan.md`](../odontograma-triadan.md) para el odontograma.

```
db/
├── migrations/    12 archivos, se aplican en orden alfabético
└── tests/         suite de verificación, sin dependencias externas
```

## Correr localmente

Con un PostgreSQL 16 cualquiera:

```bash
createdb dentapet
for f in migrations/*.sql; do
  psql -d dentapet -v ON_ERROR_STOP=1 -f "$f" || break
done
psql -d dentapet -v ON_ERROR_STOP=1 -f tests/pruebas.sql
```

La suite reporta una línea por aserción y aborta en la primera que falle. Última corrida: **66 aserciones, todas en verde** sobre PostgreSQL 16.13.

No requiere pgTAP: los helpers (`pruebas.verificar`, `pruebas.debe_fallar`) son dos funciones plpgsql definidas en el propio archivo.

## Con Supabase CLI

Los archivos se pueden copiar tal cual a `supabase/migrations/` renombrándolos al formato de timestamp que usa el CLI (`20260731120000_base.sql`). Consideraciones:

- Los roles `anon`, `authenticated` y `service_role` ya existen en un proyecto Supabase; el bloque de `0001_base.sql` que los crea es idempotente y no hace nada ahí.
- `app.uid()` lee el JWT (`request.jwt.claims → sub`) y cae al GUC `app.usuario_actual` cuando no hay JWT. Funciona en los dos entornos sin cambios.
- Las extensiones (`pgcrypto`, `btree_gist`, `citext`) están disponibles en Supabase.
- Generar tipos TypeScript: `supabase gen types typescript --local > packages/db-types/index.ts`.

## Qué cubren las pruebas

| Sección | Verifica |
|---|---|
| 1 | Fórmulas dentarias: 42/28 perro, 30/26 gato, reglas del 4 y del 9, ausencias felinas |
| 2 | Coherencia del odontograma: especie, superficies, escalas, ámbito, inmutabilidad al firmar |
| 3 | Firma: la asistente no firma; un veterinario de otra clínica tampoco; plan activo sin firma se rechaza |
| 4 | Fotografías: nacen pendientes, no cambian de estado sin profesional de esa clínica |
| 5 | Adherencia sobre ocurrencias esperadas (0% sin registros, 57.1% con 4 de 7) y alerta automática por dolor |
| 6 | Turnos: sin sobreturnos, dentro de disponibilidad, cálculo de franjas libres |
| 7 | Procedimientos: piezas coherentes con la especie |
| 8 | RLS: aislamiento entre clínicas y los "no puede" del §3.4 |
| 9 | Política anti-fatiga: tope diario, franja horaria, excepción clínica |
| 10 | Auditoría: campos cambiados, versión anterior, dispositivo, sin ruido en updates vacíos |

## Convenciones

- Tablas en `public` (para que PostgREST las exponga), funciones auxiliares en `app` (no expuestas).
- Identificadores SQL en español sin tildes; comentarios y mensajes de error en español.
- Todo id es `uuid` generado en la base, salvo los catálogos (`smallint` identity) y `auditoria` (`bigint`).
- Toda tabla clínica lleva `clinica_id`: es la unidad de aislamiento.
- Las tablas de catálogo no se auditan: son inmutables en operación normal.
