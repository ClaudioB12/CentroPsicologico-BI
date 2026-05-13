
select
    sede_id,
    nombre_sede,
    ciudad,

    case
        when tiene_online = 1 then true
        else false
    end as tiene_online,

    estado

from {{ source('centro_raw', 'oltp_sedes') }}
where coalesce(__deleted, 'false') <> 'true'