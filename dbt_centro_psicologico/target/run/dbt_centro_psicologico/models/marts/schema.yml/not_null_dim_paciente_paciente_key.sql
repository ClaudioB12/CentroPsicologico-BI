
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select paciente_key
from "dm_centro_psicologico"."marts"."dim_paciente"
where paciente_key is null



  
  
      
    ) dbt_internal_test