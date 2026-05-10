#!/bin/bash

WATCH_DIR="db_data"
LOG_FILE="logs/data_control.log"

mkdir -p logs

echo "===============================" | tee -a $LOG_FILE
echo " RODHAD DATA CONTROL CORE " | tee -a $LOG_FILE
echo "===============================" | tee -a $LOG_FILE

while true
do
    SIZE=$(du -s $WATCH_DIR | awk '{print $1}')

    TIME=$(date +"%Y-%m-%d %H:%M:%S")

    echo "$TIME | SIZE: $SIZE KB" | tee -a $LOG_FILE

    # Umbral simple (ajustable)
    if [ "$SIZE" -gt 50000 ]; then
        echo "⚠ ALERTA: crecimiento alto en db_data" | tee -a $LOG_FILE
    fi

    sleep 5
done



