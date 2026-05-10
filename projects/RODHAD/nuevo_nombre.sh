#!/bin/bash

CONFIG_FILE="rodhad_calibration.conf"

clear
echo "===================================="
echo "   RODHAD - CALIBRACIÓN MANUAL V1   "
echo "===================================="
echo ""

echo "⚙️ Configuración del sistema"
echo ""

read -p "📊 CPU threshold (%) [0-100]: " CPU_T
read -p "📊 RAM threshold (%) [0-100]: " RAM_T
read -p "🌐 Sensibilidad red (baja/media/alta): " NET_S
read -p "🚨 Modo alertas (silencioso/normal/verbose): " ALERT_M
read -p "🤖 Auto-respuesta (on/off): " AUTO_R

echo ""
echo "💾 Guardando configuración..."

cat > $CONFIG_FILE <<EOF
CPU_THRESHOLD=$CPU_T
RAM_THRESHOLD=$RAM_T
NETWORK_SENSITIVITY=$NET_S
ALERT_MODE=$ALERT_M
AUTO_RESPONSE=$AUTO_R
EOF

echo ""
echo "✔ CONFIGURACIÓN GUARDADA"
echo "📁 Archivo: $CONFIG_FILE"
echo ""
echo "📌 Contenido:"
echo "------------------------------------"
cat $CONFIG_FILE
echo "------------------------------------"
echo ""
echo "🚀 RODHAD listo para aplicar calibración"
