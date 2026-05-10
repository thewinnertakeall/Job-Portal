import numpy as np
from src.quantum_ai.core.quantum_state import QuantumBioState

class QuantumClinicalMeasurer:
    """Collapses quantum superposition states into actionable clinical diagnoses."""
    
    def __init__(self, seed: int = 42):
        self.__random_state = np.random.RandomState(seed)

    def calculate_probabilities(self, bio_state: QuantumBioState) -> np.ndarray:
        """Applies Born's Rule: P(i) = |amplitude_i|^2"""
        state_vec = bio_state.state_vector
        probabilities = np.abs(state_vec) ** 2
        probabilities /= np.sum(probabilities)
        return probabilities

    def collapse_state(self, bio_state: QuantumBioState, diagnostic_labels: list[str]) -> str:
        probabilities = self.calculate_probabilities(bio_state)
        if len(diagnostic_labels) != len(probabilities):
            raise ValueError(f"Required exactly {len(probabilities)} labels for this Hilbert space.")
            
        collapsed_index = self.__random_state.choice(len(probabilities), p=probabilities)
        return diagnostic_labels[collapsed_index]
