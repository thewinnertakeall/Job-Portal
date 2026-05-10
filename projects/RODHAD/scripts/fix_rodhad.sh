#!/bin/bash

set -e

echo "======================================="
echo "FIXING RODHAD ARCHITECTURE"
echo "======================================="

cd ~/projects/RODHAD

# =======================================
# MATAR PUERTOS OCUPADOS
# =======================================

echo ""
echo "Liberando puertos..."

fuser -k 3000/tcp || true
fuser -k 4000/tcp || true
fuser -k 5000/tcp || true

sleep 2

# =======================================
# BACKEND
# =======================================

echo ""
echo "Configurando backend..."

mkdir -p backend

cat > backend/main.py <<EOF
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/')
def home():
    return jsonify({
        "status": "RODHAD Online",
        "version": "2.0"
    })

@app.route('/health')
def health():
    return jsonify({
        "backend": "ok"
    })

@app.route('/move', methods=['POST'])
def move():

    data = request.json

    direction = data.get("direction", "stop")

    print(f"Move command: {direction}")

    return jsonify({
        "status": "ok",
        "direction": direction
    })

@app.route('/command', methods=['POST'])
def command():

    data = request.json

    return jsonify({
        "received": data
    })

@app.route('/sensors')
def sensors():

    return jsonify({
        "temperature": 25,
        "battery": 88
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

cat > backend/requirements.txt <<EOF
flask
flask-cors
requests
gunicorn
EOF

cd backend

python3 -m venv venv || true

source venv/bin/activate

pip install -r requirements.txt

cd ..

# =======================================
# GATEWAY
# =======================================

echo ""
echo "Configurando gateway..."

rm -rf gateway/node_modules
rm -f gateway/package-lock.json

mkdir -p gateway

cat > gateway/package.json <<EOF
{
  "name": "rodhad-gateway",
  "version": "2.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "axios": "^1.15.2",
    "cors": "^2.8.6",
    "express": "^4.21.2"
  }
}
EOF

cat > gateway/server.js <<EOF
const express = require('express')
const cors = require('cors')
const axios = require('axios')

const app = express()

app.use(cors())
app.use(express.json())

const BACKEND = 'http://127.0.0.1:5000'

app.get('/', (req, res) => {
    res.json({
        gateway: 'online'
    })
})

app.post('/move', async (req, res) => {

    try {

        const response = await axios.post(
            \`\${BACKEND}/move\`,
            req.body
        )

        res.json(response.data)

    } catch (err) {

        res.status(500).json({
            error: err.message
        })

    }

})

app.listen(4000, () => {
    console.log('Gateway running on http://127.0.0.1:4000')
})
EOF

cd gateway

npm install

cd ..

# =======================================
# FRONTEND
# =======================================

echo ""
echo "Configurando frontend..."

rm -rf frontend/node_modules

mkdir -p frontend/public

cat > frontend/package.json <<EOF
{
  "name": "rodhad-frontend",
  "version": "1.0.0",
  "scripts": {
    "start": "npx serve public -l 3000"
  }
}
EOF

cat > frontend/public/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>RODHAD Dashboard</title>
</head>
<body>

<h1>RODHAD Dashboard</h1>

<button onclick="moveRobot('forward')">Forward</button>
<button onclick="moveRobot('left')">Left</button>
<button onclick="moveRobot('right')">Right</button>
<button onclick="moveRobot('stop')">Stop</button>

<pre id="output"></pre>

<script>

async function moveRobot(direction) {

    const response = await fetch(
        'http://127.0.0.1:4000/move',
        {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ direction })
        }
    )

    const data = await response.json()

    document.getElementById('output').innerText =
        JSON.stringify(data, null, 2)
}

</script>

</body>
</html>
EOF

cd frontend

npm install serve

cd ..

# =======================================
# FINAL
# =======================================

echo ""
echo "======================================="
echo "RODHAD FIXED"
echo "======================================="
echo ""

echo "TERMINAL 1"
echo "cd ~/projects/RODHAD/backend"
echo "source venv/bin/activate"
echo "python main.py"

echo ""
echo "TERMINAL 2"
echo "cd ~/projects/RODHAD/gateway"
echo "npm start"

echo ""
echo "TERMINAL 3"
echo "cd ~/projects/RODHAD/frontend"
echo "npm start"

echo ""
echo "Frontend:"
echo "http://localhost:3000"

echo ""
echo "Gateway:"
echo "http://localhost:4000"

echo ""
echo "Backend:"
echo "http://localhost:5000"

