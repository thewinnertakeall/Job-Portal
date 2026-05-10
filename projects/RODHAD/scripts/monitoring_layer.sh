#!/bin/bash

# =========================================================
# RODHAD - Monitoring Layer
# =========================================================

set -e

PROJECT_DIR=~/projects/RODHAD
MONITOR_DIR=$PROJECT_DIR/monitoring
LOG_DIR=$MONITOR_DIR/logs

echo "================================================="
echo " RODHAD MONITORING INSTALLER"
echo "================================================="

mkdir -p $LOG_DIR

# =========================================================
# INSTALL MONITORING TOOLS
# =========================================================

echo "Installing monitoring packages..."

sudo apt update

sudo apt install -y \
htop \
btop \
iotop \
iftop \
sysstat \
net-tools \
lsof \
jq \
curl \
vnstat \
psmisc

# =========================================================
# ENABLE SERVICES
# =========================================================

sudo systemctl enable sysstat
sudo systemctl start sysstat

sudo systemctl enable vnstat
sudo systemctl start vnstat

# =========================================================
# MAIN MONITOR SCRIPT
# =========================================================

echo "Creating monitor engine..."

cat > $MONITOR_DIR/monitor.sh <<'EOF'
#!/bin/bash

LOG_DIR=~/projects/RODHAD/monitoring/logs
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p $LOG_DIR

# =========================================================
# CPU
# =========================================================

echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "CPU USAGE" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

top -b -n1 | head -20 >> $LOG_DIR/system_$DATE.log

# =========================================================
# RAM
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "RAM STATUS" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

free -h >> $LOG_DIR/system_$DATE.log

# =========================================================
# DISK
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "DISK STATUS" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

df -h >> $LOG_DIR/system_$DATE.log

# =========================================================
# PROCESSES
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "TOP PROCESSES" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

ps aux --sort=-%mem | head -20 >> $LOG_DIR/system_$DATE.log

# =========================================================
# NETWORK CONNECTIONS
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "NETWORK CONNECTIONS" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

ss -tunap >> $LOG_DIR/system_$DATE.log

# =========================================================
# USERS
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "ACTIVE USERS" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

who >> $LOG_DIR/system_$DATE.log
last -n 10 >> $LOG_DIR/system_$DATE.log

# =========================================================
# FAILED LOGIN ATTEMPTS
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "FAILED SSH ATTEMPTS" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

sudo grep "Failed password" /var/log/auth.log | tail -20 >> $LOG_DIR/system_$DATE.log || true

# =========================================================
# DOCKER STATUS
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "DOCKER STATUS" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

docker ps -a >> $LOG_DIR/system_$DATE.log

echo "" >> $LOG_DIR/system_$DATE.log
docker stats --no-stream >> $LOG_DIR/system_$DATE.log

# =========================================================
# DOCKER LOGS
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "DOCKER RECENT LOGS" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

for c in $(docker ps --format "{{.Names}}"); do
    echo "" >> $LOG_DIR/system_$DATE.log
    echo "CONTAINER: $c" >> $LOG_DIR/system_$DATE.log
    docker logs --tail 20 $c >> $LOG_DIR/system_$DATE.log 2>&1
done

# =========================================================
# SECURITY EVENTS
# =========================================================

echo "" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log
echo "AUDIT EVENTS" >> $LOG_DIR/system_$DATE.log
echo "=================================================" >> $LOG_DIR/system_$DATE.log

sudo ausearch -ts recent >> $LOG_DIR/system_$DATE.log || true

EOF

chmod +x $MONITOR_DIR/monitor.sh

# =========================================================
# LIVE DASHBOARD
# =========================================================

echo "Creating live dashboard..."

cat > $MONITOR_DIR/live_dashboard.sh <<'EOF'
#!/bin/bash

while true
do
    clear

    echo "================================================="
    echo " RODHAD LIVE MONITOR"
    echo "================================================="

    echo ""
    echo "CPU / RAM"
    echo "-------------------------------------------------"
    top -b -n1 | head -10

    echo ""
    echo "DISK"
    echo "-------------------------------------------------"
    df -h | head

    echo ""
    echo "DOCKER"
    echo "-------------------------------------------------"
    docker ps

    echo ""
    echo "NETWORK CONNECTIONS"
    echo "-------------------------------------------------"
    ss -tunap | head -20

    echo ""
    echo "ACTIVE USERS"
    echo "-------------------------------------------------"
    who

    sleep 5
done
EOF

chmod +x $MONITOR_DIR/live_dashboard.sh

# =========================================================
# CRON AUTOMATION
# =========================================================

echo "Installing cron monitoring..."

(
crontab -l 2>/dev/null
echo "*/5 * * * * $MONITOR_DIR/monitor.sh >/dev/null 2>&1"
) | crontab -

# =========================================================
# FINAL STATUS
# =========================================================

echo ""
echo "================================================="
echo " MONITORING INSTALLED"
echo "================================================="

echo ""
echo "Logs:"
echo "$LOG_DIR"

echo ""
echo "Run live dashboard:"
echo "$MONITOR_DIR/live_dashboard.sh"

echo ""
echo "Run manual scan:"
echo "$MONITOR_DIR/monitor.sh"

echo ""
echo "================================================="
echo " RODHAD OBSERVABILITY ACTIVE"
echo "================================================="
