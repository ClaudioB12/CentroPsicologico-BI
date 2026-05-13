
    
    

select
    paciente_key as unique_field,
    count(*) as n_records

from "dm_centro_psicologico"."marts"."dim_paciente"
where paciente_key is not null
group by paciente_key
having count(*) > 1


