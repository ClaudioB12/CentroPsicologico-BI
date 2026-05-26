select
    psicologo_id,
    dni,
    nombres,
    especialidad,
    cpp,
    modalidad,
    sede_id,
    estado
from {{ source('raw', 'psicologos') }}
