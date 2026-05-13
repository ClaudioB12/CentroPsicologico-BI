
  
    

  create  table "dm_centro_psicologico"."marts"."dim_paciente__dbt_tmp"
  
  
    as
  
  (
    select
    paciente_id as paciente_key,
    paciente_id,
    codigo_historia,
    tipo_historial,
    nombre_paciente,
    numero_documento,
    fecha_nacimiento,
    sexo,
    estado_civil,
    grado_instruccion,
    ocupacion,
    ciudad,
    fecha_ingreso,
    canal_captacion,
    estado_paciente,
    modalidad_preferida,
    sede_id

from "dm_centro_psicologico"."staging"."stg_pacientes"
  );
  