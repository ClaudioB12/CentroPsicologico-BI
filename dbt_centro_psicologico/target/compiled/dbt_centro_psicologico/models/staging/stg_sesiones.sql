select
    sesion_id,
    codigo_historia,
    paciente_id,
    psicologo_id,
    nro_sesion,

    case
        when fecha_sesion is not null
             and length(fecha_sesion::text) = 8
        then to_date(fecha_sesion::text, 'YYYYMMDD')
        else null
    end as fecha_sesion,

    tipo_historial,
    etapa_atencion,
    modalidad,
    duracion_min,
    estado_sesion,
    monto_sesion,
    estado_pago,
    metodo_pago,
    codigo_cie10,
    descripcion_cie10

from "dm_centro_psicologico"."public"."oltp_sesiones"
where coalesce(__deleted, 'false') <> 'true'