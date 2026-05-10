import numpy as np
from src.quantum_ai.core.quantum_state import QuantumBioState

class QuantumEHRState(QuantumBioState):
    """Subclass for processing electronic health records via Amplitude Encoding."""
    
    def encode_medical_data(self, data: np.ndarray) -> None:
        norm = np.linalg.norm(data)
        if norm == 0:
            return
        normalized_data = data / norm
        
        target_len = len(self._state_vector)
        self._state_vector[:len(normalized_data)] = normalized_data
        self._state_vector[len(normalized_data):] = 0.0


class QuantumMRIState(QuantumBioState):
    """Subclass for processing dense imaging data via Phase Encoding."""
    
    def encode_medical_data(self, data: np.ndarray) -> None:
        phases = np.clip(data, -np.pi, np.pi)
        for i, angle in enumerate(phases[:len(self._state_vector)]):
            self._state_vector[i] = (1.0 / np.sqrt(len(self._state_vector))) * np.exp(1j * angle)
