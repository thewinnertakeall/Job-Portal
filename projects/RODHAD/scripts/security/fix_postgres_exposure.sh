#!/bin/bash

echo "========================================="
echo "     FIXING POSTGRES EXPOSURE"
echo "========================================="

echo ""
echo "[1/5] DETECTING EXPOSED CONTAINERS..."

docker ps | grep 5432

echo ""
echo "[2/5] STOPPING EXPOSED sales_db..."

docker stop sales_db || true

echo ""
echo "[3/5] REMOVING EXPOSED sales_db..."

docker rm sales_db || true

echo ""
echo "[4/5] VERIFYING PORT 5432..."

sleep 3

ss -tunap | grep 5432 || true

echo ""
echo "[5/5] CHECKING SAFE CONTAINERS..."

docker ps

echo ""
echo "========================================="
echo "        POSTGRES HARDENED"
echo "========================================="
echo ""
echo "IF YOU DO NOT SEE:"
echo "0.0.0.0:5432"
echo ""
echo "THEN YOUR DATABASE IS NO LONGER"
echo "PUBLICLY EXPOSED."
echo "========================================="
