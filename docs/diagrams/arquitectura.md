# Arquitectura CDC y BI

## Pipeline completo: MySQL → Kafka → PostgreSQL → dbt → BI

```mermaid
flowchart TD
  subgraph OLTP["① MySQL 8.0 — dm_centro_psicologico (db:3306)"]
    direction LR
    T1["sedes · psicologos · pacientes"]
    T2["historia_clinica · sesiones"]
    T3["evaluacion_psicologica · diagnosticos\nplan_intervencion · pagos"]
  end

  subgraph CDC["② Ingesta CDC — Kafka Connect (kafka-connect:8083)"]
    DBZ["mysql-source-connector\nDebezium MySqlConnector\nhost: db:3306 | snapshot: initial"]
    KAFKA[("Kafka 7.5.0 — kafka:9092\ntopics: centro.dm_centro_psicologico.*\ndbhistory.dm_centro_psicologico")]
    SINK["postgres-sink-connector\nJDBC Sink + RegexRouter\nupsert por record_key → schema raw"]
    DBZ -->|"topic.prefix = centro"| KAFKA
    KAFKA -->|"consume + RegexRouter"| SINK
  end

  subgraph DW["③ Data Warehouse — PostgreSQL 15 (postgres:5432)"]
    RAW[("schema: raw\n9 tablas replicadas\nauto.create + auto.evolve")]
    STAGING[("schema: staging\n9 modelos stg_*\ndbt materializa como tabla")]
    DATAMART[("schema: datamart\n6 dims + 3 facts\ndbt materializa como tabla")]
    RAW -->|"dbt source('raw', ...)"| STAGING
    STAGING -->|"dbt ref() + SQL joins"| DATAMART
  end

  subgraph BI["④ Consumo BI"]
    direction LR
    EXP["dbt exposures\ndashboard_operacional · dashboard_financiero\ndashboard_clinico · reporte_pacientes"]
    PBI["Power BI\n(archivo .pbix pendiente)"]
    EXP -.->|"modelo pendiente"| PBI
  end

  OLTP    -->|"binlog ROW + Debezium capture"| DBZ
  SINK    -->|"upsert a PostgreSQL"| RAW
  DATAMART -->|"dbt exposures.yml"| EXP
```

---

## Infraestructura Docker

Todos los servicios corren en la red `cdc_network` definida en `docker-compose.yml`.

```mermaid
flowchart TD
  subgraph COMPOSE["docker-compose.yml — cdc_network (bridge)"]
    DB["db\nMySQL 8.0\n:3306\nbinlog ROW habilitado"]

    subgraph KAFKA_CLUSTER["Cluster Kafka (Confluent 7.5.0)"]
      direction LR
      ZK["zookeeper\n:2181"]
      KF["kafka\n:9092"]
      ZK -->|coordinacion| KF
    end

    subgraph CONNECT["Kafka Connect"]
      KC["kafka-connect\n:8083\nDebezium MySQL 2.4.2\nJDBC Sink 10.9.3\nPG JDBC 42.7.4"]
      CI["connector-init\nregistra conectores via\nREST POST /connectors"]
      CI -->|"POST /connectors"| KC
    end

    PG["postgres\nPostgreSQL 15\n:5432"]
    DBT_SVC["dbt\ndbt run\nstaging + datamart"]

    subgraph MONITOREO["Interfaces Web"]
      direction LR
      KUI["kafka-ui\n:8080"]
      PGADMIN["pgadmin\n:5050"]
    end
  end

  DB          -->|"binlog ROW"| KC
  KF          <-->|"broker"| KC
  KC          -->|"JDBC Sink upsert"| PG
  PG          -->|"lee schema raw.*"| DBT_SVC
  DBT_SVC     -->|"escribe staging.* y datamart.*"| PG
  KUI         -.->|"monitorea topics"| KF
  KUI         -.->|"monitorea conectores"| KC
  PGADMIN     -.->|"administra"| PG
```

---

## Notas de revision

- El compose principal monta `./init.sql` en MySQL; ese DDL crea las 9 tablas del sistema OLTP.
- Los topics individuales se infieren de `topic.prefix=centro`, `database.include.list=dm_centro_psicologico` y el patron del sink `centro\.dm_centro_psicologico\..*`.
- No se encontro archivo Power BI (`.pbix`, `.pbit`, `.pbip`). Solo existen `exposures.yml`, `metrics.yml` y `semantic_models.yml`.
- El servicio `connector-init` ejecuta `scripts/register-connectors.sh` para registrar los dos conectores JSON al inicio del stack.
