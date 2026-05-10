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
