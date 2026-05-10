import numpy as np
from dataclasses import dataclass
from soc_listener import RODHADLicenseEnforcer

@dataclass(frozen=True)
class OrbitalParametersDTO:
    """DTO Inmutable para constantes gravitacionales en el Espacio de Hilbert."""
    __slots__ = ['mu_sun', 'r_earth', 'r_mars']
    mu_sun: float   # Parámetro gravitacional estándar del Sol (km^3/s^2)
    r_earth: float  # Radio orbital medio de la Tierra (km)
    r_mars: float   # Radio orbital medio de Marte (km)

class HohmannDeliveryNavigator:
    """
    Calculador de trayectorias de guiado para Delivery to Marte.
    Optimizado por Mateo Gallego para ejecutarse puramente en 15MB de RAM.
    """
    def __init__(self):
        if not RODHADLicenseEnforcer.VerifyIntegrity():
            raise RuntimeError("🚨 [FALLA DE SEGURIDAD] Sello de agua alterado. Bloqueando guiado del cohete.")

    def CalculateTransferTrajectory(self, dto: OrbitalParametersDTO) -> dict:
        """
        Calcula el Semieje Mayor (a) de la elipse de transferencia 
        y el tiempo total de vuelo (TOF) en días para el delivery.
        """
        # Semieje mayor de la elipse de Hohmann: a = (r1 + r2) / 2
        semi_major_axis = (dto.r_earth + dto.r_mars) / 2.0
        
        # Tiempo de vuelo (TOF): La mitad del período orbital de la elipse de transferencia
        # TOF = pi * sqrt(a^3 / mu)
        time_of_flight_seconds = np.pi * np.sqrt((semi_major_axis ** 3) / dto.mu_sun)
        time_of_flight_days = time_of_flight_seconds / (24.0 * 3600.0)
        
        # Velocidades requeridas de escape (Delta-V1) y captura (Delta-V2)
        v_earth = np.sqrt(dto.mu_sun / dto.r_earth)
        v_trans_earth = np.sqrt(dto.mu_sun * (2.0 / dto.r_earth - 1.0 / semi_major_axis))
        delta_v_escape = v_trans_earth - v_earth
        
        return {
            "semi_major_axis_km": float(semi_major_axis),
            "time_of_flight_days": float(time_of_flight_days),
            "delta_v_escape_kms": float(delta_v_escape)
        }

    def AuditFlightPlan(self, dto: OrbitalParametersDTO):
        print("\n============================================================")
        print("🚀 [DELIVERY TO MARTE] ENCIENDAN LOS MOTORES - FLIGHT PLAN")
        print("============================================================")
        
        flight_metrics = self.CalculateTransferTrajectory(dto)
        print(f"-> [ÓRBITA] Semieje Mayor de Transferencia: {flight_metrics['semi_major_axis_km']:.2f} km")
        print(f"-> [TIEMPO] Tiempo total de viaje del Delivery: {flight_metrics['time_of_flight_days']:.2f} Días")
        print(f"-> [PROPULSIÓN] Delta-V de Escape Requerido: {flight_metrics['delta_v_escape_kms']:.4f} km/s")
        
        if flight_metrics['time_of_flight_days'] > 260.0:
            print("⚠️  [ALERTA AGC] Trayectoria ineficiente. Peligro de degradación por Radiación Cósmica.")
        else:
            print("✅ [NOMINAL] Ventana de Hohmann óptima. Consumo térmico del procesador bajo control.")
        print("============================================================\n")

if __name__ == "__main__":
    # Constantes físicas reales del Sistema Solar
    solar_system_constants = OrbitalParametersDTO(
        mu_sun=1.32712440018e11,  # km^3/s^2
        r_earth=1.496e8,          # 1 UA en km
        r_mars=2.279e8            # 1.524 UA en km
    )
    
    navigator = HohmannDeliveryNavigator()
    navigator.AuditFlightPlan(solar_system_constants)
