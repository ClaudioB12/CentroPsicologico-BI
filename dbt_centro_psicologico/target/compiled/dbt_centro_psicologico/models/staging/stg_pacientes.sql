select
    paciente_id,
    codigo_historia,
    tipo_historial,
    nombres,
    apellido_paterno,
    apellido_materno,
    concat_ws(' ', nombres, apellido_paterno, apellido_materno) as nombre_paciente,
    numero_documento,

    case
        when fecha_nacimiento is not null
             and length(fecha_nacimiento::text) = 8
        then to_date(fecha_nacimiento::text, 'YYYYMMDD')
        else null
    end as fecha_nacimiento,

    sexo,
    estado_civil,
    grado_instruccion,
    ocupacion,
    ciudad,
    contacto_celular,
    email,

    case
        when fecha_ingreso is not null
             and length(fecha_ingreso::text) = 8
        then to_date(fecha_ingreso::text, 'YYYYMMDD')
        else null
    end as fecha_ingreso,

    canal_captacion,
    estado_paciente,
    modalidad_preferida,
    sede_id

from "dm_centro_psicologico"."public"."oltp_pacientes"
where coalesce(__deleted, 'false') <> 'true'