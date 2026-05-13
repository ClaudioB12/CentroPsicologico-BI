select
    sede_id as sede_key,
    sede_id,
    nombre_sede,
    ciudad,
    tiene_online,
    estado

from "dm_centro_psicologico"."staging"."stg_sedes"