FROM python:3.10-slim
LABEL architecture="Frugal-E-Waste-Optimized"
WORKDIR /workspace/RODHAD
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY soc_listener.py .
CMD ["python3", "soc_listener.py"]
