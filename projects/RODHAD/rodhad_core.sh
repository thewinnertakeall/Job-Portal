#!/bin/bash

LOG_FILE="logs/rodhad.log"

mkdir -p logs

echo "========================" | tee -a $LOG_FILE
echo " RODHAD CORE INICIADO " | tee -a $LOG_FILE
echo "========================" | tee -a $LOG_FILE

while true
do
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    
    echo "$(date) | CPU: $CPU%" | tee -a $LOG_FILE

    if (( $(echo "$CPU > 80" | bc -l) )); then
        echo "⚠ ALERTA: CPU alta detectada" | tee -a $LOG_FILE
    fi

    sleep 2
done

