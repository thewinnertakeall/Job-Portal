#!/bin/bash

echo "========================================"
echo "      RODHAD DOCKER HARDENING"
echo "========================================"

cd ~/projects/RODHAD || exit

echo ""
echo "[1/7] BACKUP docker-compose.yml"

cp docker-compose.yml docker-compose.yml.bak

echo ""
echo "[2/7] REMOVING EXPOSED POSTGRES PORTS"

sed -i '/5432:5432/d' docker-compose.yml

echo ""
echo "[3/7] CREATING INTERNAL NETWORK"

if ! docker network ls | grep -q rodhad_internal; then
    docker network create rodhad_internal
fi

echo ""
echo "[4/7] ADDING SECURITY SETTINGS"

cat >> docker-compose.yml << 'EON'

networks:
  rodhad_internal:
    external: true
EON

echo ""
echo "[5/7] RESTARTING DOCKER STACK"

docker compose down

docker compose up -d

echo ""
echo "[6/7] CHECKING POSTGRES EXPOSURE"

sleep 5

echo ""
echo "POSTGRES STATUS:"
ss -tunap | grep 5432 || true

echo ""
echo "[7/7] CREATING SECURITY MONITOR"

cat > ~/projects/RODHAD/scripts/security/live_security_monitor.sh << 'EOM'
#!/bin/bash

CPU_LIMIT=85
MEM_LIMIT=85

while true
do
    clear

    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')

    MEM=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

    CONNECTIONS=$(ss -tunap | wc -l)

    echo "======================================="
    echo "      RODHAD SECURITY MONITOR"
    echo "======================================="

    echo ""
    echo "CPU: $CPU%"
    echo "RAM: $MEM%"
    echo "CONNECTIONS: $CONNECTIONS"

    echo ""
    echo "=========== USERS ==========="
    who

    echo ""
    echo "=========== DOCKER ==========="
    docker stats --no-stream

    echo ""
    echo "=========== CONNECTIONS ==========="
    ss -tunap | head -20

    echo ""
    echo "=========== TOP PROCESSES ==========="
    ps aux --sort=-%mem | head -10

    echo ""
    echo "=========== ALERTS ==========="

    if [ "$CPU" -gt "$CPU_LIMIT" ]; then
        echo "[WARNING] HIGH CPU USAGE"

        espeak "Warning. High CPU usage detected" 2>/dev/null
    fi

    if [ "$MEM" -gt "$MEM_LIMIT" ]; then
        echo "[WARNING] HIGH MEMORY USAGE"

        espeak "Warning. High memory usage detected" 2>/dev/null
    fi

    if [ "$CONNECTIONS" -gt 250 ]; then
        echo "[WARNING] TOO MANY CONNECTIONS"

        espeak "Warning. Too many connections detected" 2>/dev/null
    fi

    sleep 5
done
EOM

chmod +x ~/projects/RODHAD/scripts/security/live_security_monitor.sh

echo ""
echo "========================================"
echo "         HARDENING COMPLETE"
echo "========================================"

echo ""
echo "RUN MONITOR:"
echo "~/projects/RODHAD/scripts/security/live_security_monitor.sh"

echo ""
echo "VERIFY POSTGRES:"
echo "ss -tunap | grep 5432"

echo ""
echo "IF EMPTY = PROTECTED"
echo "========================================"
