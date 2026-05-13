
  create view "dm_centro_psicologico"."staging"."stg_sedes__dbt_tmp"
    
    
  as (
    select
    sede_id,
    nombre_sede,
    ciudad,

    case
        when tiene_online = 1 then true
        else false
    end as tiene_online,

    estado

from "dm_centro_psicologico"."public"."oltp_sedes"
where coalesce(__deleted, 'false') <> 'true'
  );