-- ================================================================
--  PostgreSQL — Inicialización de schemas
--
--  raw      : tablas replicadas desde MySQL vía CDC (Debezium)
--  datamart : tablas dimensionales y de hechos generadas por dbt
--  staging  : vistas intermedias de dbt (limpieza y tipado)
-- ================================================================

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS datamart;
