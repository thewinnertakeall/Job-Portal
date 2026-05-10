import sys

class SpaceQuarantineManager:
    """
    Manages the containment strategy and isolation thresholds for malicious actors.
    Emulates NASA Blast Radius limitation protocols.
    """
    def __init__(self):
        self.__isolated_ips = set()

    def IsIsolate(self, ip_address: str) -> bool:
        return ip_address in self.__isolated_ips

    def TriggerQuarantine(self, malicious_ip: str, reason: str) -> None:
        """Executes a defensive lockdown for the compromised node."""
        if malicious_ip not in self.__isolated_ips:
            self.__isolated_ips.add(malicious_ip)
            print(f"\n[!!! MASTER ALARM !!!] SECURITY BREACH DETECTED FROM IP: {malicious_ip}")
            print(f"Reason: {reason}")
            print(f"===> CRITICAL ACTION: IP {malicious_ip} MOVED TO ISOLATED CUARENTENA VLAN.")
            print("=> [V05N09] SHUTTING DOWN LATERAL NETWORK BRIDGES TO PROTECT APOLLO CORE.\n")
            
            # Here you would typically trigger an automated iptables or firewall block command:
            # os.system(f"iptables -A INPUT -s {malicious_ip} -j DROP")
