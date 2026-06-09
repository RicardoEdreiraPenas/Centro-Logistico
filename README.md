# Centro Logístico — Ejercicio End2End AWS

Pipeline end-to-end en AWS que simula un centro logístico con camiones (tractora + remolque), órdenes de carga/descarga con palets, asignación a 10 muelles y seguimiento en tiempo real.

## Stack

| Componente | Servicio AWS |
|---|---|
| OLTP | RDS PostgreSQL (schema `public`) |
| Mensajería | Amazon SQS |
| Data Warehouse | RDS PostgreSQL (schemas `logistics` + `dock_events`) |
| Transformaciones | dbt-postgres |
| Visualización | Metabase (docker) |

## Arquitectura

````
truck_app → SQS: truck-events → dock_app → RDS: dock_events.raw_events_dock
    │
    ▼ RDS PostgreSQL (schema: public)
 trucks / docks / assignments / truck_orders
    │
    ▼ EL pipeline (60s)
 RDS PostgreSQL (schema: logistics)
    │
    ▼ dbt → logistics_mart.* / dock_events_mart.*
    │
    ▼ Metabase (localhost:3000)
````

## Modelo de datos RDS (schema: public — OLTP)

```sql
-- Identificación del camión
trucks: id, tractora_plate (NNNN-LLL), remolque_plate (R-LNNNN),
        origin_city, origin_client, dest_city, dest_client,
        arrived_at, departed_at

-- 10 muelles fijos (IDs 1-10)
docks: id, status ('available' | 'occupied')

-- Asignación muelle-camión
assignments: id, truck_id, dock_id, assigned_at, released_at

-- Órdenes de carga o descarga
truck_orders: id, truck_id, assignment_id,
              order_type ('loading' | 'unloading'),
              cargo_desc, weight_kg, num_pallets,
              sequence (1=descarga, 2=carga),
              status ('pending' | 'in_progress' | 'completed')
```

## Infraestructura con Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## RDS — Crear schemas y tablas analíticas

Conéctate a RDS (`postgres` DB) y ejecuta:

```sql
CREATE SCHEMA IF NOT EXISTS logistics;
CREATE SCHEMA IF NOT EXISTS dock_events;

CREATE TABLE IF NOT EXISTS logistics.trucks (
    id INT, tractora_plate VARCHAR(10), remolque_plate VARCHAR(10),
    origin_city VARCHAR(50), origin_client VARCHAR(100),
    dest_city VARCHAR(50), dest_client VARCHAR(100),
    arrived_at TIMESTAMP, departed_at TIMESTAMP
);
CREATE TABLE IF NOT EXISTS logistics.docks (id INT, status VARCHAR(20));
CREATE TABLE IF NOT EXISTS logistics.assignments (
    id INT, truck_id INT, dock_id INT,
    assigned_at TIMESTAMP, released_at TIMESTAMP
);
CREATE TABLE IF NOT EXISTS logistics.truck_orders (
    id INT, truck_id INT, assignment_id INT,
    order_type VARCHAR(20), cargo_desc VARCHAR(200),
    weight_kg FLOAT, num_pallets INT, sequence INT, status VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS dock_events.raw_events_dock (
    id BIGSERIAL PRIMARY KEY,
    truck_id INT, order_id INT, order_type VARCHAR(20),
    tractora_plate VARCHAR(10), remolque_plate VARCHAR(10),
    dock_id INT, cargo_desc VARCHAR(200),
    num_pallets INT, weight_kg FLOAT,
    status VARCHAR(20), event_at TIMESTAMP
);
```

## Variables de entorno necesarias

```bash
export RDS_HOST=database-1.ct6susew4fc5.eu-west-3.rds.amazonaws.com
export RDS_PORT=5432
export RDS_USER=postgres
export RDS_PASSWORD=edem2526
export RDS_DB=postgres

export AWS_REGION=eu-west-3
```

## Ejecutar las apps (en EC2 o local)

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

### truck-app
```bash
nohup bash -c 'python -m truck_app.main' > truck.log 2>&1 &
tail -f truck.log
```

### dock-app
```bash
nohup bash -c 'python -m dock_app.main' > dock.log 2>&1 &
tail -f dock.log
```

### EL pipeline
```bash
python -m analytical_layer.el_logistics.main
```

## dbt

```bash
pip install dbt-postgres
# Configura ~/.dbt/profiles.yml con tu conexión RDS
cd analytical_layer/dbt_template/edem_project

dbt run --select base_trucks base_docks base_assignments base_truck_orders
dbt run --select base_raw_events_dock
dbt run --select expanded_dock_events trucks_at_docks truck_entry_exit_order
```

### Modelos

| Modelo | Qué responde |
|--------|-------------|
| `trucks_at_docks` | Qué camión está en qué muelle y qué operación hace ahora |
| `expanded_dock_events` | Histórico con palets, peso, origen/destino |
| `truck_entry_exit_order` | Ranking de entrada y salida de camiones |

## Metabase

```bash
cd analytical_layer && docker-compose up -d
```

Accede en `http://localhost:3000` y conecta a RDS PostgreSQL con las credenciales anteriores.
