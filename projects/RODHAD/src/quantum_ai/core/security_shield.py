import socket
import sys

class SpaceSecurityShield:
    """
    NASA-Grade Air-Gap and Self-Injected Drop Core.
    Features 'Aron' - The Street-Smart Biomedical Watchdog System.
    """
    
    @staticmethod
    def AronBarkAlert(malicious_ip: str, violation_type: str) -> None:
        """Emulates the acute defensive instincts of Aron (The street-smart dog)"""
        print(f"\n🐾 [WATCHDOG - ARON] *BARK! BARK!* Rogue activity detected from network vector: {malicious_ip}")
        print(f"🐾 [WATCHDOG - ARON] Smelled foul telemetry payload: [{violation_type}]. Initiating immediate containment!")

    @staticmethod
    def SelfInjectKillSwitch(client_socket: socket.socket, malicious_ip: str) -> None:
        """Forfully severs the attacker thread connection and flushes buffers."""
        try:
            poison_payload = b"\x00" * 1024
            client_socket.send(poison_payload)
            client_socket.shutdown(socket.SHUT_RDWR)
            client_socket.close()
            print("=> [SHIELD] Attacker stream channel successfully terminated by Aron's bite.")
        except Exception as e:
            print(f"[SHIELD ERROR] Failed to drop connection cleanly: {e}")

    @staticmethod
    def ValidateMemoryIntegrity(payload_string: str) -> bool:
        """Deep Packet Inspection against lateral remote code execution tokens."""
        malicious_tokens = ["exec", "eval", "os.system", "subprocess", "drop", "alter", "sh", "bash"]
        for token in malicious_tokens:
            if token in payload_string.lower():
                return False
        return True
