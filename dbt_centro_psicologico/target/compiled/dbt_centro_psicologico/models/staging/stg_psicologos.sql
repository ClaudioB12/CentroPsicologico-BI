select
    psicologo_id,
    dni,
    nombres as nombre_psicologo,
    especialidad,
    cpp,
    modalidad,
    sede_id,
    estado

from "dm_centro_psicologico"."public"."oltp_psicologos"
where coalesce(__deleted, 'false') <> 'true'