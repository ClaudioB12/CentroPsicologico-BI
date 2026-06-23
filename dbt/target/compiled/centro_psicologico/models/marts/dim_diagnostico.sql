select distinct
    codigo_cie10,
    descripcion_cie10
from "dm_centro_psicologico"."staging"."stg_diagnosticos"
where codigo_cie10 is not null