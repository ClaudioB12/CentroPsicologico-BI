# Esquema OLTP MySQL

Diagrama entidad-relacion del esquema operacional `dm_centro_psicologico` definido en `init.sql` y montado por el `docker-compose.yml` principal.

## Diagrama ER — Jerarquia principal

```mermaid
%%{init: {"er": {"layoutDirection": "TB"}}}%%
erDiagram
  sedes ||--o{ psicologos : "sede_id"
  sedes ||--o{ pacientes : "sede_id"
  pacientes ||--o{ historia_clinica : "paciente_id"
  historia_clinica ||--o{ sesiones : "historia_id"
  psicologos ||--o{ sesiones : "psicologo_id"

  sedes {
    INT sede_id PK
    VARCHAR nombre_sede
    VARCHAR ciudad
    TINYINT tiene_online
    ENUM estado
  }

  psicologos {
    INT psicologo_id PK
    INT sede_id FK
    VARCHAR dni
    VARCHAR nombres
    VARCHAR especialidad
    VARCHAR cpp
    ENUM modalidad
    ENUM estado
  }

  pacientes {
    INT paciente_id PK
    INT sede_id FK
    VARCHAR nombres
    ENUM tipo_documento
    VARCHAR numero_documento
    DATE fecha_nacimiento
    ENUM sexo
    VARCHAR estado_civil
    VARCHAR ocupacion
    DATE fecha_registro
    VARCHAR canal_captacion
    ENUM estado_paciente
    ENUM modalidad_preferida
  }

  historia_clinica {
    INT historia_id PK
    INT paciente_id FK
    VARCHAR codigo_historia
    ENUM tipo_historial
    DATE fecha_apertura
    ENUM estado_historia
  }

  sesiones {
    INT sesion_id PK
    INT historia_id FK
    INT psicologo_id FK
    DATE fecha_sesion
    TIME hora_sesion
    SMALLINT nro_sesion
    VARCHAR etapa_atencion
    ENUM modalidad
    SMALLINT duracion_min
    ENUM estado_sesion
  }
```

## Diagrama ER — Tablas dependientes de sesion

```mermaid
%%{init: {"er": {"layoutDirection": "TB"}}}%%
erDiagram
  sesiones ||--o| evaluacion_psicologica : "sesion_id UNIQUE"
  sesiones ||--o{ diagnosticos : "sesion_id"
  sesiones ||--o{ plan_intervencion : "sesion_id"
  sesiones ||--o{ pagos : "sesion_id"

  sesiones {
    INT sesion_id PK
    DATE fecha_sesion
    VARCHAR etapa_atencion
    ENUM estado_sesion
  }

  evaluacion_psicologica {
    INT evaluacion_id PK
    INT sesion_id FK
    TEXT metodos_aplicados
    DECIMAL puntaje_cdi
    DECIMAL puntaje_stai
    DATE fecha_evaluacion
  }

  diagnosticos {
    INT diagnostico_id PK
    INT sesion_id FK
    VARCHAR codigo_cie10
    VARCHAR descripcion_cie10
    TEXT diagnostico_clinico
  }

  plan_intervencion {
    INT plan_id PK
    INT sesion_id FK
    TEXT objetivos
    TEXT intervenciones
    DATE fecha_inicio
    DATE fecha_fin
    ENUM estado_plan
  }

  pagos {
    INT pago_id PK
    INT sesion_id FK
    DATE fecha_pago
    DECIMAL monto
    VARCHAR comprobante
    ENUM metodo_pago
    ENUM estado_pago
  }
```

---

## Descripcion de tablas

| Tabla | Proposito | PK | FKs |
|---|---|---|---|
| `sedes` | Locaciones fisicas y online del centro | `sede_id` | — |
| `psicologos` | Profesionales registrados | `psicologo_id` | `sede_id → sedes` |
| `pacientes` | Personas en atencion o evaluacion | `paciente_id` | `sede_id → sedes` |
| `historia_clinica` | Expediente clinico de cada paciente | `historia_id` | `paciente_id → pacientes` |
| `sesiones` | Citas individuales o de pareja | `sesion_id` | `historia_id`, `psicologo_id` |
| `evaluacion_psicologica` | Resultados de pruebas aplicadas (1:1 con sesion) | `evaluacion_id` | `sesion_id` (UNIQUE) |
| `diagnosticos` | Codigos CIE-10 asociados a sesiones | `diagnostico_id` | `sesion_id` |
| `plan_intervencion` | Objetivos y tecnicas de tratamiento | `plan_id` | `sesion_id` |
| `pagos` | Transacciones economicas por sesion | `pago_id` | `sesion_id` |

!!! warning "Relacion evaluacion_psicologica"
    `evaluacion_psicologica.sesion_id` tiene restriccion `UNIQUE`, por lo que la relacion es 1:0..1 (una sesion puede tener a lo sumo una evaluacion). Solo se inserta para sesiones con `etapa_atencion = 'EVALUACION'`.

!!! note "Etapas de atencion"
    El campo `etapa_atencion` en `sesiones` clasifica cada cita: `MOTIVO_CONSULTA`, `ANAMNESIS`, `EVALUACION`, `TRATAMIENTO`, `SEGUIMIENTO` o `CIERRE`. Los planes de intervencion solo se crean para sesiones `TRATAMIENTO REALIZADA`.

!!! info "Esquema anterior"
    El archivo `OLTP_Centro_Psicologico.sql` contiene un esquema anterior con tablas prefijadas `oltp_*`. **No es el DDL activo**. El compose principal monta `init.sql`.
