import socket
import json
import time
import random

class MultiPlanetRobotController:
    """
    Firmware adaptable para el hardware del robot.
    Modifica el torque del software y las inyecciones de insulina según el planeta destino.
    """
    def __init__(self, server_ip="127.0.0.1", server_port=8080):
        self.server_address = (server_ip, server_port)

    def AdjustHardwareProfile(self, target_planet: str) -> dict:
        """Configura el consumo eléctrico de la CPU y los rangos de la DTO en RAM."""
        planet = target_planet.upper().strip()
        print(f"\n🌍 [FIRMWARE] Configurando perfil físico para el planeta: {planet}")
        
        if planet == "VENUS":
            print("   🔥 [MODO INFERNAL] Alta temperatura externa. Reduciendo voltaje para evitar oxidación.")
            return {"cpu_limit": "0.05", "ram_buffer": 128, "insulin_bias": 1.0}
        elif planet == "SATURNO" or planet == "JUPITER":
            print("   ❄️  [MODO HIBERNACIÓN] Congelamiento y radiación alta. Maximizando ciclos de Flush de RAM.")
            return {"cpu_limit": "0.20", "ram_buffer": 512, "insulin_bias": 3.5}
        else:
            # Configuración nominal para Marte o la Tierra
            print("   ✅ [MODO NOMINAL] Gravedad y radiación controladas. Perfil estándar activo.")
            return {"cpu_limit": "0.10", "ram_buffer": 256, "insulin_bias": 2.0}

    def StreamPlanetaryTelemetry(self, target_planet: str):
        profile = self.AdjustHardwareProfile(target_planet)
        print("=== INICIANDO SECUENCIA DE COMUNICACIÓN INTERPLANETARIA ===")
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1.5)
            sock.connect(self.server_address)
            
            # La telemetría varía según el estrés metabólico calculado por el perfil del planeta
            telemetry_data = {
                "heart_rate": random.uniform(70.0, 95.0) * profile["insulin_bias"],
                "spo2": max(75.0, 99.0 - (profile["insulin_bias"] * 4.0)),
                "blood_pressure": 120.0,
                "radiation": 15.0 * profile["insulin_bias"]
            }
            
            sock.send(json.dumps(telemetry_data).encode('utf-8'))
            raw_response = sock.recv(256).decode('utf-8')
            response = json.loads(raw_response)
            
            print(f" -> [RED] Respuesta del Servidor: {response}")
            print(f"🦾 [ROBOT-ACTUADOR] Inyección de insulina ajustada por factor planetario: {profile['insulin_bias']} Unidades.")
            sock.close()
            
        except Exception as e:
            print(f" 🇷🇺 [ВНИМАНИЕ] Servidor offline o IP bloqueada en la RAM por Aron: {e}")

if __name__ == "__main__":
    robot = MultiPlanetRobotController()
    # Probamos el comportamiento simulando la llegada del delivery a Saturno
    robot.StreamPlanetaryTelemetry(target_planet="Saturno")
