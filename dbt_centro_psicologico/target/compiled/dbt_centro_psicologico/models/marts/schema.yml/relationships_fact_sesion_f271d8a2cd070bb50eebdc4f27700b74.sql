
    
    

with child as (
    select paciente_key as from_field
    from "dm_centro_psicologico"."marts"."fact_sesion"
    where paciente_key is not null
),

parent as (
    select paciente_key as to_field
    from "dm_centro_psicologico"."marts"."dim_paciente"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


