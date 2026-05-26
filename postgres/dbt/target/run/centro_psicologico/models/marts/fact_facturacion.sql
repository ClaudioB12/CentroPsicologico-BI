
  
    

  create  table "dm_centro_psicologico"."datamart"."fact_facturacion__dbt_tmp"
  
  
    as
  
  (
    with pagos as (
    select * from "dm_centro_psicologico"."staging"."stg_pagos"
),
sesiones as (
    select sesion_id, historia_id, psicologo_id,
           etapa_atencion, modalidad
    from "dm_centro_psicologico"."staging"."stg_sesiones"
),
historias as (
    select historia_id, paciente_id, tipo_historial from "dm_centro_psicologico"."staging"."stg_historia_clinica"
),
psicologos as (
    select psicologo_id, sede_id from "dm_centro_psicologico"."staging"."stg_psicologos"
),
servicios as (
    select servicio_id, etapa_atencion, tipo_historial, modalidad
    from "dm_centro_psicologico"."datamart"."dim_servicio"
)
select
    pg.pago_id,
    pg.sesion_id,
    pg.fecha_pago,
    h.paciente_id,
    s.psicologo_id,
    p.sede_id,
    sv.servicio_id,
    pg.monto                        as monto_cobrado,
    pg.metodo_pago,
    pg.estado_pago,
    pg.comprobante
from pagos pg
left join sesiones   s  on pg.sesion_id   = s.sesion_id
left join historias  h  on s.historia_id  = h.historia_id
left join psicologos p  on s.psicologo_id = p.psicologo_id
left join servicios  sv on s.etapa_atencion  = sv.etapa_atencion
                        and h.tipo_historial = sv.tipo_historial
                        and s.modalidad      = sv.modalidad
where pg.estado_pago = 'PAGADO'
  );
  