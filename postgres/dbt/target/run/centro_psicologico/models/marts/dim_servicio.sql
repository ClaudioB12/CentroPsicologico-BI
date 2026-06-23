
  
    

  create  table "dm_centro_psicologico"."datamart"."dim_servicio__dbt_tmp"
  
  
    as
  
  (
    with sesiones as (
    select * from "dm_centro_psicologico"."staging"."stg_sesiones"
),
historias as (
    select historia_id, tipo_historial from "dm_centro_psicologico"."staging"."stg_historia_clinica"
),
base as (
    select
        s.etapa_atencion,
        h.tipo_historial,
        s.modalidad,
        avg(s.duracion_min)::int                                                    as duracion_estandar,
        case when h.tipo_historial = 'PAREJA' then 230.00 else 150.00 end           as precio_base,
        s.etapa_atencion || ' - ' || h.tipo_historial || ' - ' || s.modalidad       as descripcion
    from sesiones s
    left join historias h on s.historia_id = h.historia_id
    where s.etapa_atencion is not null
    group by s.etapa_atencion, h.tipo_historial, s.modalidad
)
select
    -- clave surrogate estable: no cambia entre ejecuciones dbt
    md5(
        coalesce(etapa_atencion, '') || '~' ||
        coalesce(tipo_historial,  '') || '~' ||
        coalesce(modalidad,       '')
    )                       as servicio_id,
    etapa_atencion,
    tipo_historial,
    modalidad,
    duracion_estandar,
    precio_base,
    descripcion
from base
  );
  