select
    row_number() over (
        order by tipo_historial, etapa_atencion, modalidad
    ) as servicio_key,

    tipo_historial,
    etapa_atencion,
    modalidad

from (
    select distinct
        tipo_historial,
        etapa_atencion,
        modalidad
    from "dm_centro_psicologico"."staging"."stg_sesiones"
) servicios