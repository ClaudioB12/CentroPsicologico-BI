# 2. Resumen Ejecutivo

El presente proyecto academico-profesional expone el diseno, implementacion y validacion de una solucion integral de Business Intelligence y Analytics Engineering para el **Centro Psicologico Integral Guevara**, institucion de salud mental ubicada en la ciudad de Juliaca, Peru.

## Problema central

El problema central identificado es la **fragmentacion operativa de los datos clinicos, administrativos y financieros** del centro, distribuidos en registros manuales, hojas de calculo aisladas y un sistema de historia clinica basico que imposibilita la correlacion entre variables operativas y flujos economicos para la toma de decisiones basada en evidencia.

## Solucion implementada

La solucion implementada despliega un pipeline de datos moderno y completamente contenedorizado:

```
MySQL → Debezium + Kafka → PostgreSQL → dbt → Power BI
```

Se materializa un **modelo dimensional de tipo Constelacion** con tres tablas de hechos que comparten dimensiones conformadas:

| Tabla de hecho | Descripcion |
|---|---|
| `FACT_Sesion` | Sesiones terapeuticas programadas y su resultado operativo |
| `FACT_Facturacion` | Comprobantes de pago emitidos y conciliados |
| `FACT_Evaluacion` | Evaluaciones psicologicas aplicadas con codigos CIE-10 |

Las **dimensiones conformadas** compartidas son: DIM_Paciente, DIM_Psicologo, DIM_Servicio, DIM_Sede y DIM_Tiempo. La dimension especializada DIM_Diagnostico esta vinculada exclusivamente a FACT_Evaluacion.

## Resultados de la validacion

La validacion del sistema arrojo conciliacion exacta entre la capa fisica del DataMart y el modelo semantico en Power BI, procesando la muestra operativa:

| Metrica | Valor |
|---|---|
| Sesiones atendidas | 71 |
| Ingresos brutos | S/ 8,030.00 |
| Margen bruto promedio | 49.94% |
| Pacientes unicos registrados | 100 |

## Principales hallazgos analiticos

Los hallazgos analiticos revelan:

1. **Subutilizacion de agenda** en la sede Juliaca vinculada a una tasa de cancelaciones imprevistas
2. **Asimetrias en la rentabilidad** por tipo de servicio psicologico
3. **Desequilibrios en la carga de atencion** por profesional

## Recomendacion estrategica principal

El equipo propone el **despliegue inmediato de campanas automatizadas de reenganche psicoterapeutico**, fundamentadas en la Tasa de Abandono Terapeutico calculada sobre `FACT_Sesion`, complementadas por politicas de optimizacion de agenda orientadas a reducir la capacidad instalada ociosa detectada mediante el KPI de Tasa de Ocupacion en los horarios de menor afluencia registrados en el dashboard operativo.
