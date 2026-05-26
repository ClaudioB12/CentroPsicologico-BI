select
    sesion_id,
    historia_id,
    psicologo_id,
    (DATE '1970-01-01' + fecha_sesion) as fecha_sesion,
    hora_sesion,
    nro_sesion,
    etapa_atencion,
    modalidad,
    coalesce(duracion_min, 0)       as duracion_min,
    motivo_consulta,
    estado_sesion
from "dm_centro_psicologico"."raw"."sesiones"