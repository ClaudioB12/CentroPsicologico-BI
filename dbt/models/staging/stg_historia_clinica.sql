select
    historia_id,
    paciente_id,
    codigo_historia,
    tipo_historial,
    (DATE '1970-01-01' + fecha_apertura) as fecha_apertura,
    estado_historia
from {{ source('raw', 'historia_clinica') }}
