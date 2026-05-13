
select
    s.sesion_id as facturacion_key,
    s.sesion_id,

    s.paciente_id as paciente_key,
    s.psicologo_id as psicologo_key,
    p.sede_id as sede_key,
    t.tiempo_key,
    sv.servicio_key,

    s.monto_sesion,
    s.estado_pago,
    s.metodo_pago,

    case
        when upper(coalesce(s.estado_pago, '')) in ('PAGADO', 'CANCELADO')
        then s.monto_sesion
        else 0
    end as monto_pagado,

    case
        when upper(coalesce(s.estado_pago, '')) not in ('PAGADO', 'CANCELADO')
        then s.monto_sesion
        else 0
    end as monto_pendiente,

    1 as cantidad_registros_facturacion

from {{ ref('stg_sesiones') }} s

left join {{ ref('stg_pacientes') }} p
    on s.paciente_id = p.paciente_id

left join {{ ref('dim_tiempo') }} t
    on s.fecha_sesion = t.fecha

left join {{ ref('dim_servicio') }} sv
    on coalesce(s.tipo_historial, '') = coalesce(sv.tipo_historial, '')
   and coalesce(s.etapa_atencion, '') = coalesce(sv.etapa_atencion, '')
   and coalesce(s.modalidad, '') = coalesce(sv.modalidad, '')