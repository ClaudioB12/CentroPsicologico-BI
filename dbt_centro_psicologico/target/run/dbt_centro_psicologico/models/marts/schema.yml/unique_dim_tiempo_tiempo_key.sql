
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    tiempo_key as unique_field,
    count(*) as n_records

from "dm_centro_psicologico"."marts"."dim_tiempo"
where tiempo_key is not null
group by tiempo_key
having count(*) > 1



  
  
      
    ) dbt_internal_test