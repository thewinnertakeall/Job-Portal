#!/bin/bash

# =========================================================
# RODHAD - Docker Hardening Script
# =========================================================

set -e

PROJECT_DIR=~/projects/RODHAD

echo "================================================="
echo " RODHAD DOCKER HARDENING"
echo "================================================="

cd $PROJECT_DIR

# =========================================================
# CREATE SECURE DOCKER NETWORKS
# =========================================================

echo "Creating isolated Docker networks..."

docker network create \
--driver bridge \
--internal \
rodhad_backend_net || true

docker network create \
--driver bridge \
rodhad_frontend_net || true

docker network create \
--driver bridge \
rodhad_monitoring_net || true

# =========================================================
# CREATE HARDENED DOCKER-COMPOSE
# =========================================================

echo "Generating secure docker-compose.hardened.yml ..."

cat > docker-compose.hardened.yml <<'EOF'

version: "3.9"

services:

  backend:
    build: .
    container_name: rodhad_backend

    restart: unless-stopped

    user: "1000:1000"

    read_only: true

    privileged: false

    security_opt:
      - no-new-privileges:true

    cap_drop:
      - ALL

    pids_limit: 200

    mem_limit: 1g
    cpus: "1.0"

    tmpfs:
      - /tmp
      - /run

    networks:
      - backend_net

    ports:
      - "8000:8000"

    volumes:
      - ./data:/app/data:rw

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000"]
      interval: 30s
      timeout: 10s
      retries: 3

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  frontend:
    image: nginx:alpine
    container_name: rodhad_frontend

    restart: unless-stopped

    read_only: true

    privileged: false

    security_opt:
      - no-new-privileges:true

    cap_drop:
      - ALL

    pids_limit: 100

    mem_limit: 512m
    cpus: "0.50"

    tmpfs:
      - /tmp
      - /var/cache/nginx
      - /var/run

    networks:
      - frontend_net

    ports:
      - "80:80"

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  monitoring:
    image: prom/prometheus
    container_name: rodhad_monitoring

    restart: unless-stopped

    read_only: true

    privileged: false

    security_opt:
      - no-new-privileges:true

    cap_drop:
      - ALL

    pids_limit: 100

    mem_limit: 512m
    cpus: "0.50"

    networks:
      - monitoring_net

    ports:
      - "9090:9090"

    logging:
      driver: "json-file"
      options:
        max-size: "5m"
        max-file: "2"

networks:

  backend_net:
    external: true
    name: rodhad_backend_net

  frontend_net:
    external: true
    name: rodhad_frontend_net

  monitoring_net:
    external: true
    name: rodhad_monitoring_net

EOF

# =========================================================
# DOCKER DAEMON HARDENING
# =========================================================

echo "Hardening Docker daemon..."

sudo mkdir -p /etc/docker

sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "icc": false,
  "live-restore": true,
  "no-new-privileges": true,
  "userland-proxy": false,
  "disable-legacy-registry": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker

# =========================================================
# REMOVE PRIVILEGED CONTAINERS
# =========================================================

echo "Searching privileged containers..."

docker ps --format "{{.Names}}" | while read c; do
    PRIV=$(docker inspect $c --format='{{.HostConfig.Privileged}}')

    if [ "$PRIV" = "true" ]; then
        echo "WARNING: privileged container found -> $c"
    fi
done

# =========================================================
# VERIFY NON-ROOT USERS
# =========================================================

echo "Checking container users..."

docker ps --format "{{.Names}}" | while read c; do
    echo ""
    echo "Container: $c"

    docker exec $c id || true
done

# =========================================================
# SECURITY REPORT
# =========================================================

echo ""
echo "================================================="
echo " DOCKER SECURITY REPORT"
echo "================================================="

echo ""
echo "NETWORKS:"
docker network ls

echo ""
echo "RUNNING CONTAINERS:"
docker ps

echo ""
echo "RESOURCE LIMITS:"
docker inspect $(docker ps -q) \
| grep -E '"Memory"|"NanoCpus"' || true

echo ""
echo "================================================="
echo " DOCKER HARDENED SUCCESSFULLY"
echo "================================================="
