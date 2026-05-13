
    
    

select
    sesion_key as unique_field,
    count(*) as n_records

from "dm_centro_psicologico"."marts"."fact_sesion"
where sesion_key is not null
group by sesion_key
having count(*) > 1


