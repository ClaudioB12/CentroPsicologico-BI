# Centro Psicológico Integral Guevara — Pipeline CDC (BI Local)

Pipeline de replicación en tiempo real: **MySQL → Kafka → PostgreSQL**  
Cada cambio en MySQL (INSERT / UPDATE / DELETE) se propaga automáticamente a PostgreSQL en ~3-5 segundos.

---

## Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PIPELINE CDC                                  │
│                                                                       │
│  MySQL (OLTP)  ──►  Debezium  ──►  Kafka  ──►  JDBC Sink  ──►  PostgreSQL │
│   puerto 3306        (CDC)       puerto 9092               puerto 5432    │
│                                                                       │
│  Monitoreo:  Kafka UI → localhost:8080                               │
│  PostgreSQL: pgAdmin  → localhost:5050                               │
└─────────────────────────────────────────────────────────────────────┘
```

### Contenedores y puertos

| Contenedor | Puerto | Descripción |
|------------|--------|-------------|
| `centro_psicologico_db` | 3306 | MySQL 8.0 — fuente OLTP con binlog ROW |
| `centro_psicologico_postgres` | 5432 | PostgreSQL 15 — réplica destino BI |
| `zookeeper` | — | Coordinación interna de Kafka |
| `kafka` | 9092 | Broker de mensajes Kafka |
| `kafka_connect` | 8083 | Kafka Connect REST API (Debezium + JDBC) |
| `kafka_ui` | 8080 | Kafka UI — monitoreo visual |
| `pgadmin` | 5050 | pgAdmin 4 — interfaz visual PostgreSQL |

---

## Requisitos previos

- Docker Desktop instalado y corriendo
- Docker Compose (incluido en Docker Desktop)
- Mínimo 8 GB de RAM disponibles para Docker
- Puertos 3306, 5432, 8080, 8083, 5050 libres

---

## Estructura de archivos

```
CentroPsicologico-bi-local/
├── docker-compose.yml              # Orquestación de todos los servicios
├── Dockerfile                      # Imagen custom de MySQL
├── init.sql                        # Schema y datos iniciales (MySQL)
├── init-debezium.sql               # Usuario de replicación Debezium
├── kafka-connect/
│   └── Dockerfile                  # Imagen Kafka Connect + plugins
├── connectors/
│   ├── mysql-source.json           # Config conector MySQL → Kafka
│   └── postgres-sink.json          # Config conector Kafka → PostgreSQL
└── scripts/
    └── register-connectors.sh      # Script de registro automático
```

---

## Paso a paso — Primera vez (instalación completa)

### Paso 1 — Clonar o copiar el proyecto

Asegúrate de tener todos los archivos en una carpeta local, por ejemplo:
```
D:\INTELIGENCIA DE NEGOCIOS\CentroPsicologico-bi-local\
```

Verifica que existan los archivos:
```powershell
ls "D:\INTELIGENCIA DE NEGOCIOS\CentroPsicologico-bi-local"
```
Debes ver: `docker-compose.yml`, `Dockerfile`, `init.sql`, `init-debezium.sql`, carpeta `kafka-connect/`, `connectors/`, `scripts/`.

---

### Paso 2 — Construir la imagen personalizada de Kafka Connect

Este paso descarga e instala los plugins de Debezium MySQL y JDBC sink.  
**Tarda entre 3 y 8 minutos** (necesita internet).

```powershell
cd "D:\INTELIGENCIA DE NEGOCIOS\CentroPsicologico-bi-local"
docker-compose build kafka-connect
```

Verifica que termine con:
```
centropsicologico-bi-local-kafka-connect  Built
```

> **Plugins que instala:**
> - `debezium/debezium-connector-mysql:2.4.2` — captura cambios de MySQL
> - `confluentinc/kafka-connect-jdbc:10.9.3` — escribe en PostgreSQL
> - Driver JDBC de PostgreSQL 42.7.4

---

### Paso 3 — Levantar Zookeeper (primero)

Zookeeper debe estar `healthy` antes de iniciar Kafka.

```powershell
cd "D:\INTELIGENCIA DE NEGOCIOS\CentroPsicologico-bi-local"
docker-compose up -d zookeeper
```

Espera hasta que el estado sea `healthy`:
```powershell
docker ps --filter "name=zookeeper" --format "{{.Status}}"
```
Debe mostrar: `Up X minutes (healthy)` — puede tardar hasta 30 segundos.

**Captura de pantalla ETL — Etapa infraestructura:**  
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}"
```

---

### Paso 4 — Levantar MySQL y PostgreSQL

```powershell
docker-compose up -d db postgres pgadmin
```

Espera a que ambas bases de datos estén `healthy`:
```powershell
docker ps --filter "name=centro" --format "table {{.Names}}\t{{.Status}}"
```
Debe mostrar `(healthy)` en ambas.

**Verifica MySQL:**
```powershell
docker exec centro_psicologico_db mysqladmin ping -u root -prootpassword
```
Respuesta esperada: `mysqld is alive`

**Verifica PostgreSQL:**
```powershell
docker exec centro_psicologico_postgres pg_isready -U postgres
```
Respuesta esperada: `localhost:5432 - accepting connections`

---

### Paso 5 — Levantar Kafka y Kafka UI

```powershell
docker-compose up -d kafka kafka-ui
```

Espera hasta que Kafka esté `healthy` (puede tardar 1-2 minutos):
```powershell
docker ps --filter "name=kafka" --format "table {{.Names}}\t{{.Status}}"
```

**Captura de pantalla ETL — Etapa broker:**  
Abre [http://localhost:8080](http://localhost:8080) → debe aparecer el cluster `CentroPsicologico-CDC`.

---

### Paso 6 — Levantar Kafka Connect

```powershell
docker-compose up -d kafka-connect
```

Kafka Connect tarda **~90 segundos** en inicializar el worker. Espera a que responda:
```powershell
# Repetir hasta que devuelva "[]" (lista vacía de conectores)
curl http://localhost:8083/connectors
```

O con PowerShell:
```powershell
do {
    Start-Sleep -Seconds 10
    $r = try { Invoke-RestMethod http://localhost:8083/connectors } catch { $null }
    Write-Host "Estado: $(if($r -ne $null){'LISTO'}else{'Iniciando...'})"
} until ($r -ne $null)
```

---

### Paso 7 — Registrar el conector MySQL (source)

```powershell
Invoke-RestMethod -Method POST -Uri "http://localhost:8083/connectors" `
  -ContentType "application/json" `
  -InFile "D:\INTELIGENCIA DE NEGOCIOS\CentroPsicologico-bi-local\connectors\mysql-source.json"
```

Verifica que esté `RUNNING`:
```powershell
Invoke-RestMethod "http://localhost:8083/connectors/mysql-source-connector/status" | ConvertTo-Json
```
Debes ver: `"state": "RUNNING"` en `connector` y en `tasks[0]`.

**Captura de pantalla ETL — Etapa extracción:**  
Abre [http://localhost:8080](http://localhost:8080) → Topics → verás topics nuevos como `centro.dm_centro_psicologico.oltp_sedes`.

---

### Paso 8 — Registrar el conector PostgreSQL (sink)

Espera 10 segundos para que Debezium complete el snapshot inicial, luego:

```powershell
Invoke-RestMethod -Method POST -Uri "http://localhost:8083/connectors" `
  -ContentType "application/json" `
  -InFile "D:\INTELIGENCIA DE NEGOCIOS\CentroPsicologico-bi-local\connectors\postgres-sink.json"
```

Verifica que esté `RUNNING`:
```powershell
Invoke-RestMethod "http://localhost:8083/connectors/postgres-sink-connector/status" | ConvertTo-Json
```

---

### Paso 9 — Verificar replicación de datos

Espera ~15 segundos y verifica que las 11 tablas aparezcan en PostgreSQL:

```powershell
docker exec centro_psicologico_postgres psql -U postgres -d dm_centro_psicologico -c "\dt"
```

Debes ver:
```
DIM_Paciente, DIM_Psicologo, DIM_Sede, DIM_Servicio, DIM_Tiempo
FACT_Facturacion, FACT_Sesion
oltp_pacientes, oltp_psicologos, oltp_sedes, oltp_sesiones
```

Compara conteos MySQL vs PostgreSQL:
```powershell
Write-Host "=== MYSQL ==="
docker exec centro_psicologico_db mysql -u root -prootpassword dm_centro_psicologico `
  -e "SELECT 'oltp_sedes' t, COUNT(*) n FROM oltp_sedes UNION ALL SELECT 'oltp_pacientes', COUNT(*) FROM oltp_pacientes UNION ALL SELECT 'oltp_sesiones', COUNT(*) FROM oltp_sesiones;" 2>$null

Write-Host "=== POSTGRESQL ==="
docker exec centro_psicologico_postgres psql -U postgres -d dm_centro_psicologico `
  -c "SELECT 'oltp_sedes' t, COUNT(*) n FROM oltp_sedes UNION ALL SELECT 'oltp_pacientes', COUNT(*) FROM oltp_pacientes UNION ALL SELECT 'oltp_sesiones', COUNT(*) FROM oltp_sesiones;"
```

Los números deben ser **idénticos**.

---

### Paso 10 — Conectar pgAdmin a PostgreSQL

1. Abre [http://localhost:5050](http://localhost:5050)
2. Login: `admin@centro.com` / `adminpassword`
3. Panel izquierdo → **click derecho en "Servers"** → **Register → Server...**
4. Pestaña **General**:
   - Name: `CentroPsicologico CDC`
5. Pestaña **Connection**:
   - Host name/address: `postgres`  ← debe ser `postgres`, NO `localhost`
   - Port: `5432`
   - Maintenance database: `dm_centro_psicologico`
   - Username: `postgres`
   - Password: `postgrespassword`
   - Activar: "Save password"
6. Click **Save**
7. Navega: `CentroPsicologico CDC → Databases → dm_centro_psicologico → Schemas → public → Tables`

**Captura de pantalla ETL — Etapa carga:**  
Verás las 11 tablas replicadas desde MySQL.

---

### Paso 11 — Probar CDC en tiempo real

**Test INSERT:**
```powershell
# Insertar en MySQL
docker exec centro_psicologico_db mysql -u root -prootpassword dm_centro_psicologico `
  -e "INSERT INTO oltp_sedes (nombre_sede, ciudad, tiene_online) VALUES ('Sede Test CDC', 'Lima', 1);" 2>$null

# Esperar 5 segundos
Start-Sleep -Seconds 5

# Verificar en PostgreSQL
docker exec centro_psicologico_postgres psql -U postgres -d dm_centro_psicologico `
  -c "SELECT sede_id, nombre_sede, ciudad FROM oltp_sedes ORDER BY sede_id;"
```

**Test UPDATE:**
```powershell
# Actualizar en MySQL
docker exec centro_psicologico_db mysql -u root -prootpassword dm_centro_psicologico `
  -e "UPDATE oltp_sedes SET ciudad='Miraflores' WHERE nombre_sede='Sede Test CDC';" 2>$null

Start-Sleep -Seconds 5

# Verificar en PostgreSQL — debe mostrar 'Miraflores'
docker exec centro_psicologico_postgres psql -U postgres -d dm_centro_psicologico `
  -c "SELECT sede_id, nombre_sede, ciudad FROM oltp_sedes ORDER BY sede_id;"
```

---

## Uso diario — Iniciar y detener

### Iniciar todo (próximas veces)

El paso de `build` solo se necesita la primera vez. Para iniciar normalmente:

```powershell
cd "D:\INTELIGENCIA DE NEGOCIOS\CentroPsicologico-bi-local"

# 1. Zookeeper primero
docker-compose up -d zookeeper
Start-Sleep -Seconds 20

# 2. Resto de servicios
docker-compose up -d db postgres pgadmin kafka kafka-ui kafka-connect

# 3. Esperar Kafka Connect (~90s) y registrar conectores
Start-Sleep -Seconds 100
Invoke-RestMethod -Method POST -Uri "http://localhost:8083/connectors" -ContentType "application/json" -InFile ".\connectors\mysql-source.json"
Start-Sleep -Seconds 8
Invoke-RestMethod -Method POST -Uri "http://localhost:8083/connectors" -ContentType "application/json" -InFile ".\connectors\postgres-sink.json"
```

> **Nota:** Los conectores deben re-registrarse cada vez que Kafka Connect reinicia desde cero. Si los volúmenes Docker persisten, los conectores pueden sobrevivir al reinicio.

### Verificar estado

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Verificar conectores activos

```powershell
Invoke-RestMethod "http://localhost:8083/connectors?expand=status" | ConvertTo-Json -Depth 5
```

### Detener todo (preserva datos)

```powershell
cd "D:\INTELIGENCIA DE NEGOCIOS\CentroPsicologico-bi-local"
docker-compose down
```

### Detener y borrar todos los datos (reset completo)

```powershell
docker-compose down -v
```

---

## Monitoreo visual — Capturas de pantalla ETL

### Kafka UI — Ver mensajes en tiempo real
- URL: [http://localhost:8080](http://localhost:8080)
- Cluster: `CentroPsicologico-CDC`
- Topics → `centro.dm_centro_psicologico.oltp_sedes` → Messages  
  (cada INSERT/UPDATE en MySQL aparece como un mensaje Kafka)
- Kafka Connect → Connectors → verás ambos conectores en verde

### pgAdmin — Ver datos en PostgreSQL
- URL: [http://localhost:5050](http://localhost:5050)
- Servidor: `CentroPsicologico CDC` (ver Paso 10)
- Query Tool → `SELECT * FROM oltp_pacientes LIMIT 10;`

### Kafka Connect REST API — Estado de conectores
```powershell
# Listar conectores
Invoke-RestMethod "http://localhost:8083/connectors"

# Estado conector MySQL
Invoke-RestMethod "http://localhost:8083/connectors/mysql-source-connector/status"

# Estado conector PostgreSQL
Invoke-RestMethod "http://localhost:8083/connectors/postgres-sink-connector/status"
```

---

## Credenciales de referencia

| Servicio | Usuario | Contraseña | Host (interno Docker) |
|----------|---------|------------|----------------------|
| MySQL | `root` | `rootpassword` | `db` |
| MySQL CDC user | `debezium` | `dbzpassword` | `db` |
| PostgreSQL | `postgres` | `postgrespassword` | `postgres` |
| pgAdmin | `admin@centro.com` | `adminpassword` | — |

---

## Solución de problemas frecuentes

### Kafka Connect no responde en puerto 8083
El worker tarda hasta 2 minutos en iniciar. Espera y vuelve a intentar:
```powershell
curl http://localhost:8083/connectors
```

### Conector en estado FAILED
```powershell
# Ver el error
Invoke-RestMethod "http://localhost:8083/connectors/mysql-source-connector/status" | ConvertTo-Json

# Reiniciar el conector
Invoke-RestMethod -Method POST "http://localhost:8083/connectors/mysql-source-connector/restart"
```

### pgAdmin no conecta con host "postgres"
- Asegúrate de usar `postgres` (nombre del servicio Docker), no `localhost`
- El puerto es `5432`, no otro
- Verifica que el contenedor esté corriendo: `docker ps | findstr postgres`

### Zookeeper permanece `unhealthy`
```powershell
docker-compose down zookeeper
docker-compose up -d zookeeper
# Esperar 30 segundos
docker inspect zookeeper --format '{{.State.Health.Status}}'
```

### Tablas no aparecen en PostgreSQL después de registrar conectores
El snapshot inicial puede tardar 1-2 minutos si hay muchos datos. Verifica:
```powershell
# Ver logs del conector
docker logs kafka_connect --tail 50
```

---

## Tablas replicadas

| Tabla | Descripción |
|-------|-------------|
| `oltp_sedes` | Sedes físicas y online |
| `oltp_psicologos` | Equipo terapéutico |
| `oltp_pacientes` | Registro de pacientes |
| `oltp_sesiones` | Sesiones clínicas |
| `DIM_Tiempo` | Dimensión calendario |
| `DIM_Paciente` | Dimensión paciente (anonimizado) |
| `DIM_Psicologo` | Dimensión psicólogo |
| `DIM_Sede` | Dimensión sede |
| `DIM_Servicio` | Dimensión tipo de servicio |
| `FACT_Sesion` | Hechos de sesiones clínicas |
| `FACT_Facturacion` | Hechos de facturación/pagos |
