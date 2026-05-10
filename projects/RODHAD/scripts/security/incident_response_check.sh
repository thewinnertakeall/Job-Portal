#!/bin/bash

echo "========================================="
echo "      RODHAD INCIDENT RESPONSE"
echo "========================================="

echo ""
echo "[1] DOCKER CONTAINERS"
docker ps

echo ""
echo "========================================="
echo "[2] ACTIVE CONNECTIONS"
echo "========================================="
ss -tunap

echo ""
echo "========================================="
echo "[3] CPU / RAM TOP PROCESSES"
echo "========================================="
ps aux --sort=-%cpu | head -15

echo ""
echo "========================================="
echo "[4] DOCKER RESOURCE USAGE"
echo "========================================="
docker stats --no-stream

echo ""
echo "========================================="
echo "[5] FAILED LOGINS"
echo "========================================="

if [ -f /var/log/auth.log ]; then
    sudo tail -20 /var/log/auth.log
else
    echo "auth.log not available in WSL"
fi

echo ""
echo "========================================="
echo "[6] SUSPICIOUS NETWORK CONNECTIONS"
echo "========================================="
ss -antp | grep ESTAB

echo ""
echo "========================================="
echo "[7] POSTGRES CONNECTIONS"
echo "========================================="

DB_CONTAINER=$(docker ps --format "{{.Names}}" | grep rodhad-db)

if [ -n "$DB_CONTAINER" ]; then

    POSTGRES_USER=$(docker exec $DB_CONTAINER env | grep POSTGRES_USER | cut -d '=' -f2)

    if [ -z "$POSTGRES_USER" ]; then
        POSTGRES_USER=rodhad
    fi

    docker exec -it $DB_CONTAINER psql -U $POSTGRES_USER -d postgres -c "
    SELECT pid, usename, datname, client_addr, state
    FROM pg_stat_activity;
    "

else
    echo "PostgreSQL container not found."
fi

echo ""
echo "========================================="
echo "[8] DOCKER LOGS"
echo "========================================="

for container in $(docker ps --format "{{.Names}}")
do
    echo ""
    echo "----- $container -----"
    docker logs --tail 10 $container
done

echo ""
echo "========================================="
echo "[9] DISK USAGE"
echo "========================================="
df -h

echo ""
echo "========================================="
echo "[10] MEMORY"
echo "========================================="
free -h

echo ""
echo "========================================="
echo " INCIDENT RESPONSE CHECK COMPLETE"
echo "========================================="

