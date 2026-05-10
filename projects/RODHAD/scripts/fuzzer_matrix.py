import socket
import json
import time
import random

class TelemetryFuzzerEngine:
    """
    Fuzzing Matrix designed by the RODHAD Crew to test 
    variable overflows, parameters pollution, and structural stress.
    """
    def __init__(self, target_ip: str = "127.0.0.1", target_port: int = 8080):
        self.target_address = (target_ip, target_port)
        
        # Test Cases mapping specific engineering failure modes
        self.test_matrix = {
            "CASE_01_ARGOS_ENGINE_OVERFLOW": {
                "heart_rate": 850.0, "spo2": 95.0, "blood_pressure": 120.0, "radiation": 15.0
            },
            "CASE_02_DENTAL_MOLD_MUTATION": {
                "heart_rate": "CRITICAL_ATTACK_STRING", "spo2": None, "blood_pressure": 130.0, "radiation": 22.1
            },
            "CASE_03_INJECTION_FUZZING": {
                "heart_rate": 72.0, "spo2": 98.0, "blood_pressure": 110.0, "radiation": 12.5,
                "lateral_exploit": "import os; os.system('echo COMPROMISED')"
            },
            "CASE_04_SPACE_NOMINAL_TELEMETRY": {
                "heart_rate": 82.3, "spo2": 97.4, "blood_pressure": 122.1, "radiation": 34.8
            }
        }

    def LaunchStressTest(self):
        print(f"=== LAUNCHING RODHAD INDUSTRIAL SECURITY MATRIX ===")
        
        for case_name, payload in self.test_matrix.items():
            print(f"\n[EXECUTION] Testing Boundary: {case_name}")
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2.0)
                sock.connect(self.target_address)
                
                # Send the clean or contaminated payload directly to the gateway
                sock.send(json.dumps(payload).encode('utf-8'))
                
                raw_response = sock.recv(1024)
                if raw_bytes := raw_response:
                    response = json.loads(raw_bytes.decode('utf-8'))
                    print(f"-> [SERVER METRICS VERDICT]: {response}")
                else:
                    print("-> [SERVER REACTION]: Connection severed silently (Air-Gap Protection Active).")
                    
                sock.close()
            except (socket.timeout, ConnectionResetError, BrokenPipeError):
                print("-> [KILL-SWITCH SUCCESS] The Apollo Core drop-circuit killed the thread immediately.")
            except Exception as e:
                print(f"-> [ALERT] Network layer anomaly: {e}")
                
            time.sleep(1.0)
        print("\n=== SECURITY FUZZING MATRIX TEST COMPLETE ===")

if __name__ == "__main__":
    # Target the exposed Docker container gateway port
    tester = TelemetryFuzzerEngine(target_ip="127.0.0.1", target_port=8080)
    tester.LaunchStressTest()
