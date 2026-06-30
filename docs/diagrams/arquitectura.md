# Arquitectura CDC y BI

## Pipeline completo: MySQL → Kafka → PostgreSQL → dbt → BI

```mermaid
flowchart TD
  subgraph CAPA1["① Fuente OLTP — MySQL 8.0  puerto 3306"]
    T1["sesiones · pagos · evaluacion_psicologica"]
    T2["pacientes · psicologos · sedes"]
    T3["historia_clinica · diagnosticos · plan_intervencion"]
  end

  subgraph CAPA2["② Ingesta CDC — Debezium + Apache Kafka"]
    DBZ["mysql-source-connector\nDebezium MySqlConnector 2.4.2\nhost: db:3306  |  snapshot: initial"]
    KAFKA[("Kafka 7.5.0  puerto 9092\ntopics: centro.dm_centro_psicologico.*")]
    SINK["postgres-sink-connector\nJDBC Sink 10.9.3 + RegexRouter\nupsert por record_key → schema raw"]
    DBZ -->|"topic.prefix=centro"| KAFKA
    KAFKA -->|"consume + RegexRouter"| SINK
  end

  subgraph CAPA3["③ Data Warehouse — PostgreSQL 15  puerto 5432"]
    RAW[("schema: raw\n9 tablas replicadas\nauto.create + auto.evolve")]
    STAGING[("schema: staging\n9 modelos stg_* + 1 int_ephemeral\ndbt materializa como tabla")]
    DATAMART[("schema: datamart\n6 dimensiones + 3 hechos\ndbt materializa como tabla")]
    RAW -->|"dbt source refs"| STAGING
    STAGING -->|"dbt ref() + SQL joins"| DATAMART
  end

  subgraph CAPA4["④ Business Intelligence — Power BI Desktop"]
    PBI["Power BI Import Mode\nconexion localhost:5432 → schema datamart\n13 KPIs  ·  3 tableros  ·  4 jerarquias"]
  end

  CAPA1    -->|"binlog ROW capturado por Debezium"| DBZ
  SINK     -->|"upsert a PostgreSQL schema raw"| RAW
  DATAMART -->|"conexion directa Import Mode"| PBI
```

---

## Infraestructura Docker

Todos los servicios corren en la red `cdc_network` definida en `docker-compose.yml`.

```mermaid
flowchart TD
  subgraph COMPOSE["docker-compose.yml — red cdc_network bridge"]
    DB["db\nMySQL 8.0  ·  puerto 3306\nbinlog ROW habilitado"]
    ZK["zookeeper\npuerto 2181"]
    KF["kafka\npuerto 9092"]
    KC["kafka-connect  ·  puerto 8083\nDebezium MySqlConnector 2.4.2\nJDBC Sink 10.9.3  ·  PG JDBC 42.7.4"]
    CI["connector-init\nregistra conectores al inicio\nvia REST POST /connectors"]
    PG["postgres\nPostgreSQL 15  ·  puerto 5432"]
    DBT_SVC["dbt\ndbt run\nestaging + datamart"]
    KUI["kafka-ui\npuerto 8080"]
    PGADMIN["pgadmin\npuerto 5050"]
  end

  ZK       -->|"coordinacion de cluster"| KF
  CI       -->|"POST /connectors"| KC
  DB       -->|"binlog ROW"| KC
  KF      <-->|"broker de mensajes"| KC
  KC       -->|"JDBC Sink upsert"| PG
  PG       -->|"lee schema raw.*"| DBT_SVC
  DBT_SVC  -->|"escribe staging.* y datamart.*"| PG
  KUI     -.->|"monitorea topics"| KF
  KUI     -.->|"monitorea conectores"| KC
  PGADMIN -.->|"administra bases de datos"| PG
```

---

## Notas de revision

- El compose principal (`docker-compose.yml`) monta `./init.sql` en MySQL; ese DDL crea las tablas `sedes`, `psicologos`, `pacientes`, `historia_clinica`, `sesiones`, `evaluacion_psicologica`, `diagnosticos`, `plan_intervencion` y `pagos`.
- Existe `OLTP_Centro_Psicologico.sql` con un esquema anterior `oltp_*` de 4 tablas que **no** es el DDL cargado por el `docker-compose.yml` principal.
- Los topics individuales no estan enumerados en el JSON del conector; se infieren de `topic.prefix=centro`, `database.include.list=dm_centro_psicologico` y el patron del sink `centro\.dm_centro_psicologico\..*`.
- No se encontro archivo Power BI (`.pbix`, `.pbit`, `.pbip`, `.bim`, `.dax`). Solo existen `exposures.yml`, `metrics.yml` y `semantic_models.yml` que documentan el consumo analitico esperado.
- El servicio `connector-init` ejecuta `scripts/register-connectors.sh` para registrar automaticamente los dos conectores JSON al inicio del stack.
