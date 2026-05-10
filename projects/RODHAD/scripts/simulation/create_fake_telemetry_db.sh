#!/bin/bash

echo "========================================="
echo "     RODHAD TELEMETRY SIMULATION"
echo "========================================="

echo ""
echo "[1/6] DETECTING POSTGRES CONTAINER..."

DB_CONTAINER=$(docker ps --format "{{.Names}}" | grep rodhad-db)

echo "CONTAINER:"
echo "$DB_CONTAINER"

echo ""
echo "[2/6] DETECTING POSTGRES USER..."

POSTGRES_USER=$(docker inspect $DB_CONTAINER | grep POSTGRES_USER | head -1 | cut -d '"' -f4)

if [ -z "$POSTGRES_USER" ]; then
    POSTGRES_USER=postgres
fi

echo "POSTGRES USER:"
echo "$POSTGRES_USER"

echo ""
echo "[3/6] CREATING SIMULATION DATABASE..."

docker exec -i $DB_CONTAINER psql -U $POSTGRES_USER << 'EOSQL'

CREATE DATABASE rodhad_simulation;

EOSQL

echo ""
echo "[4/6] CREATING TELEMETRY TABLE..."

docker exec -i $DB_CONTAINER psql -U $POSTGRES_USER -d rodhad_simulation << 'EOSQL'

CREATE TABLE IF NOT EXISTS telemetry (
    id SERIAL PRIMARY KEY,
    cpu_usage FLOAT,
    ram_usage FLOAT,
    requests INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

EOSQL

echo ""
echo "[5/6] INSERTING NORMAL DATA..."

docker exec -i $DB_CONTAINER psql -U $POSTGRES_USER -d rodhad_simulation << 'EOSQL'

INSERT INTO telemetry
(cpu_usage, ram_usage, requests)
VALUES
(20,30,100),
(22,35,120),
(25,40,140),
(18,28,90),
(24,38,110);

EOSQL

echo ""
echo "[6/6] INSERTING ANOMALY DATA..."

docker exec -i $DB_CONTAINER psql -U $POSTGRES_USER -d rodhad_simulation << 'EOSQL'

INSERT INTO telemetry
(cpu_usage, ram_usage, requests)
VALUES
(99,99,50000);

EOSQL

echo ""
echo "========================================="
echo "      SIMULATION DATABASE READY"
echo "========================================="

echo ""
echo "CONNECT MANUALLY:"
echo "docker exec -it $DB_CONTAINER psql -U $POSTGRES_USER -d rodhad_simulation"

echo ""
echo "SHOW DATA:"
echo "SELECT * FROM telemetry;"

echo "========================================="
