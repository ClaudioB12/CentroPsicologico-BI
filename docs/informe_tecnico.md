# Informe tecnico del proyecto CentroPsicologico-BI

## Resumen ejecutivo

El repositorio implementa un pipeline BI local para un centro psicologico. La ruta real observada en codigo es:

`MySQL OLTP -> Debezium MySQL Connector -> Kafka -> JDBC Sink Connector -> PostgreSQL raw -> dbt staging -> dbt datamart -> consumo BI documentado por exposures`.

El proyecto contiene infraestructura Docker, DDL MySQL, configuraciones Kafka Connect/Debezium, un proyecto dbt con capas `staging` y `marts`, diagramas Mermaid y un checklist de evidencia. No se encontro un archivo Power BI real (`.pbix`, `.pbit`, `.pbip`, `.bim`, `.dax`) dentro del repositorio.

## Inventario del repositorio

| Area | Archivos/carpetas encontrados | Uso observado |
|---|---|---|
| Docker general | `docker-compose.yml` | Stack completo: MySQL, PostgreSQL, Zookeeper, Kafka, Kafka Connect, connector-init, dbt, Kafka UI y pgAdmin |
| Docker separado | `docker-compose.oltp.yml`, `docker-compose.postgres.yml`, `docker-compose.pipeline.yml`, `docker-compose.dbt.yml` | Variante modular del despliegue |
| MySQL OLTP | `init.sql`, `mysql/init.sql`, `OLTP_Centro_Psicologico.sql`, `modelo_oltp.mwb` | DDL y datos de muestra; el compose principal monta `init.sql` |
| Debezium/Kafka | `connectors/mysql-source.json`, `connectors/postgres-sink.json`, `kafka-connect/Dockerfile`, `scripts/register-connectors.sh` | CDC MySQL y sink JDBC a PostgreSQL |
| PostgreSQL | `init-postgres.sql`, `postgres/init-postgres.sql` | Inicializacion de base destino |
| dbt | `dbt/dbt_project.yml`, `dbt/profiles.yml`, `dbt/models/staging/*.sql`, `dbt/models/marts/*.sql`, `dbt/models/marts/*.yml` | Transformacion raw -> staging -> datamart |
| Artefactos dbt | `dbt/target/run_results.json`, `dbt/target/manifest.json`, `dbt/logs/dbt.log` | Evidencia parcial de ejecucion dbt |
| Documentacion | `README.md`, `docs/` | Instrucciones, diagramas y checklist de evidencia |
| Power BI | No encontrado | No hay modelo, medidas DAX ni dashboard versionado en el repo |

## Arquitectura implementada

El pipeline principal esta definido en `docker-compose.yml`:

- `db`: MySQL 8.0 con binlog ROW habilitado.
- `postgres`: PostgreSQL 15 como destino raw y datamart.
- `zookeeper` y `kafka`: infraestructura Kafka Confluent 7.5.0.
- `kafka-connect`: worker Kafka Connect con Debezium MySQL y JDBC Sink.
- `connector-init`: registra los conectores JSON.
- `dbt`: ejecuta `dbt run` despues de esperar el snapshot inicial.
- `kafka-ui`: monitoreo visual de topics y conectores.
- `pgadmin`: administracion visual de PostgreSQL.

Ver el diagrama detallado en [Arquitectura CDC y BI](diagrams/arquitectura.md).

## Esquema OLTP real

El DDL usado por el `docker-compose.yml` principal es `init.sql`. Crea la base `dm_centro_psicologico` y las siguientes tablas:

| Tabla | PK | FKs | Columnas principales |
|---|---|---|---|
| `sedes` | `sede_id` | - | `nombre_sede`, `ciudad`, `tiene_online`, `estado` |
| `psicologos` | `psicologo_id` | `sede_id -> sedes.sede_id` | `dni`, `nombres`, `especialidad`, `cpp`, `modalidad`, `estado` |
| `pacientes` | `paciente_id` | `sede_id -> sedes.sede_id` | `nombres`, apellidos, documento, nacimiento, sexo, contacto, captacion, estado, modalidad |
| `historia_clinica` | `historia_id` | `paciente_id -> pacientes.paciente_id` | `codigo_historia`, `tipo_historial`, `fecha_apertura`, `estado_historia` |
| `sesiones` | `sesion_id` | `historia_id -> historia_clinica.historia_id`, `psicologo_id -> psicologos.psicologo_id` | `fecha_sesion`, `hora_sesion`, `nro_sesion`, etapa, modalidad, duracion, estado |
| `evaluacion_psicologica` | `evaluacion_id` | `sesion_id -> sesiones.sesion_id` | metodos, resultados, `puntaje_cdi`, `puntaje_stai`, `fecha_evaluacion` |
| `diagnosticos` | `diagnostico_id` | `sesion_id -> sesiones.sesion_id` | `codigo_cie10`, `descripcion_cie10`, diagnostico clinico |
| `plan_intervencion` | `plan_id` | `sesion_id -> sesiones.sesion_id` | objetivos, intervenciones, recomendaciones, fechas, estado |
| `pagos` | `pago_id` | `sesion_id -> sesiones.sesion_id` | `fecha_pago`, `monto`, `comprobante`, `metodo_pago`, `estado_pago` |

Tambien existe `OLTP_Centro_Psicologico.sql`, con un esquema anterior de 4 tablas `oltp_*`. Ese archivo no coincide con el DDL montado por el compose principal.

## Ingesta CDC

### Conector origen MySQL

Archivo: `connectors/mysql-source.json`.

- Nombre: `mysql-source-connector`.
- Clase: `io.debezium.connector.mysql.MySqlConnector`.
- Host origen: `db:3306`.
- Base incluida: `dm_centro_psicologico`.
- Prefijo de topics: `centro`.
- Topic de historial: `dbhistory.dm_centro_psicologico`.
- Snapshot: `initial`.

Los topics de datos se derivan con el patron:

`centro.dm_centro_psicologico.<tabla>`.

### Conector destino PostgreSQL

Archivo: `connectors/postgres-sink.json`.

- Nombre: `postgres-sink-connector`.
- Clase: `io.confluent.connect.jdbc.JdbcSinkConnector`.
- Destino: `jdbc:postgresql://postgres:5432/dm_centro_psicologico`.
- Topics consumidos: `centro\.dm_centro_psicologico\..*`.
- Escritura: `upsert`.
- PK: `record_key`.
- Transformaciones: `ExtractNewRecordState` y `RegexRouter`.
- Formato de tabla: `raw.${topic}` despues de enrutar el nombre del topic a solo `<tabla>`.

Resultado esperado: tablas replicadas en el schema `raw` de PostgreSQL.

## Modelos dbt

El proyecto dbt principal esta en `dbt/`.

Configuracion:

- Proyecto: `centro_psicologico`.
- Staging materializa como tabla en schema `staging`.
- Marts materializa como tabla en schema `datamart`.
- Fuentes declaradas en `dbt/models/sources.yml` apuntan al schema `raw`.

### Staging

| Modelo | Fuente raw | Transformaciones observadas |
|---|---|---|
| `stg_sedes` | `raw.sedes` | Convierte `tiene_online` a booleano |
| `stg_psicologos` | `raw.psicologos` | Seleccion directa de columnas |
| `stg_pacientes` | `raw.pacientes` | Convierte fechas desde entero Debezium con `DATE '1970-01-01' + campo` |
| `stg_historia_clinica` | `raw.historia_clinica` | Convierte `fecha_apertura` |
| `stg_sesiones` | `raw.sesiones` | Convierte `fecha_sesion`, aplica `coalesce(duracion_min, 0)` |
| `stg_evaluaciones` | `raw.evaluacion_psicologica` | `coalesce` para puntajes CDI/STAI y convierte `fecha_evaluacion` |
| `stg_diagnosticos` | `raw.diagnosticos` | Filtra `codigo_cie10 is not null` |
| `stg_planes` | `raw.plan_intervencion` | Convierte fechas de inicio y fin |
| `stg_pagos` | `raw.pagos` | Convierte `fecha_pago` y aplica `coalesce(monto, 0.00)` |

### Marts

| Modelo | Tipo | Fuentes/joins | Columnas calculadas relevantes |
|---|---|---|---|
| `dim_paciente` | Dimension | `stg_pacientes` left join `stg_historia_clinica` por `paciente_id` | `rango_etario`, `ocupacion_grupo`, `canal_captacion`, `fecha_primera_consulta` |
| `dim_psicologo` | Dimension | `stg_psicologos` | Sin calculos complejos |
| `dim_sede` | Dimension | `stg_sedes` | Sin calculos complejos |
| `dim_servicio` | Dimension | `stg_sesiones` left join `stg_historia_clinica` por `historia_id` | `duracion_estandar`, `precio_base`, `descripcion` |
| `dim_tiempo` | Dimension | `stg_sesiones` | anio, semestre, trimestre, mes, semana, dia, fin de semana |
| `dim_diagnostico` | Dimension | `stg_diagnosticos` | Distintos `codigo_cie10` y `descripcion_cie10` |
| `fact_sesion` | Hecho | `stg_sesiones` left join historias y psicologos | flags `realizada`, `cancelada`, `noshow`, `primera_sesion` |
| `fact_facturacion` | Hecho | `stg_pagos` left join sesiones, historias y psicologos | `monto_cobrado`, filtro `estado_pago = 'PAGADO'` |
| `fact_evaluacion` | Hecho | `stg_evaluaciones` left join sesiones e historias | `nivel_depresion`, `nivel_ansiedad` |
| `time_spine_day` | Auxiliar MetricFlow | `generate_series` | Fechas diarias 2020-01-01 a 2030-12-31 |

Ver el ER en [Modelo dimensional](diagrams/modelo_dimensional.md).

## Capa semantica y exposiciones

El repo incluye:

- `dbt/models/marts/semantic_models.yml`: modelos semanticos para `fact_sesion`, `fact_facturacion` y `fact_evaluacion`.
- `dbt/models/marts/metrics.yml`: metricas operacionales, financieras, clinicas y de pacientes.
- `dbt/models/marts/exposures.yml`: consumidores BI documentados:
  - `dashboard_operacional`
  - `dashboard_financiero`
  - `dashboard_clinico`
  - `reporte_pacientes`

Estos archivos documentan consumo analitico, pero no reemplazan un archivo Power BI real.

## Estado de ejecucion dbt encontrado

El artefacto `dbt/target/run_results.json` registra una ejecucion `dbt run` exitosa:

- Total de modelos: 18.
- Resultado final registrado: `PASS=18 WARN=0 ERROR=0 SKIP=0`.
- Fecha del artefacto: `2026-05-26T12:55:30Z`.

Tambien hay errores historicos en `dbt/logs/dbt.log` de intentos previos, principalmente por casteos de fecha/booleanos, pero el ultimo `run_results.json` disponible corresponde a una ejecucion correcta de `dbt run`.

No se encontro evidencia de `dbt test` ni definiciones de tests en una carpeta `tests`.

## Power BI

No se encontro ningun archivo versionado de Power BI:

- `.pbix`
- `.pbit`
- `.pbip`
- `.bim`
- `.dax`

Por tanto, no se pueden validar relaciones Power BI, medidas DAX, paginas del dashboard, segmentadores, drill-down ni drill-through desde el codigo del repositorio. Esos elementos quedan como evidencia pendiente.

## Hallazgos e inconsistencias

| Hallazgo | Impacto | Evidencia |
|---|---|---|
| Conviven dos esquemas OLTP: `init.sql` sin prefijo y `OLTP_Centro_Psicologico.sql` con `oltp_*` | Puede confundir diagramas, capturas y consultas de validacion | `docker-compose.yml` monta `init.sql`; README referencia `oltp_*` |
| README documenta nombres `DIM_*` y `FACT_*` en mayusculas | dbt realmente crea `dim_*` y `fact_*` en minusculas | `dbt/models/marts/*.sql` |
| README menciona dos hechos, pero dbt tiene tres | Falta reflejar `fact_evaluacion` en documentacion previa | `fact_evaluacion.sql` |
| `dim_diagnostico` no tiene relacion directa con facts | El ER no puede conectar diagnosticos a hechos sin inventar FK | `dim_diagnostico.sql`, `fact_*.sql` |
| No existe Power BI versionado | No se pueden auditar DAX ni modelo visual desde el repo | Busqueda de archivos Power BI sin resultados |
| No hay `dbt test` documentado | Falta evidencia formal de calidad de datos | No hay resultado ni tests encontrados |

## Evidencia requerida

La lista completa de capturas pendientes esta en [Evidencia pendiente](EVIDENCIA_PENDIENTE.md). Las mas importantes para cerrar el informe son:

- Conectores `mysql-source-connector` y `postgres-sink-connector` en estado `RUNNING`.
- Kafka UI mostrando topics `centro.dm_centro_psicologico.<tabla>`.
- PostgreSQL mostrando `raw.*` y `datamart.*`.
- Resultado actualizado de `dbt run` o `dbt build`.
- Resultado de `dbt test`, si se agregan tests.
- Vista de relaciones y medidas DAX en Power BI, cuando exista el archivo/modelo.
- Capturas de paginas reales del dashboard: operacional, financiero, clinico y pacientes.

## Comandos utiles

Levantar el stack completo:

```powershell
docker compose up -d --build
```

Ver contenedores:

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Ver conectores:

```powershell
Invoke-RestMethod "http://localhost:8083/connectors?expand=status" | ConvertTo-Json -Depth 5
```

Ver tablas raw:

```powershell
docker exec centro_psicologico_postgres psql -U postgres -d dm_centro_psicologico -c "\dt raw.*"
```

Ver tablas datamart:

```powershell
docker exec centro_psicologico_postgres psql -U postgres -d dm_centro_psicologico -c "\dt datamart.*"
```

Ejecutar dbt:

```powershell
docker compose run --rm dbt
```

## Conclusion

El repositorio contiene una base solida de pipeline BI local con CDC y dbt. La parte mas fuerte y verificable esta en infraestructura, conectores y modelos SQL. Los pendientes principales estan en evidencia visual, pruebas dbt y versionamiento del modelo Power BI.
