# Centro Psicologico BI

Este sitio MkDocs consolida el informe tecnico del proyecto **CentroPsicologico-BI** a partir de los archivos reales del repositorio.

## Contenido

- [Informe tecnico](informe_tecnico.md): inventario del proyecto, esquema OLTP, CDC, dbt, datamart, Power BI y hallazgos.
- [Arquitectura CDC y BI](diagrams/arquitectura.md): diagrama Mermaid del pipeline real.
- [Modelo dimensional](diagrams/modelo_dimensional.md): diagrama Mermaid ER del datamart.
- [Evidencia pendiente](EVIDENCIA_PENDIENTE.md): checklist de capturas requeridas para completar el informe.

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
