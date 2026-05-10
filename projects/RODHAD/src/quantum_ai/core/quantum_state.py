from abc import ABC, abstractmethod
import numpy as np

class QuantumBioState(ABC):
    """Abstract Base Class representing the quantum biological state of an astronaut."""
    
    def __init__(self, num_qubits: int):
        self._num_qubits = num_qubits
        self._state_vector = np.zeros(2**num_qubits, dtype=complex)
        self._state_vector[0] = 1.0  # Ground state |0...0>

    @property
    def state_vector(self) -> np.ndarray:
        """Encapsulation of the internal complex state vector."""
        return self._state_vector

    @abstractmethod
    def encode_medical_data(self, data: np.ndarray) -> None:
        """Polymorphism: Custom clinical encoding per dataset type (EHR/MRI)."""
        pass

    def __matmul__(self, gate: np.ndarray):
        """Operator overloading (@) for unitary quantum gate transformations."""
        if gate.shape != (len(self._state_vector), len(self._state_vector)):
            raise ValueError("Gate dimensions do not match the Hilbert space.")
        self._state_vector = np.dot(gate, self._state_vector)
        return self

    def __repr__(self) -> str:
        return f"QuantumBioState(Qubits: {self._num_qubits}, State: {np.round(self._state_vector, 3)})"
