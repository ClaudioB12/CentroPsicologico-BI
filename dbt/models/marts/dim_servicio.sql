with sesiones as (
    select * from {{ ref('stg_sesiones') }}
),
historias as (
    select historia_id, tipo_historial from {{ ref('stg_historia_clinica') }}
)
select distinct
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
