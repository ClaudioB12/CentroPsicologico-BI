
    
    

with child as (
    select servicio_key as from_field
    from "dm_centro_psicologico"."marts"."fact_sesion"
    where servicio_key is not null
),

parent as (
    select servicio_key as to_field
    from "dm_centro_psicologico"."marts"."dim_servicio"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


