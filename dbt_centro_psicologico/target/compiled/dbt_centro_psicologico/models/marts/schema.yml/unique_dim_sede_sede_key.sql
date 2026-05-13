
    
    

select
    sede_key as unique_field,
    count(*) as n_records

from "dm_centro_psicologico"."marts"."dim_sede"
where sede_key is not null
group by sede_key
having count(*) > 1


