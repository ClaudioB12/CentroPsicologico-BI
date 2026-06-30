# 10. Dashboard Interactivo

El dashboard interactivo esta implementado en **Power BI Desktop** con tres tableros ejecutivos y un reporte de pacientes. Cada pagina tiene KPIs, visuales especificos y segmentadores cruzados que permiten analisis por periodo, sede, psicologo y modalidad.

## 10.1 Paginas del dashboard

| Pagina | Objetivo | Visuales principales | Filtros |
|---|---|---|---|
| **Tablero Ejecutivo** | Mostrar KPIs financieros y operativos globales | Tarjetas (ingresos, sesiones, margen), grafico de lineas mensual, barras por psicologo | Periodo, sede |
| **Tablero Clinico Operativo** | Analizar tasa de cancelacion, no-show y ocupacion | Tabla con semaforo RAG, bullet chart ocupacion vs. meta 75%, grafico de barras por psicologo | Periodo, psicologo, etapa atencion |
| **Tablero de Fidelizacion** | Identificar pacientes en riesgo de abandono | Tabla de alertas, grafico de recurrencia, mapa de calor por etapa terapeutica | Estado paciente, canal captacion, rango etario |
| **Reporte de Pacientes** | Analizar distribucion demografica y comportamiento | Grafico de dona por rango etario, ranking por psicologo, tabla detalle pacientes | Modalidad, sexo, sede |

## 10.2 Interactividad implementada

| Funcionalidad | Pagina / visual | Proposito |
|---|---|---|
| Segmentadores cruzados | Todas las paginas | Filtros sincronizados por periodo, sede, psicologo y modalidad para analisis multidimensional |
| Drill-down temporal | Graficos de tendencia | Navegacion Año → Trimestre → Mes → Semana en cualquier visual con eje de tiempo |
| Drill-through | Pagina de pacientes | Desde resumen de psicologo → detalle de sesiones y pagos del profesional seleccionado |
| Tooltips personalizados | KPIs tipo tarjeta | Al pasar el cursor muestra formula del KPI y comparativo vs periodo anterior |
| Navegacion entre paginas | Botones de menu | Navegacion sin perder el contexto del filtro activo |

## 10.3 Comparativos y KPIs obligatorios

El dashboard incluye los tres comparativos obligatorios del curso:

### Comparativo vs mismo periodo ano anterior (YoY)

```mermaid
flowchart TD
  subgraph LOGICA["Logica de comparacion YoY"]
    direction LR
    PA["Periodo actual\nMes N del Ano X"]
    PP["Mismo periodo\nMes N del Ano X-1"]
    VAR["Variacion YoY %\n(actual - anterior) / anterior"]
  end

  subgraph KPI["KPIs con variacion YoY"]
    direction LR
    K1["Sesiones Realizadas\nvs. mismo mes ano anterior"]
    K2["Ingresos Totales S/.\nvs. mismo mes ano anterior"]
    K3["Tasa Cancelacion %\nvs. mismo mes ano anterior"]
  end

  subgraph DAX["Medidas DAX YoY"]
    direction LR
    D1["Ingresos Ano Anterior =\nCALCULATE([Monto Total Cobrado],\nSAMEPERIODLASTYEAR('dim_tiempo'[fecha]))"]
    D2["Variacion YoY % =\nDIVIDE([Monto Total Cobrado] -\n[Ingresos Ano Anterior],\n[Ingresos Ano Anterior], 0) * 100"]
  end

  PA --> VAR
  PP --> VAR
  VAR --> KPI
  DAX --> KPI
```

### Comparativo vs periodo anterior (MoM)

```mermaid
flowchart TD
  subgraph LOGICA["Logica de comparacion MoM"]
    direction LR
    PA["Mes actual\nN"]
    PP["Mes anterior\nN-1"]
    VAR["Variacion MoM %\n(N - N-1) / N-1"]
  end

  subgraph DAX["Medidas DAX MoM"]
    direction LR
    D1["Ingresos Periodo Anterior =\nCALCULATE([Monto Total Cobrado],\nPREVIOUSMONTH('dim_tiempo'[fecha]))"]
    D2["Variacion MoM % =\nDIVIDE([Monto Total Cobrado] -\n[Ingresos Periodo Anterior],\n[Ingresos Periodo Anterior], 0) * 100"]
  end

  PA --> VAR
  PP --> VAR
  DAX --> VAR
```

### Tabla KPI de variacion por dimension de negocio

| KPI | Valor actual | Ano anterior | Variacion % | Dimension |
|---|---|---|---|---|
| Sesiones realizadas | 71 | — | — | por Psicologo / Sede |
| Ingresos Totales S/ | S/ 8,030 | — | — | por Sede / Metodo Pago |
| Tasa Cancelacion % | ~13% | — | — | por Psicologo |
| Margen Bruto % | 49.94% | — | — | por Tipo de Servicio |
| Ticket Promedio S/ | ~S/ 113 | — | — | por Canal Captacion |
| Abandono Terapeutico % | — | — | — | por Psicologo / Etapa |

!!! tip "Iconos de semaforo RAG"
    Los visuales de comparativo usan formato condicional con iconos: verde (cumplido), amarillo (en rango esperado), rojo (bajo). Los umbrales son los definidos en la seccion de [criterios de interpretacion de KPIs](04_kpis.md#42-criterios-de-interpretacion).

## 10.4 Estructura de visuales obligatorios

```mermaid
flowchart TD
  subgraph DASH["Tablero Ejecutivo — Visuales obligatorios"]
    direction LR
    V1["Tarjetas KPI\nIngresos · Sesiones\nMargen · Ticket Prom."]
    V2["Grafico lineas mensual\nTendencia ingresos\ny sesiones por mes"]
    V3["Comparativo YoY\nActual vs mismo mes\nano anterior"]
    V4["Comparativo MoM\nActual vs mes\nanterior"]
    V5["Tabla KPI variacion\npor Psicologo · Sede\nformato condicional RAG"]
  end

  subgraph SEG["Segmentadores"]
    direction LR
    S1["Ano / Mes"]
    S2["Sede"]
    S3["Psicologo"]
    S4["Modalidad"]
  end

  SEG -->|"filtran"| DASH
```
