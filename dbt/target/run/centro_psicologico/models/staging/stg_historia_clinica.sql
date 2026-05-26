
  
    

  create  table "dm_centro_psicologico"."staging"."stg_historia_clinica__dbt_tmp"
  
  
    as
  
  (
    select
    historia_id,
    paciente_id,
    codigo_historia,
    tipo_historial,
    (DATE '1970-01-01' + fecha_apertura) as fecha_apertura,
    estado_historia
from "dm_centro_psicologico"."raw"."historia_clinica"
  );
  