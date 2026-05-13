
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sede_key
from "dm_centro_psicologico"."marts"."dim_sede"
where sede_key is null



  
  
      
    ) dbt_internal_test