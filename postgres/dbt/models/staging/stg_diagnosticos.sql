select
    diagnostico_id,
    sesion_id,
    codigo_cie10,
    descripcion_cie10,
    diagnostico_clinico
from {{ source('raw', 'diagnosticos') }}
where codigo_cie10 is not null
