
select
    s.sesion_id as sesion_key,
    s.sesion_id,

    s.paciente_id as paciente_key,
    s.psicologo_id as psicologo_key,
    p.sede_id as sede_key,
    t.tiempo_key,
    sv.servicio_key,

    s.nro_sesion,
    s.duracion_min,
    s.estado_sesion,
    s.codigo_cie10,
    s.descripcion_cie10,

    1 as cantidad_sesiones

from {{ ref('stg_sesiones') }} s

left join {{ ref('stg_pacientes') }} p
    on s.paciente_id = p.paciente_id

left join {{ ref('dim_tiempo') }} t
    on s.fecha_sesion = t.fecha

left join {{ ref('dim_servicio') }} sv
    on coalesce(s.tipo_historial, '') = coalesce(sv.tipo_historial, '')
   and coalesce(s.etapa_atencion, '') = coalesce(sv.etapa_atencion, '')
   and coalesce(s.modalidad, '') = coalesce(sv.modalidad, '')