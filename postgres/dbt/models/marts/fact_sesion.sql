with sesiones as (
    select * from {{ ref('stg_sesiones') }}
),
historias as (
    select historia_id, paciente_id, tipo_historial from {{ ref('stg_historia_clinica') }}
),
psicologos as (
    select psicologo_id, sede_id from {{ ref('stg_psicologos') }}
),
diagnosticos as (
    -- un diagnóstico principal por sesión (max por si hubiera más de uno)
    select sesion_id, min(codigo_cie10) as codigo_cie10
    from {{ ref('stg_diagnosticos') }}
    group by sesion_id
),
servicios as (
    select servicio_id, etapa_atencion, tipo_historial, modalidad
    from {{ ref('dim_servicio') }}
)
select
    s.sesion_id,
    s.fecha_sesion,
    h.paciente_id,
    s.psicologo_id,
    p.sede_id,
    s.historia_id,
    -- claves foráneas a dimensiones
    d.codigo_cie10,
    sv.servicio_id,
    -- atributos de la sesión
    s.nro_sesion,
    h.tipo_historial,
    s.etapa_atencion,
    s.modalidad,
    s.duracion_min,
    -- flags para medidas DAX rápidas
    (s.estado_sesion = 'REALIZADA')::int    as flag_realizada,
    (s.estado_sesion = 'CANCELADA')::int    as flag_cancelada,
    (s.estado_sesion = 'NO_SHOW')::int      as flag_noshow,
    (s.nro_sesion = 1)::int                 as flag_primera_sesion,
    s.estado_sesion
from sesiones s
left join historias   h  on s.historia_id  = h.historia_id
left join psicologos  p  on s.psicologo_id = p.psicologo_id
left join diagnosticos d  on s.sesion_id   = d.sesion_id
left join servicios   sv on s.etapa_atencion  = sv.etapa_atencion
                         and h.tipo_historial = sv.tipo_historial
                         and s.modalidad      = sv.modalidad
