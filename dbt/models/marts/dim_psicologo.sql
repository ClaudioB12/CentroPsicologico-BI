select
    psicologo_id,
    dni,
    nombres,
    especialidad,
    cpp,
    modalidad,
    sede_id,
    estado
from {{ ref('stg_psicologos') }}
