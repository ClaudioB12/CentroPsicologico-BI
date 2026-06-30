# 15. Sustentacion Tecnica

## 15.1 Respuestas tecnicas del equipo

### Flujo del dato desde el OLTP hasta el dashboard

```
MySQL 8.0 (sesiones, pagos, pacientes...) 
  → binlog ROW capturado por Debezium 2.4.2
  → eventos publicados en Kafka 7.5.0 (topics: centro.dm_centro_psicologico.*)
  → JDBC Sink escribe en PostgreSQL 15 schema raw (upsert por record_key)
  → dbt transforma: raw → staging (9 stg_* + 1 int_) → datamart (6 dims + 3 facts)
  → Power BI Desktop Import Mode: consulta schema datamart, construye modelo semantico
  → Dashboard interactivo con 13 KPIs y 3 tableros
```

### Transformaciones principales aplicadas

1. Conversion de `estado_sesion` (texto) a tres flags booleanos numericos: `flag_realizada`, `flag_cancelada`, `flag_noshow` via CASE WHEN en `stg_sesiones.sql`
2. Conversion de fechas enteras Debezium → DATE: `DATE '1970-01-01' + dias` en `stg_pacientes.sql`
3. COALESCE de `monto` a 0.0 en `stg_pagos.sql` para evitar NULL en sumas financieras
4. Clasificacion dinamica de `rango_etario` en `stg_pacientes.sql` via CASE WHEN sobre `fecha_nacimiento`
5. Generacion analitica de `dim_tiempo` con macro dbt — vector de 1,096 fechas sin dependencia del OLTP
6. INNER JOIN de `int_sesiones_facturadas` (ephemeral) para aislar transacciones huerfanas antes de materializar hechos

### Por que se eligio el Modelo Constelacion

El Modelo Constelacion (tres tablas de hechos compartiendo dimensiones conformadas) se eligio porque:

- Los procesos de negocio **son independientes pero comparten entidades**: un psicologo aparece en sesiones, en facturacion y en evaluaciones
- Permite **analisis cruzado** entre los tres procesos sin duplicar datos dimensionales
- Habilita los **comparativos obligatorios** usando `DIM_Tiempo` compartida por las tres facts
- `FACT_Evaluacion` es una **factless fact table** — su valor no es un monto sino un evento diagnostico, lo que justifica separarla de `FACT_Sesion`

### Como se valido que los KPIs son correctos

1. Consultas SQL directas sobre el schema `datamart` calculando cada KPI con la formula de negocio definida
2. Comparacion de resultados SQL vs. medidas DAX en Power BI (conciliacion exacta — S/ 8,030 en ambos)
3. Verificacion de unicidad de llaves primarias via `dbt test`
4. Validacion de rangos: `puntaje_cdi` en [0-54], `monto_cobrado` > 0, `estado_pago IN ('PAGADO', 'PENDIENTE')`

### Problema tecnico presentado y solucion

**Problema:** Las fechas en el schema `raw` llegaban como enteros Unix (dias desde 1970-01-01) porque Debezium serializa los tipos DATE de MySQL como enteros en el mensaje Kafka JDBC.

**Solucion:** En `stg_pacientes.sql` y otros modelos staging se aplica la conversion `DATE '1970-01-01' + INTERVAL (fecha_campo || ' days')` para obtener el tipo DATE correcto en PostgreSQL.

### Limitaciones de la solucion actual

- Power BI requiere que el stack Docker este corriendo para actualizar datos (no hay modo Online Service configurado)
- `DIM_DIAGNOSTICO` no tiene FK en `FACT_SESION` — el diagnostico CIE-10 solo es accesible via `FACT_EVALUACION`
- Los KPIs 8 (Tiempo de Espera) y 9 (NPS) no son calculables con el esquema OLTP actual (Fase 2)
- No hay politica de SCD (Slowly Changing Dimensions) implementada — si un psicologo cambia de sede, el historico no se preserva

### Mejoras para la siguiente version

- Implementar dbt tests de unicidad y not_null en todos los modelos
- Agregar `fecha_solicitud_cita` al OLTP para habilitar el KPI 8
- Configurar Power BI Service con gateway para acceso online sin Docker corriendo
- Implementar SCD Tipo 2 en `DIM_PACIENTE` para conservar el historico de `estado_paciente`
- Agregar tabla `encuestas_satisfaccion` para habilitar el KPI NPS

## 15.2 Estructura de la presentacion PPT

| Slide | Contenido |
|---|---|
| 1 | Titulo: "Sistema BI Centro Psicologico Integral Guevara" · Equipo · Links GitHub/MkDocs |
| 2 | Problema de negocio: 4 problemas criticos + usuarios + impacto esperado |
| 3 | KPIs principales (13 KPIs) y preguntas de negocio (4 preguntas criticas) |
| 4 | Arquitectura BI end-to-end: diagrama de 4 capas |
| 5 | Fuente OLTP (9 tablas), ingesta CDC (Debezium+Kafka) y capas raw/staging/marts |
| 6 | Modelo dimensional Constelacion: 3 hechos + 6 dimensiones + grano de cada fact |
| 7 | Modelo semantico Power BI: relaciones, jerarquias y medidas DAX principales |
| 8 | Dashboard: capturas de los 3 tableros + comparativos YoY y MoM obligatorios |
| 9 | Validacion SQL vs Power BI: tabla de conciliacion + trazabilidad fuente→KPI |
| 10 | Hallazgos, decision recomendada (campana reenganche) y mejoras futuras |
| 11 | Aportes individuales del equipo |

## 15.3 Preguntas del docente — respuestas preparadas

| # | Pregunta | Respuesta sintetica |
|---|---|---|
| 1 | ¿Como se conecta el problema de negocio con los KPIs? | El 18% de citas no realizadas → KPI 6 Tasa Cancelacion/NoShow. La imposibilidad de medir productividad → KPI 3 Sesiones por Psicologo. La ausencia de margenes → KPI 1 Margen Bruto. El abandono terapeutico → KPI 4. |
| 2 | ¿Que parte del repositorio demuestra la construccion del pipeline? | `connectors/` (configuracion Debezium/Kafka), `dbt/models/staging/` (transformaciones), `dbt/models/marts/` (modelo dimensional), `dbt/target/run_results.json` (evidencia de ejecucion PASS=20) |
| 3 | ¿Como se valida que el dashboard muestra resultados correctos? | Conciliacion SQL vs DAX: `SELECT SUM(monto_cobrado) FROM datamart.fact_facturacion WHERE estado_pago='PAGADO'` da S/ 8,030 — mismo valor que la medida [Monto Total Cobrado] en Power BI |
| 4 | ¿Por que el modelo dimensional soporta los analisis presentados? | El Modelo Constelacion permite cruzar sesiones con facturacion y evaluaciones usando las mismas dimensiones conformadas (DIM_Tiempo, DIM_Paciente, DIM_Psicologo), habilitando todos los KPIs cross-process |
| 5 | ¿Que diferencia hay entre la fuente OLTP, el DataMart y el modelo semantico? | OLTP: datos operacionales normalizados para escritura rapida. DataMart: datos desnormalizados optimizados para consulta analitica (modelo estrella). Modelo semantico: capa de negocio en Power BI con KPIs, jerarquias y relaciones para el usuario final |
| 6 | ¿Que hallazgo justifica la decision recomendada? | La Tasa de Abandono Terapeutico detectada en FACT_Sesion via `flag_realizada = 0` y `dim_paciente.estado_paciente = 'ABANDONO'` revela pacientes que abandonaron sin cierre clinico formal — justifica la campana de reenganche |
| 7 | ¿Que componente construyo o valido cada integrante? | Claudio: pipeline CDC + Docker + dbt staging. Josue: modelo dimensional + dbt marts + MkDocs. Joel: modelo semantico Power BI + medidas DAX + dashboards. Wilbert: validacion SQL vs Power BI + evidencias + conciliacion KPIs |
