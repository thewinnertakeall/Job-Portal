#!/bin/bash
echo "[NASA-INFRA] Purging existing container configurations and locks..."
docker stop rodhad_server 2>/dev/null
docker rm rodhad_server 2>/dev/null

echo "[NASA-INFRA] Building hardened application container layers..."
docker build -t rodhad-networked-app:latest .

echo "[NASA-INFRA] Deploying networked server node instance..."
docker run -d --name rodhad_server -p 8080:8080 rodhad-networked-app:latest

echo "[NASA-INFRA] Verification of real-time server initialization logs:"
docker logs rodhad_server
