#!/bin/bash

# =========================================================
# RODHAD - AI DEFENSIVE LAYER
# =========================================================

set -e

PROJECT_DIR=~/projects/RODHAD
AI_DIR=$PROJECT_DIR/ai_defense

echo "================================================="
echo " RODHAD AI DEFENSIVE SYSTEM"
echo "================================================="

mkdir -p $AI_DIR
mkdir -p $AI_DIR/logs
mkdir -p $AI_DIR/models
mkdir -p $AI_DIR/data

# =========================================================
# INSTALL AI / SECURITY PACKAGES
# =========================================================

echo "Installing packages..."

sudo apt update

sudo apt install -y \
python3-pip \
espeak \
jq \
curl

pip install --break-system-packages \
pandas \
numpy \
scikit-learn \
psutil \
joblib

# =========================================================
# CREATE AI ENGINE
# =========================================================

echo "Creating AI engine..."

cat > $AI_DIR/ai_defense.py <<'EOF'
import os
import time
import json
import psutil
import subprocess
import pandas as pd
from datetime import datetime
from sklearn.ensemble import IsolationForest

LOG_DIR = os.path.expanduser("~/projects/RODHAD/ai_defense/logs")
DATA_DIR = os.path.expanduser("~/projects/RODHAD/ai_defense/data")

os.makedirs(LOG_DIR, exist_ok=True)
os.makedirs(DATA_DIR, exist_ok=True)

# =========================================================
# VOICE ALERT
# =========================================================

def robot_voice(message):
    try:
        subprocess.run(
            ["espeak", "-s", "150", "-ven+f3", message],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except:
        pass

# =========================================================
# SYSTEM DATA
# =========================================================

def collect_metrics():

    cpu = psutil.cpu_percent(interval=1)
    ram = psutil.virtual_memory().percent
    disk = psutil.disk_usage('/').percent
    users = len(psutil.users())
    processes = len(psutil.pids())

    connections = len(psutil.net_connections())

    docker_containers = 0

    try:
        result = subprocess.check_output(
            "docker ps -q | wc -l",
            shell=True
        ).decode().strip()

        docker_containers = int(result)

    except:
        pass

    return {
        "timestamp": datetime.now().isoformat(),
        "cpu": cpu,
        "ram": ram,
        "disk": disk,
        "users": users,
        "processes": processes,
        "connections": connections,
        "docker_containers": docker_containers
    }

# =========================================================
# SAVE DATA
# =========================================================

def save_metrics(data):

    file = f"{DATA_DIR}/metrics.jsonl"

    with open(file, "a") as f:
        f.write(json.dumps(data) + "\n")

# =========================================================
# LOAD DATA
# =========================================================

def load_dataset():

    file = f"{DATA_DIR}/metrics.jsonl"

    if not os.path.exists(file):
        return pd.DataFrame()

    rows = []

    with open(file) as f:
        for line in f:
            try:
                rows.append(json.loads(line))
            except:
                pass

    return pd.DataFrame(rows)

# =========================================================
# AI DETECTION
# =========================================================

def detect_anomalies(df):

    if len(df) < 20:
        return None

    features = df[[
        "cpu",
        "ram",
        "disk",
        "users",
        "processes",
        "connections",
        "docker_containers"
    ]]

    model = IsolationForest(
        contamination=0.05,
        random_state=42
    )

    model.fit(features)

    preds = model.predict(features)

    latest = preds[-1]

    return latest == -1

# =========================================================
# SECURITY CORRELATION
# =========================================================

def correlate_security_events():

    alerts = []

    try:
        auth_log = "/var/log/auth.log"

        if os.path.exists(auth_log):

            failed = subprocess.check_output(
                f"grep 'Failed password' {auth_log} | tail -5",
                shell=True
            ).decode()

            if failed.strip():
                alerts.append("multiple ssh failures detected")

    except:
        pass

    try:
        docker_logs = subprocess.check_output(
            "docker ps --format '{{.Names}}'",
            shell=True
        ).decode().splitlines()

        for c in docker_logs:

            logs = subprocess.check_output(
                f"docker logs --tail 5 {c}",
                shell=True,
                stderr=subprocess.DEVNULL
            ).decode().lower()

            if "error" in logs:
                alerts.append(f"container errors detected in {c}")

    except:
        pass

    return alerts

# =========================================================
# ALERT SYSTEM
# =========================================================

def alert(message):

    log_file = f"{LOG_DIR}/alerts.log"

    timestamp = datetime.now().isoformat()

    full = f"[{timestamp}] ALERT: {message}"

    print(full)

    with open(log_file, "a") as f:
        f.write(full + "\n")

    robot_voice(message)

# =========================================================
# MAIN LOOP
# =========================================================

print("RODHAD AI DEFENSE ACTIVE")

while True:

    try:

        metrics = collect_metrics()

        save_metrics(metrics)

        df = load_dataset()

        anomaly = detect_anomalies(df)

        if anomaly:
            alert("anomalous system behavior detected")

        events = correlate_security_events()

        for e in events:
            alert(e)

        if metrics["cpu"] > 90:
            alert("critical cpu usage")

        if metrics["ram"] > 90:
            alert("critical ram usage")

        if metrics["connections"] > 300:
            alert("high network connections")

        time.sleep(20)

    except Exception as e:

        alert(f"ai engine error {str(e)}")

        time.sleep(20)

EOF

# =========================================================
# STARTER SCRIPT
# =========================================================

echo "Creating launcher..."

cat > $AI_DIR/start_ai_defense.sh <<'EOF'
#!/bin/bash

cd ~/projects/RODHAD/ai_defense

python3 ai_defense.py
EOF

chmod +x $AI_DIR/start_ai_defense.sh

# =========================================================
# SYSTEMD SERVICE
# =========================================================

echo "Creating systemd service..."

sudo tee /etc/systemd/system/rodhad-ai.service > /dev/null <<EOF
[Unit]
Description=RODHAD AI Defense System
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$AI_DIR
ExecStart=/usr/bin/python3 $AI_DIR/ai_defense.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# =========================================================
# ENABLE SERVICE
# =========================================================

sudo systemctl daemon-reload

sudo systemctl enable rodhad-ai.service

sudo systemctl restart rodhad-ai.service

# =========================================================
# FINAL STATUS
# =========================================================

echo ""
echo "================================================="
echo " AI DEFENSIVE SYSTEM ACTIVE"
echo "================================================="

echo ""
echo "Logs:"
echo "$AI_DIR/logs/alerts.log"

echo ""
echo "Manual start:"
echo "$AI_DIR/start_ai_defense.sh"

echo ""
echo "Service status:"
echo "sudo systemctl status rodhad-ai.service"

echo ""
echo "Live logs:"
echo "tail -f $AI_DIR/logs/alerts.log"

echo ""
echo "================================================="
echo " RODHAD AI DEFENSE ONLINE"
echo "================================================="
