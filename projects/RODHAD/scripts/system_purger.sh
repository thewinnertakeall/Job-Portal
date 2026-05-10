#!/bin/bash
echo "[E-WASTE-MAINTENANCE] Initiating automated cache flush to protect recycled hardware..."

# Force system memory compaction and drop file caches in OS RAM
sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null

# Prune unused docker layers, dangling volumes, and stopped build logs
docker system prune -a --volumes -f

# Truncate large system log files to zero bytes to save flash memory space
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

echo "[SUCCESS] Flash storage space recovered. Micro-kernel computing power optimized."
