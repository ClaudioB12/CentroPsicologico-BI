
  
    

  create  table "dm_centro_psicologico"."staging"."stg_psicologos__dbt_tmp"
  
  
    as
  
  (
    select
    psicologo_id,
    dni,
    nombres,
    especialidad,
    cpp,
    modalidad,
    sede_id,
    estado
from "dm_centro_psicologico"."raw"."psicologos"
  );
  