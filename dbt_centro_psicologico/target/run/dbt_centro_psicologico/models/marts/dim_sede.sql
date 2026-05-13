
  
    

  create  table "dm_centro_psicologico"."marts"."dim_sede__dbt_tmp"
  
  
    as
  
  (
    select
    sede_id as sede_key,
    sede_id,
    nombre_sede,
    ciudad,
    tiene_online,
    estado

from "dm_centro_psicologico"."staging"."stg_sedes"
  );
  