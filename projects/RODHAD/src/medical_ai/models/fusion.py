import numpy as np
import pandas as pd
from src.medical_ai.processors.image import BaseProcessor

class MultimodalMedicalIntegrator:
    """Clase de alto nivel para unificar flujos heterogéneos de datos."""
    
    def __init__(self):
        self.processors: list[BaseProcessor] = []

    def register_processor(self, processor: BaseProcessor) -> None:
        """Inyección de dependencias aceptando cualquier subclase de BaseProcessor."""
        self.processors.append(processor)

    def process_all(self, file_paths: list[str]) -> list:
        """
        Ejecución Polimórfica: Invoca .process() sin conocer el tipo 
        exacto del procesador (si es imagen o datos tabulares EHR).
        """
        results = []
        for processor, path in zip(self.processors, file_paths):
            processed_data = processor.process(path)
            results.append(processed_data)
            print(f"[POO] Procesado con éxito usando {processor.__class__.__name__}")
        return results
