-- ================================================================
--  TIME SPINE — requerido por MetricFlow (dbt Semantic Layer)
--
--  Una fila por día desde 2020-01-01 hasta 2030-12-31.
--  MetricFlow usa esta tabla como eje temporal para agregar métricas
--  por día, semana, mes, trimestre, año, etc.
-- ================================================================

{{ config(materialized='table') }}

select
    generate_series::date as date_day
from generate_series(
    '2020-01-01'::date,
    '2030-12-31'::date,
    '1 day'::interval
)
