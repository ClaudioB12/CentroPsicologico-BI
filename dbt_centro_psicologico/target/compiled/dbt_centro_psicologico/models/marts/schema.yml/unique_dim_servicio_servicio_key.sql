
    
    

select
    servicio_key as unique_field,
    count(*) as n_records

from "dm_centro_psicologico"."marts"."dim_servicio"
where servicio_key is not null
group by servicio_key
having count(*) > 1


