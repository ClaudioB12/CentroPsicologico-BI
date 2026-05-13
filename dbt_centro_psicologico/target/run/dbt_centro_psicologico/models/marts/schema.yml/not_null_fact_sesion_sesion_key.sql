
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sesion_key
from "dm_centro_psicologico"."marts"."fact_sesion"
where sesion_key is null



  
  
      
    ) dbt_internal_test