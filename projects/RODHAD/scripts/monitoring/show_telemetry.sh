#!/bin/bash

echo "========================================="
echo "        RODHAD TELEMETRY VIEWER"
echo "========================================="

DB_CONTAINER=$(docker ps --format "{{.Names}}" | grep rodhad-db)

if [ -z "$DB_CONTAINER" ]; then
    echo "ERROR: PostgreSQL container not found."
    exit 1
fi

POSTGRES_USER=$(docker inspect $DB_CONTAINER | grep POSTGRES_USER | head -1 | cut -d '"' -f4)

if [ -z "$POSTGRES_USER" ]; then
    POSTGRES_USER=postgres
fi

echo ""
echo "DATABASE CONTAINER:"
echo "$DB_CONTAINER"

echo ""
echo "POSTGRES USER:"
echo "$POSTGRES_USER"

echo ""
echo "========================================="
echo "         TELEMETRY DATA"
echo "========================================="

docker exec -it $DB_CONTAINER psql \
-U $POSTGRES_USER \
-d rodhad_simulation \
-c "SELECT * FROM telemetry ORDER BY id DESC LIMIT 50;"

echo ""
echo "========================================="
echo "      END OF TELEMETRY DATA"
echo "========================================="
