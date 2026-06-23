# Centro Psicologico BI

Este sitio consolida el informe tecnico del proyecto **CentroPsicologico-BI**: un pipeline de inteligencia de negocios local con CDC, dbt y Power BI para un centro psicologico.

## Contenido

- [Informe tecnico](informe_tecnico.md): inventario del proyecto, esquema OLTP, CDC, dbt, datamart y hallazgos.
- [Arquitectura CDC y BI](diagrams/arquitectura.md): pipeline completo MySQL → Kafka → PostgreSQL → dbt → BI e infraestructura Docker.
- [Lineaje dbt](diagrams/lineaje_dbt.md): dependencias entre capas raw → staging → dimensiones y hechos.
- [Esquema OLTP MySQL](diagrams/oltp_schema.md): diagrama ER del esquema operacional `dm_centro_psicologico`.
- [Modelo dimensional](diagrams/modelo_dimensional.md): diagrama ER del datamart (esquema estrella con 3 facts y 6 dims).
- [Evidencia pendiente](EVIDENCIA_PENDIENTE.md): checklist de capturas requeridas para completar el informe.

## Resumen del pipeline

```
MySQL 8.0 (OLTP)
  └─ Debezium CDC → Kafka → JDBC Sink
       └─ PostgreSQL schema raw
            └─ dbt staging (9 modelos stg_*)
                 └─ dbt datamart (6 dims + 3 facts)
                      └─ dbt exposures → Power BI
```

## Como levantar la documentacion

Instalar dependencias:

```powershell
python -m pip install -r requirements-docs.txt
```

Ejecutar servidor local:

```powershell
mkdocs serve
```

Generar HTML estatico:

```powershell
mkdocs build
```

El sitio generado queda en `site/`.
