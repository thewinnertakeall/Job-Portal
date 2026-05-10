import numpy as np
from dataclasses import dataclass
from soc_listener import RODHADLicenseEnforcer

@dataclass(frozen=True)
class PlanetOrbitDTO:
    __slots__ = ['name', 'radius_km']
    name: str
    radius_km: float

class DeepSpaceNavigator:
    """
    Sistema de Guiado Interplanetario Absoluto de RODHAD.
    Calcula órbitas de Hohmann para todo el Sistema Solar en 250 KB de RAM.
    """
    MU_SUN = 1.32712440018e11  # Constante gravitacional del Sol (km^3/s^2)
    R_EARTH = 1.496e8          # Radio orbital de la Tierra (km)

    def __init__(self):
        if not RODHADLicenseEnforcer.VerifyIntegrity():
            raise SecurityError("Línea de seguridad de Mateo Gallego comprometida.")
        
        # Base de datos indexada en RAM de la chatarra informática (Frugal)
        self.solar_system = {
            "MERCURIO": PlanetOrbitDTO("Mercurio", 5.791e7),
            "VENUS": PlanetOrbitDTO("Venus", 1.082e8),
            "MARTE": PlanetOrbitDTO("Marte", 2.279e8),
            "JUPITER": PlanetOrbitDTO("Júpiter", 7.785e8),
            "SATURNO": PlanetOrbitDTO("Saturno", 1.434e9),
            "URANO": PlanetOrbitDTO("Urano", 2.871e9),
            "NEPTUNO": PlanetOrbitDTO("Neptuno", 4.495e9)
        }

    def PlotInterplanetaryRoute(self, target_planet_name: str) -> dict:
        """Calcula el tiempo de vuelo y el Delta-V de escape para el planeta seleccionado."""
        target = target_planet_name.upper().strip()
        if target not in self.solar_system:
            raise ValueError(f"Planeta fuera de los mapas de la tripulación: {target_planet_name}")
            
        planet_dto = self.solar_system[target]
        r_target = planet_dto.radius_km
        
        # Geometría de Hohmann: Semieje mayor de la elipse de transferencia
        semi_major_axis = (self.R_EARTH + r_target) / 2.0
        
        # Tiempo de vuelo en segundos y conversión a días/años
        time_seconds = np.pi * np.sqrt((semi_major_axis ** 3) / self.MU_SUN)
        time_days = time_seconds / (24.0 * 3600.0)
        
        # Cálculo de la inyección de escape desde la Tierra
        v_earth = np.sqrt(self.MU_SUN / self.R_EARTH)
        v_transfer = np.sqrt(self.MU_SUN * (2.0 / self.R_EARTH - 1.0 / semi_major_axis))
        delta_v_escape = abs(v_transfer - v_earth)
        
        return {
            "name": planet_dto.name,
            "days": float(time_days),
            "years": float(time_days / 365.25),
            "delta_v": float(delta_v_escape)
        }

    def RenderFlightLog(self, target_planet_name: str):
        route = self.PlotInterplanetaryRoute(target_planet_name)
        
        print(f"🌍 [DEEP-SPACE] CALCULANDO TRAYECTORIA DE ENTRADA O SALIDA HOHMANN")
        print(f"-> [DESTINO]: Misión Delivery a {route['name']}")
        print(f"-> [DURACIÓN DE VIAJE]: {route['days']:.2f} Días ({route['years']:.2f} Años de flotación)")
        print(f"-> [IMPULSO REQUERIDO]: Delta-V = {route['delta_v']:.4f} km/s")
        
        # Evaluación de riesgos físicos en hardware y tripulación (Resistencia a la Insulina por tiempo)
        if route['days'] > 1000.0:
            print("   ⚠️  [ALERTA TERMICA] Tiempo de exposición extremo: Alto peligro de congelamiento de RAM y oxidación física por falta de uso.")
        else:
            print("   ✅ [NOMINAL] Ruta dentro de los parámetros de soporte vital eficientes.")
        print("-------------------------------------------------------------------------")
