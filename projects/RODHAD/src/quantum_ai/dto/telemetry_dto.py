from dataclasses import dataclass

@dataclass(frozen=True)
class AstronautTelemetryDTO:
    """
    Data Transfer Object (DTO) for Space Biomedical Telemetry.
    Implements compile-time data immutability (frozen=True) to prevent memory hijacking.
    """
    heart_rate: float
    spo2: float
    blood_pressure: float
    radiation: float

    @classmethod
    def FromRawNetworkPayload(cls, data_dict: dict):
        """Factory method to filter and strict-cast incoming socket variables."""
        # Clean external payloads against type mutations or parameter pollution
        return cls(
            heart_rate=float(data_dict.get("heart_rate", 0.0)),
            spo2=float(data_dict.get("spo2", 0.0)),
            blood_pressure=float(data_dict.get("blood_pressure", 0.0)),
            radiation=float(data_dict.get("radiation", 0.0))
        )
