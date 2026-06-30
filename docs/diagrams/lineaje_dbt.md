# Lineaje dbt

Dependencias entre capas de modelos dbt: fuentes `raw` → `staging` → dimensiones y hechos del `datamart`.

## Linaje: raw → staging

```mermaid
flowchart TD
  subgraph RAW["schema raw — 9 fuentes CDC"]
    direction LR
    r1([raw.sedes]) 
    r2([raw.psicologos])
    r3([raw.pacientes])
    r4([raw.historia_clinica])
    r5([raw.sesiones])
    r6([raw.evaluacion_psicologica])
    r7([raw.diagnosticos])
    r8([raw.plan_intervencion])
    r9([raw.pagos])
  end

  subgraph STAGING["schema staging — 9 modelos stg_*"]
    direction LR
    s1[stg_sedes]
    s2[stg_psicologos]
    s3[stg_pacientes]
    s4[stg_historia_clinica]
    s5[stg_sesiones]
    s6[stg_evaluaciones]
    s7[stg_diagnosticos]
    s8[stg_planes]
    s9[stg_pagos]
  end

  r1 --> s1
  r2 --> s2
  r3 --> s3
  r4 --> s4
  r5 --> s5
  r6 --> s6
  r7 --> s7
  r8 --> s8
  r9 --> s9
```

## Linaje: staging → dimensiones

```mermaid
flowchart TD
  subgraph STAGING["schema staging"]
    direction LR
    s1[stg_sedes]
    s2[stg_psicologos]
    s3[stg_pacientes]
    s4[stg_historia_clinica]
    s5[stg_sesiones]
    s7[stg_diagnosticos]
  end

  subgraph DIMS["schema datamart — dimensiones"]
    d1[dim_sede]
    d2[dim_psicologo]
    d3[dim_paciente]
    d4[dim_tiempo]
    d5[dim_servicio]
    d6[dim_diagnostico]
  end

  s1 --> d1
  s2 --> d2
  s3 --> d3
  s4 --> d3
  s5 --> d4
  s5 --> d5
  s4 --> d5
  s7 --> d6
```

## Linaje: staging → hechos

```mermaid
flowchart TD
  subgraph STAGING["schema staging"]
    direction LR
    s2[stg_psicologos]
    s4[stg_historia_clinica]
    s5[stg_sesiones]
    s6[stg_evaluaciones]
    s9[stg_pagos]
  end

  subgraph FACTS["schema datamart — hechos"]
    f1[fact_sesion\n52 filas]
    f2[fact_facturacion\n45 filas]
    f3[fact_evaluacion\n9 filas]
  end

  s5 --> f1
  s4 --> f1
  s2 --> f1

  s9 --> f2
  s5 --> f2
  s4 --> f2
  s2 --> f2

  s6 --> f3
  s5 --> f3
  s4 --> f3
```

---

## Transformaciones aplicadas en staging

| Modelo staging | Filas | Fuente raw | Transformaciones clave |
|---|---|---|---|
| `stg_sedes` | 3 | `raw.sedes` | Convierte `tiene_online` TINYINT → booleano |
| `stg_psicologos` | 4 | `raw.psicologos` | Seleccion directa de columnas |
| `stg_pacientes` | 20 | `raw.pacientes` | `DATE '1970-01-01' + fecha_nacimiento` (entero Debezium → DATE) |
| `stg_historia_clinica` | 20 | `raw.historia_clinica` | Convierte `fecha_apertura` |
| `stg_sesiones` | 52 | `raw.sesiones` | Convierte `fecha_sesion`; `coalesce(duracion_min, 0)` |
| `stg_evaluaciones` | 9 | `raw.evaluacion_psicologica` | `coalesce` en CDI/STAI; convierte `fecha_evaluacion` |
| `stg_diagnosticos` | 31 | `raw.diagnosticos` | Filtra `codigo_cie10 IS NOT NULL` |
| `stg_planes` | 9 | `raw.plan_intervencion` | Convierte `fecha_inicio` y `fecha_fin` |
| `stg_pagos` | 45 | `raw.pagos` | Convierte `fecha_pago`; `coalesce(monto, 0.00)` |

## Construccion de marts

| Modelo mart | Filas | Joins principales |
|---|---|---|
| `dim_paciente` | 20 | `stg_pacientes` LEFT JOIN `stg_historia_clinica` |
| `dim_psicologo` | 4 | `stg_psicologos` |
| `dim_sede` | 3 | `stg_sedes` |
| `dim_servicio` | 22 | `stg_sesiones` LEFT JOIN `stg_historia_clinica` — `DISTINCT etapa+historial+modalidad` |
| `dim_tiempo` | 48 | `stg_sesiones` — fechas unicas de sesion |
| `dim_diagnostico` | 10 | `stg_diagnosticos` — `DISTINCT codigo_cie10` |
| `fact_sesion` | 52 | `stg_sesiones` + historias + psicologos |
| `fact_facturacion` | 45 | `stg_pagos` + sesiones + historias + psicologos; filtro `estado_pago = 'PAGADO'` |
| `fact_evaluacion` | 9 | `stg_evaluaciones` + sesiones + historias |
