from abc import ABC, abstractmethod
import pydicom
import cv2
import numpy as np
import pandas as pd

class BaseProcessor(ABC):
    """Clase Abstracta (Abstracción) para el procesamiento de datos médicos."""
    
    @abstractmethod
    def process(self, file_path: str) -> np.ndarray | pd.DataFrame:
        """Método abstracto que debe ser implementado por todas las subclases."""
        pass


class DICOMProcessor(BaseProcessor):
    """Subclase (Herencia) especializada en Imágenes Médicas (TAC, MRI, Rayos X)."""
    
    def __init__(self, target_size: tuple[int, int] = (224, 224)):
        self.target_size = target_size

    def process(self, file_path: str) -> np.ndarray:
        """Implementación específica para archivos DICOM (Polimorfismo)."""
        dicom = pydicom.dcmread(file_path)
        image = dicom.pixel_array.astype(float)
        
        # Normalización a escala de grises estándar
        image = (image - np.min(image)) / (np.max(image) - np.min(image)) * 255.0
        image = image.astype(np.uint8)
        
        # Filtros de contraste (Ecualización CLAHE tipo NASA MED-SEG)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
        enhanced_image = clahe.apply(image)
        
        # Redimensionado adaptativo
        resized_image = cv2.resize(enhanced_image, self.target_size)
        return resized_image / 255.0


class EHRProcessor(BaseProcessor):
    """Subclase (Herencia) especializada en Registros Médicos Electrónicos."""
    
    def __init__(self, required_features: list[str]):
        self.required_features = required_features

    def process(self, file_path: str) -> pd.DataFrame:
        """Implementación específica para datos tabulares EHR (Polimorfismo)."""
        df = pd.read_csv(file_path)
        
        # Limpieza de nulos y filtrado por características requeridas (vitals)
        df = df.dropna(subset=self.required_features)
        return df[self.required_features]
