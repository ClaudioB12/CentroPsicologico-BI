select
    historia_id,
    paciente_id,
    codigo_historia,
    tipo_historial,
    (DATE '1970-01-01' + fecha_apertura * INTERVAL '1 day')::date as fecha_apertura,
    estado_historia
from "dm_centro_psicologico"."raw"."historia_clinica"