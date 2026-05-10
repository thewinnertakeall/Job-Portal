#!/bin/bash

echo "========================================="
echo "        RODHAD OBSERVABILITY PANEL"
echo "========================================="

echo ""
echo "[1] SYSTEM STATUS"
echo "-----------------------------------------"
uptime
echo ""
free -h
echo ""
df -h

echo ""
echo "[2] TOP PROCESSES (CPU)"
echo "-----------------------------------------"
ps aux --sort=-%cpu | head -10

echo ""
echo "[3] TOP PROCESSES (RAM)"
echo "-----------------------------------------"
ps aux --sort=-%mem | head -10

echo ""
echo "[4] DOCKER STATUS"
echo "-----------------------------------------"
docker ps

echo ""
echo "[5] DOCKER STATS"
echo "-----------------------------------------"
docker stats --no-stream

echo ""
echo "[6] NETWORK CONNECTIONS"
echo "-----------------------------------------"
ss -tunap | head -20

echo ""
echo "[7] POSTGRES ACTIVITY"
echo "-----------------------------------------"

DB=$(docker ps --format "{{.Names}}" | grep rodhad-db)

if [ -n "$DB" ]; then
  docker exec $DB psql -U postgres -d postgres -c "
  SELECT pid, usename, datname, state
  FROM pg_stat_activity;
  "
else
  echo "PostgreSQL container not found"
fi

echo ""
echo "[8] SIMPLE ANOMALY DETECTION"
echo "-----------------------------------------"

CPU_TOP=$(ps aux --sort=-%cpu | awk 'NR==2 {print $3}')

echo "CPU TOP PROCESS: $CPU_TOP %"

if (( $(echo "$CPU_TOP > 80" | bc -l) )); then
  echo "⚠ ALERT: HIGH CPU USAGE DETECTED"
  espeak "Warning high CPU usage detected"
fi

echo ""
echo "========================================="
echo "         END OBSERVABILITY"
echo "========================================="
