select
    plan_id,
    sesion_id,
    objetivos,
    intervenciones,
    recomendaciones,
    (DATE '1970-01-01' + fecha_inicio) as fecha_inicio,
    (DATE '1970-01-01' + fecha_fin)   as fecha_fin,
    estado_plan
from {{ source('raw', 'plan_intervencion') }}
