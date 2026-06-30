# Centro Psicologico Integral Guevara — BI End-to-End

Sistema de Business Intelligence completo para la gestion clinica, operativa y financiera del Centro Psicologico Integral Guevara, Juliaca, Peru.

## Pipeline implementado

```
MySQL 8.0 → Debezium + Kafka → PostgreSQL 15 → dbt → Power BI
```

## Resultados validados

| Metrica | Valor |
|---|---|
| Sesiones atendidas | 71 |
| Ingresos brutos | S/ 8,030.00 |
| Margen bruto promedio | 49.94% |
| Pacientes unicos registrados | 100 |
| Modelos dbt ejecutados | 20 (PASS=20) |
| KPIs implementados | 13 |

## Estructura del proyecto

| Seccion | Descripcion |
|---|---|
| [Datos del Proyecto](informe/01_datos_generales.md) | Equipo, herramientas y componentes |
| [Resumen Ejecutivo](informe/02_resumen_ejecutivo.md) | Problema, solucion y hallazgos |
| [Problema y KPIs](informe/03_problema_negocio.md) | Problema de negocio y preguntas analiticas |
| [KPIs Principales](informe/04_kpis.md) | 13 KPIs con formulas y criterios de interpretacion |
| [Arquitectura BI](informe/05_arquitectura.md) | 4 capas: OLTP → CDC → DW → Power BI |
| [Fuente OLTP](informe/06_oltp.md) | 9 tablas MySQL y su uso analitico |
| [Pipeline de Ingesta](informe/07_pipeline.md) | CDC Debezium + Kafka + 20 modelos dbt |
| [Data Warehouse](informe/08_datamart.md) | Modelo Constelacion con 3 facts y 6 dims |
| [Modelo Semantico](informe/09_modelo_semantico.md) | Relaciones Power BI, DAX y jerarquias |
| [Dashboard](informe/10_dashboard.md) | 3 tableros + comparativos YoY y MoM |
| [Sustentacion](informe/15_sustentacion.md) | Respuestas tecnicas + estructura PPT |
| [Evidencias](EVIDENCIA_PENDIENTE.md) | E-01 a E-18 con diagramas y consultas SQL |

## Como levantar la documentacion

```powershell
pip install -r requirements-docs.txt
mkdocs serve
```

## Repositorio

- **GitHub:** [ClaudioB12/CentroPsicologico-BI](https://github.com/ClaudioB12/CentroPsicologico-BI)
- **Equipo:** Claudio Bustinza · Josue Ochoa · Joel Huillca · Wilbert Mayta
