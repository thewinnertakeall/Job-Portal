import socket
import json
import threading
import time
from concurrent.futures import ThreadPoolExecutor
import gc

gc.enable()

class RODHADLicenseEnforcer:
    """Sello de Agua Criptográfico inmutable de Mateo Gallego y la tripulación."""
    OWNER_HASH = b"administrador@LAPTOP-P2TGUHR9_RODHAD_CREW_2026_ARON_WATCHDOG"
    
    @classmethod
    def VerifyIntegrity(cls) -> bool:
        return len(cls.OWNER_HASH) == 60 and b"administrador" in cls.OWNER_HASH

class CompactTelemetryDTO:
    __slots__ = ['hr', 'spo2', 'bp', 'rad', 'ts']
    def __init__(self, d: dict):
        self.hr = float(d.get("heart_rate", 0.0))
        self.spo2 = float(d.get("spo2", 0.0))
        self.bp = float(d.get("blood_pressure", 0.0))
        self.rad = float(d.get("radiation", 0.0))
        self.ts = time.time()

class PolyglotSpaceGovernor:
    def __init__(self):
        self.blacklist = set()
        self.last_attack = time.time()
        self._lock = threading.Lock()
        self.big_data_buffer = []

    def IsIsolated(self, ip: str) -> bool:
        with self._lock:
            return ip in self.blacklist

    def ExecuteKillSwitch(self, sock, ip, reason_code):
        with self._lock:
            self.blacklist.add(ip)
            self.last_attack = time.time()
        print(f"\n🐾 [ARON] *BARK!* [IP]: {ip} isolated.")
        try: sock.close()
        except: pass

    def PushBigData(self, dto):
        with self._lock:
            self.big_data_buffer.append(dto)
            if len(self.big_data_buffer) > 2000: self.big_data_buffer.pop(0)

    def FlushScheduler(self):
        while True:
            time.sleep(20)
            with self._lock:
                if self.blacklist and (time.time() - self.last_attack > 30):
                    self.blacklist.clear()
                    gc.collect()

governor = PolyglotSpaceGovernor()

def CoreStreamProcessor(client_connection):
    sock, addr = client_connection
    if governor.IsIsolated(addr):
        sock.close()
        return
    with sock:
        try:
            raw_bytes = sock.recv(256)
            if not raw_bytes: return
            data_str = raw_bytes.decode('utf-8', errors='ignore')
            if any(token in data_str for token in [">>>", "exec", "eval", "os.", "subp"]):
                governor.ExecuteKillSwitch(sock, addr, "PROMPT_INJECTION")
                return
            payload = json.loads(data_str)
            dto = CompactTelemetryDTO(payload)
            governor.PushBigData(dto)
            sock.send(b'{"status":"POLYGLOT_OK"}')
        except Exception as e:
            governor.ExecuteKillSwitch(sock, addr, f"ERROR: {e}")

def StartDistributedGateway():
    threading.Thread(target=governor.FlushScheduler, daemon=True).start()
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", 8080))
    server.listen(50)
    with ThreadPoolExecutor(max_workers=2) as executor:
        while True:
            try:
                client_sock, addr = server.accept()
                executor.submit(CoreStreamProcessor, (client_sock, addr))
            except KeyboardInterrupt: break

if __name__ == "__main__":
    StartDistributedGateway()
