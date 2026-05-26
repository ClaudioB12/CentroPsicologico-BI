with evaluaciones as (
    select * from {{ ref('stg_evaluaciones') }}
),
sesiones as (
    select sesion_id, historia_id, psicologo_id, fecha_sesion from {{ ref('stg_sesiones') }}
),
historias as (
    select historia_id, paciente_id from {{ ref('stg_historia_clinica') }}
),
psicologos as (
    select psicologo_id, sede_id from {{ ref('stg_psicologos') }}
)
select
    e.evaluacion_id,
    e.sesion_id,
    s.fecha_sesion,
    h.paciente_id,
    s.psicologo_id,
    p.sede_id,
    s.historia_id,
    e.puntaje_cdi,
    e.puntaje_stai,
    case
        when e.puntaje_cdi  >= 30 then 'SEVERO'
        when e.puntaje_cdi  >= 20 then 'MODERADO'
        when e.puntaje_cdi  >= 10 then 'LEVE'
        else 'NORMAL'
    end                                         as nivel_depresion,
    case
        when e.puntaje_stai >= 60 then 'ALTO'
        when e.puntaje_stai >= 40 then 'MODERADO'
        else 'BAJO'
    end                                         as nivel_ansiedad,
    e.metodos_aplicados,
    e.fecha_evaluacion
from evaluaciones e
left join sesiones  s on e.sesion_id   = s.sesion_id
left join historias h on s.historia_id = h.historia_id
left join psicologos p on s.psicologo_id = p.psicologo_id
