# SnapBeat Gateway 🌐

Lightweight, high-performance API Gateway and Load Balancer for **SnapBeat**.

Routes video rendering requests from **SnapBeat Mobile App** and **SnapBeat Web** across one or multiple background rendering servers.

---

## Features
- **Ultra-Lightweight**: Only requires `FastAPI`, `Uvicorn`, and `HTTPX` (~150MB Docker image, runs smoothly on 256MB/512MB RAM free cloud tiers). No heavy OpenCV, FFmpeg, or ML libraries needed!
- **Zero Configuration**: Defaults to `http://localhost:8772` for local development.
- **Intelligent Load Balancing**: Polls backend servers (`/api/health`) and routes jobs to the least busy server.
- **Composite Job Routing**: Encodes backend origin into job IDs (`0_123`) so progress checks and video downloads automatically hit the right server.
- **CORS Enabled**: Out-of-the-box support for web and mobile clients.

---

## Running Locally

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Run gateway (pointing to local or remote render server)
SNAPBEAT_BACKENDS=http://localhost:8772 python gateway.py
```

---

## Free Cloud Hosting Deployment

### Option 1: Render.com (Recommended - 100% Free)
1. Push this `SnapBeat-Gateway` folder to a GitHub repository.
2. Sign in to [render.com](https://render.com) and click **New + &rarr; Web Service**.
3. Select your repository.
4. Settings:
   - **Environment**: `Python 3` (or `Docker`)
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `python gateway.py`
5. Under **Environment Variables**, add:
   - `SNAPBEAT_BACKENDS` = `http://YOUR_SERVER_PUBLIC_IP:8772`
6. Click **Deploy**. Render gives you a free HTTPS URL (e.g. `https://snapbeat-gateway.onrender.com`).

---

### Option 2: Railway.app
1. Go to [railway.app](https://railway.app).
2. Click **New Project &rarr; Deploy from GitHub repo**.
3. Add Variable `SNAPBEAT_BACKENDS=http://YOUR_SERVER_IP:8772`.
4. Railway automatically detects `Dockerfile` or `requirements.txt` and gives you a public domain.

---

### Option 3: Fly.io
```bash
fly launch
fly secrets set SNAPBEAT_BACKENDS=http://YOUR_SERVER_IP:8772
fly deploy
```

---

## API Endpoints Exposed
- `GET /` — Gateway status and backends count
- `GET /api/health` — Aggregated health of all connected rendering servers
- `POST /api/render/mobile` — Proxied render job submission
- `GET /api/render/status/{id}` — Proxied job status tracking
- `GET /api/render/download/{id}` — Proxied MP4 video streaming/download
