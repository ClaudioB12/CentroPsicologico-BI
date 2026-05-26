with pagos as (
    select * from {{ ref('stg_pagos') }}
),
sesiones as (
    select sesion_id, historia_id, psicologo_id from {{ ref('stg_sesiones') }}
),
historias as (
    select historia_id, paciente_id from {{ ref('stg_historia_clinica') }}
),
psicologos as (
    select psicologo_id, sede_id from {{ ref('stg_psicologos') }}
)
select
    pg.pago_id,
    pg.sesion_id,
    pg.fecha_pago,
    h.paciente_id,
    s.psicologo_id,
    p.sede_id,
    pg.monto                        as monto_cobrado,
    pg.metodo_pago,
    pg.estado_pago,
    pg.comprobante
from pagos pg
left join sesiones   s  on pg.sesion_id   = s.sesion_id
left join historias  h  on s.historia_id  = h.historia_id
left join psicologos p  on s.psicologo_id = p.psicologo_id
where pg.estado_pago = 'PAGADO'
