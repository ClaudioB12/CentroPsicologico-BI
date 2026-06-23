select distinct
    fecha_sesion                                                              as fecha,
    extract(year    from fecha_sesion)::int                                   as anio,
    case when extract(month from fecha_sesion) <= 6 then 1 else 2 end        as semestre,
    extract(quarter from fecha_sesion)::int                                   as trimestre,
    'Q' || extract(quarter from fecha_sesion)::text                           as trim_desc,
    extract(month   from fecha_sesion)::int                                   as mes,
    to_char(fecha_sesion, 'TMMonth')                                          as mes_desc,
    extract(week    from fecha_sesion)::int                                   as semana_anio,
    extract(day     from fecha_sesion)::int                                   as dia_mes,
    extract(isodow  from fecha_sesion)::int                                   as dia_semana,
    to_char(fecha_sesion, 'TMDay')                                            as dia_semana_desc,
    (extract(isodow from fecha_sesion) >= 6)                                  as es_fin_semana
from "dm_centro_psicologico"."staging"."stg_sesiones"