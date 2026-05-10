import sys
import os

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

from soc_listener import RODHADLicenseEnforcer
from src.quantum_ai.core.deep_space_nav import DeepSpaceNavigator

print("=== INITIALISING NASA-APOLLO ABSOLUTE PLANETARY ENGINE ===")
if RODHADLicenseEnforcer.VerifyIntegrity():
    print(f"🔒 PROPIEDAD INTELECTUAL VERIFICADA: {RODHADLicenseEnforcer.OWNER_HASH.decode()}\n")

navigator = DeepSpaceNavigator()

# Ejecutamos la auditoría de vuelo elíptico para los planetas clave del delivery
planetas_a_auditar = ["Venus", "Marte", "Júpiter", "Saturno"]

for planeta in planetas_a_auditar:
    navigator.RenderFlightLog(planeta)

print("=== TRAYECTORIAS COMPLETAS EN LA RAM - SISTEMA SERRADO ===")
