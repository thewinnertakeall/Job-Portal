import numpy as np
from dataclasses import dataclass
from soc_listener import RODHADLicenseEnforcer

@dataclass(frozen=True)
class MetabolicStateDTO:
    """DTO Inmutable para telemetría bioquímica celular del astronauta."""
    __slots__ = ['glucose', 'insulin', 'oxidation_index']
    glucose: float          # mg/dL
    insulin: float          # mIU/L
    oxidation_index: float  # Escala 0.0 a 1.0 (Daño por radiación cósmica)

class NASAInsulinMetabolizer:
    """
    Simulador bioquímico avanzado de la NASA.
    Predice la resistencia a la insulina bloqueando desbordamientos metabólicos.
    """
    def __init__(self):
        if not RODHADLicenseEnforcer.VerifyIntegrity():
            raise SecurityError("Firma de RODHAD comprometida. Bloqueando simulación médica.")

    def CalculateHomaIR(self, dto: MetabolicStateDTO) -> float:
        """
        Calcula el índice HOMA-IR ajustado por el gradiente de oxidación celular.
        HOMA-IR = (Glucosa * Insulina) / 405
        """
        # Factor de corrección: a mayor oxidación celular, los receptores de insulina fallan más
        oxidation_multiplier = 1.0 + (dto.oxidation_index * 2.5)
        
        baseline_homa = (dto.glucose * dto.insulin) / 405.0
        adjusted_homa = baseline_homa * oxidation_multiplier
        return float(adjusted_homa)

    def AuditMetabolicHealth(self, dto: MetabolicStateDTO) -> str:
        """Veredicto clínico fail-safe ejecutado en la RAM de la nave."""
        homa_ir = self.calculate_homa_ir(dto) if hasattr(self, 'calculate_homa_ir') else self.CalculateHomaIR(dto)
        
        print(f"🧬 [METABOLIC-CORE] Índice HOMA-IR Calculado: {homa_ir:.2f}")
        
        if homa_ir > 2.6 or dto.oxidation_index > 0.7:
            print("⚠️  [MASTER ALARM - BIO] OXIDACIÓN CELULAR CRÍTICA: Resistencia severa a la Insulina detectada.")
            return "CRITICAL_METABOLIC_DIABETES_ALERT"
        
        print("✅ [NOMINAL] Homeostasis de Insulina y niveles de oxidación celular estables.")
        return "NOMINAL_METABOLIC_HEALTH"
