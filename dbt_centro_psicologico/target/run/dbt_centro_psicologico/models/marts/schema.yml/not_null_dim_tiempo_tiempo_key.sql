
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select tiempo_key
from "dm_centro_psicologico"."marts"."dim_tiempo"
where tiempo_key is null



  
  
      
    ) dbt_internal_test