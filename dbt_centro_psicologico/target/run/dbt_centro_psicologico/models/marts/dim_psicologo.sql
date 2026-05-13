
  
    

  create  table "dm_centro_psicologico"."marts"."dim_psicologo__dbt_tmp"
  
  
    as
  
  (
    select
    psicologo_id as psicologo_key,
    psicologo_id,
    dni,
    nombre_psicologo,
    especialidad,
    cpp,
    modalidad,
    sede_id,
    estado

from "dm_centro_psicologico"."staging"."stg_psicologos"
  );
  