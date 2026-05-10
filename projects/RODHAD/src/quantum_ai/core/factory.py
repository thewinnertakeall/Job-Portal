import numpy as np
from src.quantum_ai.core.quantum_state import QuantumBioState
from src.quantum_ai.simulators.coders import QuantumEHRState, QuantumMRIState

class QuantumMedicalFactory:
    """GoF Factory Pattern to instantiate biomedical quantum structures."""
    
    @staticmethod
    def create_quantum_representation(data_type: str, qubits: int) -> QuantumBioState:
        if data_type.upper() == "EHR":
            return QuantumEHRState(num_qubits=qubits)
        elif data_type.upper() in ["MRI", "TAC", "XRAY"]:
            return QuantumMRIState(num_qubits=qubits)
        else:
            raise ValueError(f"Unsupported quantum telemetry data type: {data_type}")


class QuantumGates:
    """Mathematical operator class containing Kronecker transformations."""
    
    @staticmethod
    def hadamard_multi(qubits: int) -> np.ndarray:
        H = np.array([[1, 1], [1, -1]]) / np.sqrt(2)
        gate = H
        for _ in range(qubits - 1):
            gate = np.kron(gate, H)
        return gate
