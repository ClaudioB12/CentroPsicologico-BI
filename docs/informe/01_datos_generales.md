# 1. Datos Generales del Proyecto

## Ficha del proyecto

| Campo | Descripcion |
|---|---|
| **Nombre del proyecto BI** | Sistema de Business Intelligence para el Centro Psicologico Integral Guevara |
| **Proceso de negocio analizado** | Gestion clinica-operativa de sesiones psicologicas y flujos de facturacion/pagos financieros |
| **Fuente transaccional** | Sistema OLTP en MySQL 8.0 — base de datos `dm_centro_psicologico` |
| **Link repositorio GitHub** | [ClaudioB12/CentroPsicologico-BI](https://github.com/ClaudioB12/CentroPsicologico-BI.git) |
| **Link sitio MkDocs** | [claudiob12.github.io/CentroPsicologico-BI](https://claudiob12.github.io/CentroPsicologico-BI/) |

## Equipo

| Integrante | Rol principal |
|---|---|
| Claudio Bustinza Inofuente | Pipeline CDC, arquitectura Docker, dbt staging y marts |
| Josue Gabriel Ochoa Mamani | Modelo dimensional, dbt marts, documentacion MkDocs |
| Joel Huillca Lima | Modelo semantico Power BI, medidas DAX, dashboards |
| Wilbert Alex Mayta Arotaype | Validacion de KPIs, SQL de conciliacion, evidencias |

## Componentes y herramientas

| Componente | Herramienta / tecnologia | Estado |
|---|---|---|
| OLTP | MySQL 8.0 — binlog ROW habilitado | Completo |
| Ingesta | Debezium 2.4.2 + Apache Kafka 7.5.0 | Completo |
| DW / DataMart | PostgreSQL 15 — schemas raw, staging, datamart | Completo |
| Transformacion | dbt 1.12.0b1 — 20 modelos | Completo |
| Modelo semantico | Power BI Desktop — Import Mode | Completo |
| Dashboard | Power BI — 3 tableros + reporte de pacientes | Completo |
| Validacion | SQL sobre schema datamart + dbt test | Completo |
| Documentacion | MkDocs Material + GitHub Pages | Completo |

!!! info "Repositorio equivalente al del curso"
    El repositorio contiene codigo fuente, archivos de configuracion Docker, conectores Kafka, modelos dbt, el archivo Power BI `.pbix` y esta carpeta `docs/` con la documentacion MkDocs completa.
