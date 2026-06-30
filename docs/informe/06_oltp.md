# 6. Fuente Transaccional OLTP

## 6.1 Descripcion del sistema OLTP

El sistema transaccional del Centro Psicologico Integral Guevara esta implementado en **MySQL 8.0** con la base de datos `dm_centro_psicologico`. El esquema contiene **9 tablas relacionales** que cubren la operacion clinica, administrativa y financiera del centro. El binlog ROW esta habilitado para que Debezium pueda capturar todos los cambios sin intervenir en las transacciones operativas.

## 6.2 Tablas utilizadas

| Tabla OLTP | Descripcion | Campos principales | Uso analitico |
|---|---|---|---|
| `sesiones` | Registra el agendamiento y estado clinico de cada cita terapeutica, incluyendo su resultado operativo (realizada, cancelada o no-show) | sesion_id, historia_id, psicologo_id, fecha_sesion, hora_sesion, nro_sesion, etapa_atencion, modalidad, duracion_min, estado_sesion | Fuente principal de FACT_Sesion. Soporta KPI 2, 3, 4, 5, 6 |
| `pagos` | Almacena los comprobantes de pago, montos cobrados y estado de las transacciones economicas por sesion | pago_id, sesion_id, fecha_pago, monto, metodo_pago, estado_pago | Fuente de FACT_Facturacion. Soporta KPI 1, 7, 10, 13 |
| `evaluacion_psicologica` | Registra los resultados de pruebas psicologicas aplicadas a los pacientes (CDI, STAI), vinculados a CIE-10 | evaluacion_id, sesion_id, metodos_aplicados, puntaje_cdi, puntaje_stai, fecha_evaluacion | Fuente exclusiva de FACT_Evaluacion. Soporta KPI 11 |
| `pacientes` | Consolida la informacion demografica, historica y el estado terapeutico actual de cada paciente | paciente_id, sede_id, nombres, fecha_nacimiento, sexo, canal_captacion, estado_paciente, modalidad_preferida | Fuente de DIM_Paciente. Soporta KPI 2 y KPI 4 |
| `psicologos` | Almacena el perfil profesional, especialidad y estado operativo del staff terapeutico | psicologo_id, sede_id, nombres, especialidad, cpp, modalidad, estado | Fuente de DIM_Psicologo. Soporta KPI 3 y KPI 7 |
| `historia_clinica` | Expediente clinico de cada paciente con tipo de historia y estado | historia_id, paciente_id, codigo_historia, tipo_historial, fecha_apertura, estado_historia | Join clave en staging: une pacientes con sesiones |
| `sedes` | Catalogo geografico de las instalaciones fisicas del centro en Juliaca | sede_id, nombre_sede, ciudad, tiene_online, estado | Fuente de DIM_Sede. Permite segmentacion geografica de ingresos |
| `diagnosticos` | Maestro de codigos estandarizados de salud mental bajo CIE-10 | diagnostico_id, sesion_id, codigo_cie10, descripcion_cie10, diagnostico_clinico | Fuente de DIM_Diagnostico. Soporta KPI 11 |
| `plan_intervencion` | Estructura de planes terapeuticos multisesion con objetivos e intervenciones | plan_id, sesion_id, objetivos, intervenciones, fecha_inicio, fecha_fin, estado_plan | Vinculacion extendida con DIM_Servicio |

## 6.3 Diagrama ER del esquema OLTP

Ver [Esquema OLTP MySQL](../diagrams/oltp_schema.md) para los diagramas ER completos divididos en:

- **Diagrama 1:** Jerarquia principal: `sedes → psicologos/pacientes → historia_clinica → sesiones`
- **Diagrama 2:** Tablas dependientes de sesion: `evaluacion_psicologica`, `diagnosticos`, `plan_intervencion`, `pagos`

## 6.4 Evidencia del origen

```sql
-- Conteos actuales en MySQL (datos reales del centro)
SELECT 'sedes'                  AS tabla, COUNT(*) AS filas FROM sedes
UNION ALL SELECT 'psicologos',  COUNT(*) FROM psicologos
UNION ALL SELECT 'pacientes',   COUNT(*) FROM pacientes
UNION ALL SELECT 'historia_clinica', COUNT(*) FROM historia_clinica
UNION ALL SELECT 'sesiones',    COUNT(*) FROM sesiones
UNION ALL SELECT 'evaluacion_psicologica', COUNT(*) FROM evaluacion_psicologica
UNION ALL SELECT 'diagnosticos', COUNT(*) FROM diagnosticos
UNION ALL SELECT 'plan_intervencion', COUNT(*) FROM plan_intervencion
UNION ALL SELECT 'pagos',       COUNT(*) FROM pagos;
```

| Tabla | Filas (datos reales) | Descripcion |
|---|---|---|
| sedes | 2 | Sede Fisica Juliaca + Sede Virtual Online |
| psicologos | 6 | Staff profesional activo |
| pacientes | 100 | Pacientes unicos registrados |
| historia_clinica | 100 | Expedientes (1:1 con pacientes) |
| sesiones | 71+ | Sesiones realizadas (71 atendidas) |
| evaluacion_psicologica | 15+ | Evaluaciones CDI/STAI aplicadas |
| diagnosticos | 30+ | Codigos CIE-10 asignados |
| plan_intervencion | 10+ | Planes terapeuticos |
| pagos | 71 | Comprobantes — ingresos brutos S/ 8,030 |

!!! note "Datos en el repositorio"
    El archivo `init.sql` en el repositorio contiene un **dataset de muestra reducido** para levantar el pipeline localmente. Los datos reales del centro son mas extensos y se gestionan directamente en el OLTP operacional.
