
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select facturacion_key
from "dm_centro_psicologico"."marts"."fact_facturacion"
where facturacion_key is null



  
  
      
    ) dbt_internal_test