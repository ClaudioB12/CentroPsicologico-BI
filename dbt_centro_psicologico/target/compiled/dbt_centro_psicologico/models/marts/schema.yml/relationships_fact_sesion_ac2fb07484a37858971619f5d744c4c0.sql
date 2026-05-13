
    
    

with child as (
    select tiempo_key as from_field
    from "dm_centro_psicologico"."marts"."fact_sesion"
    where tiempo_key is not null
),

parent as (
    select tiempo_key as to_field
    from "dm_centro_psicologico"."marts"."dim_tiempo"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


