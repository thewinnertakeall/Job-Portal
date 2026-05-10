from sklearn.ensemble import IsolationForest
import pandas as pd

class BaseDetector:
    """Clase base para sistemas de alerta temprana."""
    def __init__(self, contamination: float):
        self._contamination = contamination  # Atributo protegido

    @property
    def contamination(self) -> float:
        return self._contamination


class BioTelemetryAnomalyDetector(BaseDetector):
    """Detector de anomalías de signos vitales basado en telemetría de cohetes."""
    
    def __init__(self, contamination: float = 0.05):
        super().__init__(contamination)
        # Encapsulamiento del modelo matemático interno
        self.__model = IsolationForest(contamination=self.contamination, random_state=42)

    def train_detector(self, ehr_dataframe: pd.DataFrame, features: list[str]) -> None:
        X = ehr_dataframe[features]
        self.__model.fit(X)

    def detect(self, current_vitals: pd.DataFrame, features: list[str]) -> int:
        X = current_vitals[features]
        # Retorna -1 para anomalía crítica, 1 para estado nominal
        return int(self.__model.predict(X)[0])
