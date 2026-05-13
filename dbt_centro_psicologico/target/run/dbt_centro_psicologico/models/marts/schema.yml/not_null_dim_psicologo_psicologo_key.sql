
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select psicologo_key
from "dm_centro_psicologico"."marts"."dim_psicologo"
where psicologo_key is null



  
  
      
    ) dbt_internal_test