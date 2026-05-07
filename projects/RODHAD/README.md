# RODHAD: Robotic Decision & Health Analysis Data

**Lead Developer:** DOCTOR DE DATOS MATHEW  
**Architecture:** Distributed Microservices (Docker + ROS2 + AI)

## Security Protocol
Access to the sensor ingestion API is protected via **JWT (JSON Web Tokens)**.
To obtain an access token, use the `/sensors/login` endpoint.

## Deployment
1. Ensure Docker and Docker Compose are installed.
2. Run: `docker-compose up --build -d`
3. Use the Authorization header: `Bearer <token>` for all sensor requests.

---
*Confidential and Proprietary Information.*
