# Modelo dimensional

```mermaid
erDiagram
  DIM_PACIENTE ||--o{ FACT_SESION : "paciente_id"
  DIM_PACIENTE ||--o{ FACT_FACTURACION : "paciente_id"
  DIM_PACIENTE ||--o{ FACT_EVALUACION : "paciente_id"

  DIM_PSICOLOGO ||--o{ FACT_SESION : "psicologo_id"
  DIM_PSICOLOGO ||--o{ FACT_FACTURACION : "psicologo_id"
  DIM_PSICOLOGO ||--o{ FACT_EVALUACION : "psicologo_id"

  DIM_SEDE ||--o{ FACT_SESION : "sede_id"
  DIM_SEDE ||--o{ FACT_FACTURACION : "sede_id"

  DIM_TIEMPO ||--o{ FACT_SESION : "fecha = fecha_sesion"
  DIM_TIEMPO ||--o{ FACT_FACTURACION : "fecha = fecha_pago"
  DIM_TIEMPO ||--o{ FACT_EVALUACION : "fecha = fecha_evaluacion"

  DIM_SERVICIO ||--o{ FACT_SESION : "etapa_atencion + tipo_historial + modalidad"

  DIM_PACIENTE {
    INT paciente_id PK
    VARCHAR codigo_historia
    VARCHAR tipo_historial
    VARCHAR rango_etario
    VARCHAR sexo
    VARCHAR estado_civil
    VARCHAR grado_instruccion
    VARCHAR ocupacion_grupo
    VARCHAR canal_captacion
    VARCHAR estado_paciente
    VARCHAR modalidad_preferida
    DATE fecha_primera_consulta
  }

  DIM_PSICOLOGO {
    INT psicologo_id PK
    VARCHAR dni
    VARCHAR nombres
    VARCHAR especialidad
    VARCHAR cpp
    VARCHAR modalidad
    INT sede_id FK
    VARCHAR estado
  }

  DIM_SEDE {
    INT sede_id PK
    VARCHAR nombre_sede
    VARCHAR ciudad
    BOOLEAN tiene_online
    VARCHAR estado
  }

  DIM_TIEMPO {
    DATE fecha PK
    INT anio
    INT semestre
    INT trimestre
    VARCHAR trim_desc
    INT mes
    VARCHAR mes_desc
    INT semana_anio
    INT dia_mes
    INT dia_semana
    VARCHAR dia_semana_desc
    BOOLEAN es_fin_semana
  }

  DIM_SERVICIO {
    VARCHAR etapa_atencion PK
    VARCHAR tipo_historial PK
    VARCHAR modalidad PK
    INT duracion_estandar
    DECIMAL precio_base
    VARCHAR descripcion
  }

  DIM_DIAGNOSTICO {
    VARCHAR codigo_cie10 PK
    VARCHAR descripcion_cie10
  }

  FACT_SESION {
    INT sesion_id PK
    DATE fecha_sesion FK
    INT paciente_id FK
    INT psicologo_id FK
    INT sede_id FK
    INT historia_id
    INT nro_sesion
    VARCHAR tipo_historial
    VARCHAR etapa_atencion
    VARCHAR modalidad
    INT duracion_min
    INT flag_realizada
    INT flag_cancelada
    INT flag_noshow
    INT flag_primera_sesion
    VARCHAR estado_sesion
  }

  FACT_FACTURACION {
    INT pago_id PK
    INT sesion_id FK
    DATE fecha_pago FK
    INT paciente_id FK
    INT psicologo_id FK
    INT sede_id FK
    DECIMAL monto_cobrado
    VARCHAR metodo_pago
    VARCHAR estado_pago
    VARCHAR comprobante
  }

  FACT_EVALUACION {
    INT evaluacion_id PK
    INT sesion_id FK
    DATE fecha_sesion
    INT paciente_id FK
    INT psicologo_id FK
    INT historia_id
    DECIMAL puntaje_cdi
    DECIMAL puntaje_stai
    VARCHAR nivel_depresion
    VARCHAR nivel_ansiedad
    VARCHAR metodos_aplicados
    DATE fecha_evaluacion FK
  }

  %% DIM_PACIENTE, DIM_PSICOLOGO, DIM_SEDE y DIM_TIEMPO son dimensiones conformadas compartidas por mas de una fact table.
  %% DIM_DIAGNOSTICO existe en marts, pero ninguna fact table de marts incluye codigo_cie10 ni diagnostico_id para relacionarla directamente.
  %% No se detecto una factless fact table: las tres fact tables tienen metricas numericas o flags agregables.
```

## Notas de revision

- `dim_servicio` no tiene una clave surrogate en SQL; su relacion con `fact_sesion` se representa por la combinacion natural `etapa_atencion`, `tipo_historial` y `modalidad`.
- `dim_diagnostico` se crea desde `stg_diagnosticos`, pero `fact_evaluacion`, `fact_sesion` y `fact_facturacion` no contienen `codigo_cie10` ni `diagnostico_id`. Por eso queda sin relacion directa en el ER real.
- `fact_facturacion` se filtra a `pg.estado_pago = 'PAGADO'`.
- `fact_evaluacion` contiene `fecha_sesion` y `fecha_evaluacion`; para el vinculo temporal se uso `fecha_evaluacion` porque es el campo temporal declarado en `semantic_models.yml`.
- El README documenta `FACT_Sesion` y `FACT_Facturacion`, pero el codigo dbt real tambien incluye `fact_evaluacion`.
