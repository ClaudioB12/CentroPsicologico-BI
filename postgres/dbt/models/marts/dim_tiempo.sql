with rango as (
    select
        min(fecha_sesion) as fecha_min,
        max(fecha_sesion) as fecha_max
    from {{ ref('stg_sesiones') }}
),
calendario as (
    select generate_series(
        (select fecha_min from rango),
        (select fecha_max from rango),
        interval '1 day'
    )::date as fecha
)
select
    fecha,
    extract(year    from fecha)::int                                   as anio,
    case when extract(month from fecha) <= 6 then 1 else 2 end        as semestre,
    extract(quarter from fecha)::int                                   as trimestre,
    'Q' || extract(quarter from fecha)::text                           as trim_desc,
    extract(month   from fecha)::int                                   as mes,
    to_char(fecha, 'TMMonth')                                          as mes_desc,
    extract(week    from fecha)::int                                   as semana_anio,
    extract(day     from fecha)::int                                   as dia_mes,
    extract(isodow  from fecha)::int                                   as dia_semana,
    to_char(fecha, 'TMDay')                                            as dia_semana_desc,
    (extract(isodow from fecha) >= 6)::boolean                        as es_fin_semana
from calendario