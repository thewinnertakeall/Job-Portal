#!/bin/bash
# Generador de Reportes ISO - RODHAD
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="reporte_$TIMESTAMP.txt"

echo "------------------------------------------" > data/reports/$FILENAME
echo "RODHAD MEDICAL SYSTEM - REPORTE ISO-9001" >> data/reports/$FILENAME
echo "FECHA: $TIMESTAMP" >> data/reports/$FILENAME
echo "ESTADO: PACIENTE DETECTADO EN SIMULACIÓN" >> data/reports/$FILENAME
echo "------------------------------------------" >> data/reports/$FILENAME

echo "✅ Reporte generado: data/reports/$FILENAME"
