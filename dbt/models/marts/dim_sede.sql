select
    sede_id,
    nombre_sede,
    ciudad,
    tiene_online,
    estado
from {{ ref('stg_sedes') }}
