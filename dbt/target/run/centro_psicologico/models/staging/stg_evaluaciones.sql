
  
    

  create  table "dm_centro_psicologico"."staging"."stg_evaluaciones__dbt_tmp"
  
  
    as
  
  (
    select
    evaluacion_id,
    sesion_id,
    metodos_aplicados,
    resultados,
    coalesce(puntaje_cdi,  0)       as puntaje_cdi,
    coalesce(puntaje_stai, 0)       as puntaje_stai,
    observaciones,
    (DATE '1970-01-01' + fecha_evaluacion) as fecha_evaluacion
from "dm_centro_psicologico"."raw"."evaluacion_psicologica"
  );
  