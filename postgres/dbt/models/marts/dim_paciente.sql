with pacientes as (
    select * from {{ ref('stg_pacientes') }}
),
historias as (
    select paciente_id, codigo_historia, tipo_historial
    from {{ ref('stg_historia_clinica') }}
)
select
    p.paciente_id,
    h.codigo_historia,
    h.tipo_historial,
    case
        when extract(year from age(current_date, p.fecha_nacimiento)) < 18  then '< 18'
        when extract(year from age(current_date, p.fecha_nacimiento)) <= 25 then '18-25'
        when extract(year from age(current_date, p.fecha_nacimiento)) <= 35 then '26-35'
        when extract(year from age(current_date, p.fecha_nacimiento)) <= 45 then '36-45'
        when extract(year from age(current_date, p.fecha_nacimiento)) <= 60 then '46-60'
        else '60+'
    end                                                               as rango_etario,
    p.sexo,
    p.estado_civil,
    p.grado_instruccion,
    case
        when p.ocupacion ilike '%docente%'    or p.ocupacion ilike '%profesor%'   then 'Educacion'
        when p.ocupacion ilike '%medico%'     or p.ocupacion ilike '%enfermero%'  then 'Salud'
        when p.ocupacion ilike '%comerciante%'                                    then 'Comercio'
        when p.ocupacion ilike '%ingeniero%'  or p.ocupacion ilike '%tecnico%'    then 'Tecnico'
        when p.ocupacion ilike '%abogado%'    or p.ocupacion ilike '%contador%'   then 'Profesional'
        when p.ocupacion ilike '%estudiante%'                                     then 'Estudiantil'
        when p.ocupacion ilike '%conductor%'                                      then 'Transporte'
        when p.ocupacion ilike '%agricultor%'                                     then 'Agro'
        when p.ocupacion ilike '%ama de casa%'                                    then 'Hogar'
        else 'Otros'
    end                                                               as ocupacion_grupo,
    coalesce(p.canal_captacion, 'No registrado')                      as canal_captacion,
    p.estado_paciente,
    p.modalidad_preferida,
    p.fecha_registro                                                  as fecha_primera_consulta
from pacientes p
left join historias h on p.paciente_id = h.paciente_id
