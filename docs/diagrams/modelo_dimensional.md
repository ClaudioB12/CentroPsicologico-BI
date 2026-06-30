# Modelo dimensional

Diagrama entidad-relacion del datamart construido por dbt en el schema `datamart` de PostgreSQL.

## Esquema estrella — Facts y dimensiones conformadas

```mermaid
%%{init: {"er": {"layoutDirection": "TB"}}}%%
erDiagram
  DIM_PACIENTE ||--o{ FACT_SESION : "paciente_id"
  DIM_PACIENTE ||--o{ FACT_FACTURACION : "paciente_id"
  DIM_PACIENTE ||--o{ FACT_EVALUACION : "paciente_id"
  DIM_PSICOLOGO ||--o{ FACT_SESION : "psicologo_id"
  DIM_PSICOLOGO ||--o{ FACT_FACTURACION : "psicologo_id"
  DIM_PSICOLOGO ||--o{ FACT_EVALUACION : "psicologo_id"
  DIM_SEDE ||--o{ FACT_SESION : "sede_id"
  DIM_SEDE ||--o{ FACT_FACTURACION : "sede_id"
  DIM_TIEMPO ||--o{ FACT_SESION : "fecha_sesion"
  DIM_TIEMPO ||--o{ FACT_FACTURACION : "fecha_pago"
  DIM_TIEMPO ||--o{ FACT_EVALUACION : "fecha_evaluacion"
  DIM_SERVICIO ||--o{ FACT_SESION : "etapa+historial+modalidad"

  DIM_PACIENTE {
    INT paciente_id PK
    VARCHAR codigo_historia
    VARCHAR tipo_historial
    VARCHAR rango_etario
    VARCHAR sexo
    VARCHAR estado_civil
    VARCHAR ocupacion_grupo
    VARCHAR canal_captacion
    VARCHAR estado_paciente
    VARCHAR modalidad_preferida
    DATE fecha_primera_consulta
  }

  DIM_PSICOLOGO {
    INT psicologo_id PK
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
    INT mes
    VARCHAR mes_desc
    INT semana_anio
    INT dia_mes
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

  FACT_SESION {
    INT sesion_id PK
    DATE fecha_sesion FK
    INT paciente_id FK
    INT psicologo_id FK
    INT sede_id FK
    INT historia_id
    INT nro_sesion
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
  }

  FACT_EVALUACION {
    INT evaluacion_id PK
    INT sesion_id FK
    INT paciente_id FK
    INT psicologo_id FK
    DECIMAL puntaje_cdi
    DECIMAL puntaje_stai
    VARCHAR nivel_depresion
    VARCHAR nivel_ansiedad
    VARCHAR metodos_aplicados
    DATE fecha_evaluacion FK
  }
```

## Dimension independiente

```mermaid
%%{init: {"er": {"layoutDirection": "TB"}}}%%
erDiagram
  DIM_DIAGNOSTICO {
    VARCHAR codigo_cie10 PK
    VARCHAR descripcion_cie10
  }
```

!!! warning "DIM_DIAGNOSTICO sin FK en hechos"
    `dim_diagnostico` existe en el datamart pero ninguna de las tres facts contiene `codigo_cie10` ni `diagnostico_id`. Para vincularlo habria que agregar esa FK a `fact_sesion` en los modelos dbt.

---

## Notas de revision

!!! note "Clave compuesta en DIM_SERVICIO"
    `dim_servicio` no tiene surrogate key. Su relacion con `fact_sesion` se establece por la combinacion natural de tres columnas: `etapa_atencion + tipo_historial + modalidad`.

!!! info "Dimensiones conformadas"
    `DIM_PACIENTE`, `DIM_PSICOLOGO`, `DIM_SEDE` y `DIM_TIEMPO` son compartidas por mas de una tabla de hechos, lo que permite analisis cruzado entre sesiones, facturacion y evaluaciones.

!!! tip "Filtro en FACT_FACTURACION"
    `fact_facturacion` solo incluye registros con `estado_pago = 'PAGADO'`. Los pagos pendientes o exonerados quedan excluidos.

## Resumen del esquema estrella

| Tipo | Nombre | Filas (dbt run 2026-05-26) |
|---|---|---|
| Hecho | `fact_sesion` | 52 |
| Hecho | `fact_facturacion` | 45 |
| Hecho | `fact_evaluacion` | 9 |
| Dimension | `dim_paciente` | 20 |
| Dimension | `dim_psicologo` | 4 |
| Dimension | `dim_sede` | 3 |
| Dimension | `dim_tiempo` | 48 fechas |
| Dimension | `dim_servicio` | 22 combinaciones |
| Dimension | `dim_diagnostico` | 10 codigos CIE-10 |
