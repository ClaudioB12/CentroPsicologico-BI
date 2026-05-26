
  
    

  create  table "dm_centro_psicologico"."datamart"."fact_sesion__dbt_tmp"
  
  
    as
  
  (
    with sesiones as (
    select * from "dm_centro_psicologico"."staging"."stg_sesiones"
),
historias as (
    select historia_id, paciente_id, tipo_historial from "dm_centro_psicologico"."staging"."stg_historia_clinica"
),
psicologos as (
    select psicologo_id, sede_id from "dm_centro_psicologico"."staging"."stg_psicologos"
)
select
    s.sesion_id,
    s.fecha_sesion,
    h.paciente_id,
    s.psicologo_id,
    p.sede_id,
    s.historia_id,
    s.nro_sesion,
    h.tipo_historial,
    s.etapa_atencion,
    s.modalidad,
    s.duracion_min,
    (s.estado_sesion = 'REALIZADA')::int    as flag_realizada,
    (s.estado_sesion = 'CANCELADA')::int    as flag_cancelada,
    (s.estado_sesion = 'NO_SHOW')::int      as flag_noshow,
    (s.nro_sesion = 1)::int                 as flag_primera_sesion,
    s.estado_sesion
from sesiones s
left join historias  h on s.historia_id  = h.historia_id
left join psicologos p on s.psicologo_id = p.psicologo_id
  );
  