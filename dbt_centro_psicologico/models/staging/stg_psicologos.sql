
select
    psicologo_id,
    dni,
    nombres as nombre_psicologo,
    especialidad,
    cpp,
    modalidad,
    sede_id,
    estado

from {{ source('centro_raw', 'oltp_psicologos') }}
where coalesce(__deleted, 'false') <> 'true'