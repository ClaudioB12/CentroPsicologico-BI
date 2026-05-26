select
    sede_id,
    nombre_sede,
    ciudad,
    (tiene_online <> 0)      as tiene_online,
    estado
from "dm_centro_psicologico"."raw"."sedes"