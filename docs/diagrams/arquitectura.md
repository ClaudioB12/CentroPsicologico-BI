# Arquitectura CDC y BI

## Pipeline completo: MySQL → Kafka → PostgreSQL → dbt → BI

```mermaid
flowchart LR
  subgraph OLTP["MySQL 8.0 — dm_centro_psicologico (db:3306)"]
    MYSQL[(dm_centro_psicologico)]
    T_SEDES[sedes]
    T_PSICOLOGOS[psicologos]
    T_PACIENTES[pacientes]
    T_HISTORIA[historia_clinica]
    T_SESIONES[sesiones]
    T_EVAL[evaluacion_psicologica]
    T_DIAG[diagnosticos]
    T_PLANES[plan_intervencion]
    T_PAGOS[pagos]
    MYSQL --> T_SEDES & T_PSICOLOGOS & T_PACIENTES
    MYSQL --> T_HISTORIA & T_SESIONES
    MYSQL --> T_EVAL & T_DIAG & T_PLANES & T_PAGOS
  end

  subgraph CDC["Kafka Connect — kafka-connect:8083"]
    DBZ["mysql-source-connector\nDebezium MySqlConnector\nhost: db:3306 | snapshot: initial"]
    KAFKA[("Kafka 7.5.0 — kafka:9092\ntopics: centro.dm_centro_psicologico.*\ndbhistory.dm_centro_psicologico")]
    SINK["postgres-sink-connector\nJDBC Sink + RegexRouter\nupsert por record_key → schema raw"]
    DBZ -->|"topic.prefix=centro"| KAFKA
    KAFKA -->|"consume + RegexRouter"| SINK
  end

  subgraph DW["PostgreSQL 15 — dm_centro_psicologico (postgres:5432)"]
    RAW[("schema: raw\n9 tablas replicadas\nauto.create + auto.evolve")]
    STAGING[("schema: staging\n9 modelos stg_*\ndbt materializa como tabla")]
    DATAMART[("schema: datamart\n6 dims + 3 facts\ndbt materializa como tabla")]
    RAW -->|"dbt source('raw', ...)"| STAGING
    STAGING -->|"dbt ref() + SQL joins"| DATAMART
  end

  subgraph BI["Consumo BI"]
    EXP["dbt exposures\ndashboard_operacional\ndashboard_financiero\ndashboard_clinico\nreporte_pacientes"]
    PBI["Power BI\n(archivo .pbix pendiente)"]
    EXP -.->|"modelo pendiente"| PBI
  end

  OLTP -->|"binlog ROW + Debezium capture"| DBZ
  SINK -->|"upsert a PostgreSQL"| RAW
  DATAMART -->|"dbt exposures.yml"| EXP
```

---

## Infraestructura Docker

Todos los servicios corren en la red `cdc_network` definida en `docker-compose.yml`.

```mermaid
flowchart TB
  subgraph COMPOSE["docker-compose.yml — cdc_network (bridge)"]
    subgraph KAFKA_CLUSTER["Cluster Kafka (Confluent 7.5.0)"]
      ZK["zookeeper\n:2181"]
      KF["kafka\n:9092"]
      ZK -->|coordinacion| KF
    end

    subgraph CONNECT["Kafka Connect"]
      KC["kafka-connect\n:8083\nDebezium MySQL 2.4.2\nJDBC Sink 10.9.3\nPG JDBC 42.7.4"]
      CI["connector-init\nregistra conectores via\nREST POST /connectors"]
      CI -->|"POST /connectors"| KC
    end

    DB["db\nMySQL 8.0\n:3306\nbinlog ROW habilitado"]
    PG["postgres\nPostgreSQL 15\n:5432"]
    DBT_SVC["dbt\ndbt run\nestaging + datamart"]

    subgraph MONITOREO["Interfaces Web"]
      KUI["kafka-ui\n:8080"]
      PGADMIN["pgadmin\n:5050"]
    end
  end

  DB -->|"binlog ROW"| KC
  KF <-->|"broker"| KC
  KC -->|"JDBC Sink upsert"| PG
  PG -->|"lee schema raw.*"| DBT_SVC
  DBT_SVC -->|"escribe staging.* y datamart.*"| PG
  KUI -.->|"monitorea topics"| KF
  KUI -.->|"monitorea conectores"| KC
  PGADMIN -.->|"administra"| PG
```

---

## Notas de revision

- El compose principal (`docker-compose.yml`) monta `./init.sql` en MySQL; ese DDL crea las tablas `sedes`, `psicologos`, `pacientes`, `historia_clinica`, `sesiones`, `evaluacion_psicologica`, `diagnosticos`, `plan_intervencion` y `pagos`.
- Existe `OLTP_Centro_Psicologico.sql` con un esquema anterior `oltp_*` de 4 tablas que **no** es el DDL cargado por el `docker-compose.yml` principal.
- Los topics individuales no estan enumerados en el JSON del conector; se infieren de `topic.prefix=centro`, `database.include.list=dm_centro_psicologico` y el patron del sink `centro\.dm_centro_psicologico\..*`.
- No se encontro archivo Power BI (`.pbix`, `.pbit`, `.pbip`, `.bim`, `.dax`). Solo existen `exposures.yml`, `metrics.yml` y `semantic_models.yml` que documentan el consumo analitico esperado.
- El servicio `connector-init` ejecuta `scripts/register-connectors.sh` para registrar automaticamente los dos conectores JSON al inicio del stack.
