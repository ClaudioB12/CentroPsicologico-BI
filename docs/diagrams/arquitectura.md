# Arquitectura CDC y BI

```mermaid
flowchart LR
  subgraph OLTP["OLTP / MySQL 8.0"]
    MYSQL[(dm_centro_psicologico)]
    T_SEDES[sedes]
    T_PSICOLOGOS[psicologos]
    T_PACIENTES[pacientes]
    T_HISTORIA[historia_clinica]
    T_SESIONES[sesiones]
    T_EVALUACIONES[evaluacion_psicologica]
    T_DIAGNOSTICOS[diagnosticos]
    T_PLANES[plan_intervencion]
    T_PAGOS[pagos]
    MYSQL --> T_SEDES
    MYSQL --> T_PSICOLOGOS
    MYSQL --> T_PACIENTES
    MYSQL --> T_HISTORIA
    MYSQL --> T_SESIONES
    MYSQL --> T_EVALUACIONES
    MYSQL --> T_DIAGNOSTICOS
    MYSQL --> T_PLANES
    MYSQL --> T_PAGOS
  end

  subgraph CDC["Ingesta CDC / Kafka Connect"]
    DBZ[mysql-source-connector<br/>io.debezium.connector.mysql.MySqlConnector]
    KAFKA[(Kafka<br/>confluentinc/cp-kafka:7.5.0)]
    TOPICS[Topics<br/>centro.dm_centro_psicologico.*<br/>dbhistory.dm_centro_psicologico]
    SINK[postgres-sink-connector<br/>io.confluent.connect.jdbc.JdbcSinkConnector]
  end

  subgraph DW["Data Warehouse / PostgreSQL 15"]
    RAW[(schema raw)]
    STAGING[(schema staging<br/>dbt models/staging)]
    DATAMART[(schema datamart<br/>dbt models/marts)]
    RAW_TABLES[raw.sedes, raw.psicologos, raw.pacientes,<br/>raw.historia_clinica, raw.sesiones,<br/>raw.evaluacion_psicologica, raw.diagnosticos,<br/>raw.plan_intervencion, raw.pagos]
    STG_TABLES[stg_sedes, stg_psicologos, stg_pacientes,<br/>stg_historia_clinica, stg_sesiones,<br/>stg_evaluaciones, stg_diagnosticos,<br/>stg_planes, stg_pagos]
    MART_TABLES[dim_sede, dim_psicologo, dim_paciente,<br/>dim_diagnostico, dim_tiempo, dim_servicio,<br/>fact_sesion, fact_facturacion, fact_evaluacion]
    RAW --> RAW_TABLES
    STAGING --> STG_TABLES
    DATAMART --> MART_TABLES
  end

  subgraph BI["BI / Consumo"]
    EXP[dbt exposures<br/>dashboard_operacional<br/>dashboard_financiero<br/>dashboard_clinico<br/>reporte_pacientes]
    PBI[Power BI<br/>archivo .pbix/.pbit no encontrado]
  end

  MYSQL -->|binlog ROW + Debezium MySQL connector| DBZ
  DBZ -->|Kafka Connect produce con topic.prefix=centro| KAFKA
  KAFKA -->|topics: centro.dm_centro_psicologico.<tabla>| TOPICS
  TOPICS -->|Kafka Connect JDBC Sink + RegexRouter| SINK
  SINK -->|auto.create/auto.evolve upsert hacia PostgreSQL| RAW
  RAW_TABLES -->|dbt source('raw', ...)| STAGING
  STG_TABLES -->|dbt ref() y joins SQL| DATAMART
  MART_TABLES -->|dbt exposures.yml documenta consumo| EXP
  EXP -.->|modelo Power BI no existe en el repo| PBI
```

## Notas de revision

- El pipeline Docker principal (`docker-compose.yml`) monta `./init.sql` en MySQL; ese DDL crea tablas `sedes`, `psicologos`, `pacientes`, `historia_clinica`, `sesiones`, `evaluacion_psicologica`, `diagnosticos`, `plan_intervencion` y `pagos`.
- Existe `OLTP_Centro_Psicologico.sql` con un esquema anterior `oltp_*` de 4 tablas. No parece ser el DDL cargado por el `docker-compose.yml` principal.
- El README mezcla referencias a tablas `oltp_*`, `DIM_*` y `FACT_*`, pero los modelos dbt reales materializan en minusculas: `dim_*` y `fact_*`, con una tercera tabla de hechos `fact_evaluacion`.
- No se encontro archivo Power BI (`.pbix`, `.pbit`, `.pbip`, `.bim`, `.dax`) ni documentacion real de relaciones/medidas DAX. Solo hay `dbt/models/marts/exposures.yml`, `metrics.yml` y `semantic_models.yml`.
- Los topics individuales no estan enumerados en el JSON; se infieren mecanicamente de `topic.prefix=centro`, `database.include.list=dm_centro_psicologico` y el patron del sink `centro\.dm_centro_psicologico\..*`.
