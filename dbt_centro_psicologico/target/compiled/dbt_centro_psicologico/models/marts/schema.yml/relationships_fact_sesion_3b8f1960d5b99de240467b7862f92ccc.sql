
    
    

with child as (
    select psicologo_key as from_field
    from "dm_centro_psicologico"."marts"."fact_sesion"
    where psicologo_key is not null
),

parent as (
    select psicologo_key as to_field
    from "dm_centro_psicologico"."marts"."dim_psicologo"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


