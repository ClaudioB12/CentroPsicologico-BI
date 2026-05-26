select
    codigo_cie10,
    min(descripcion_cie10)      as descripcion_cie10
from {{ ref('stg_diagnosticos') }}
where codigo_cie10 is not null
group by codigo_cie10