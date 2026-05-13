
select
    to_char(fecha_sesion, 'YYYYMMDD')::int as tiempo_key,
    fecha_sesion as fecha,
    extract(year from fecha_sesion)::int as anio,
    extract(quarter from fecha_sesion)::int as trimestre,
    extract(month from fecha_sesion)::int as mes_numero,
    to_char(fecha_sesion, 'TMMonth') as mes_nombre,
    extract(day from fecha_sesion)::int as dia,
    extract(dow from fecha_sesion)::int as dia_semana_numero,
    to_char(fecha_sesion, 'TMDay') as dia_semana_nombre

from (
    select distinct
        fecha_sesion
    from {{ ref('stg_sesiones') }}
    where fecha_sesion is not null
) fechas