import time
import json
import hashlib
import random
import getpass
from datetime import datetime

# =========================
# RODHAD SOC CORE SIMULADO
# =========================

EVENT_TYPES = [
    "login_success",
    "login_failed",
    "file_access",
    "privilege_escalation",
    "network_scan",
    "suspicious_process"
]

def sha256(event: dict) -> str:
    data = json.dumps(event, sort_keys=True).encode()
    return hashlib.sha256(data).hexdigest()

def generate_event():
    return {
        "timestamp": datetime.utcnow().isoformat(),
        "event_type": random.choice(EVENT_TYPES),
        "user": random.choice(["admin", "service", "analyst", "root"]),
        "ip": f"192.168.0.{random.randint(1,255)}",
        "severity": random.randint(1,10)
    }

def anomaly_score(event):
    score = 0

    if event["event_type"] == "privilege_escalation":
        score += 5
    if event["event_type"] == "login_failed":
        score += 3
    if event["user"] == "root":
        score += 2
    if event["severity"] >= 8:
        score += 2

    return score

# =========================
# LOGIN SIMPLE
# =========================

def login():
    print("🔐 RODHAD SOC LOGIN")

    user = input("User: ")
    password = getpass.getpass("Password: ")

    # login simulado duro (rápido para test)
    if user == "admin" and password == "admin123":
        print("✅ Access granted (SOC ADMIN)")
        return user
    else:
        print("❌ Access denied")
        exit()

# =========================
# SOC LOOP
# =========================

def soc_loop():
    print("🚨 RODHAD SOC CORE RUNNING")
    print("=" * 40)

    while True:
        event = generate_event()
        event_hash = sha256(event)
        score = anomaly_score(event)

        log = {
            "event": event,
            "sha256": event_hash,
            "anomaly_score": score
        }

        print(json.dumps(log, indent=2))

        if score >= 6:
            print("⚠️ ALERTA SOC: ANOMALÍA DETECTADA")

        time.sleep(1)

# =========================
# MAIN
# =========================

if __name__ == "__main__":
    login()
    soc_loop()
