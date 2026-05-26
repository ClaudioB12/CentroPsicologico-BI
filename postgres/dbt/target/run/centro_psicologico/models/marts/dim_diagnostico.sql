
  
    

  create  table "dm_centro_psicologico"."datamart"."dim_diagnostico__dbt_tmp"
  
  
    as
  
  (
    select
    codigo_cie10,
    min(descripcion_cie10)      as descripcion_cie10
from "dm_centro_psicologico"."staging"."stg_diagnosticos"
where codigo_cie10 is not null
group by codigo_cie10
  );
  