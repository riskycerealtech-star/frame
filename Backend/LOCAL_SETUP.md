# 🚀 Local Development Setup Guide

## Quick Start

### Option 1: Run with uvicorn directly (Recommended)

```bash
# 1. Navigate to Backend directory
cd Backend

# 2. Create virtual environment (if not exists)
python3 -m venv venv

# 3. Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Run the server
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

**Server will be available at:**
- API: http://localhost:8080
- Swagger UI: http://localhost:8080/docs/frame/swagger-ui/index.html
- ReDoc: http://localhost:8080/docs/frame/redoc/index.html
- OpenAPI JSON: http://localhost:8080/docs/frame/openapi.json

---

### Option 2: Run with Docker Compose (with PostgreSQL)

```bash
# 1. Navigate to Backend directory
cd Backend

# 2. Start services (PostgreSQL + API)
docker-compose -f docker-compose.dev.yml up --build

# 3. Access the API
# API: http://localhost:8000
# Swagger: http://localhost:8000/docs/frame/swagger-ui/index.html
```

---

### Option 3: Run with Python directly

```bash
# 1. Navigate to Backend directory
cd Backend

# 2. Activate virtual environment
source venv/bin/activate

# 3. Run with Python
python main.py
```

---

## Environment Variables (Optional)

Create a `.env` file in the Backend directory:

```env
# Database (if using local PostgreSQL)
POSTGRES_SERVER=localhost
POSTGRES_USER=glass_user
POSTGRES_PASSWORD=glass_local_password
POSTGRES_DB=glass_db
POSTGRES_PORT=5432

# Google Cloud (optional for local dev)
GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account-key.json
GOOGLE_CLOUD_PROJECT_ID=glass-backend-api

# App Settings
SECRET_KEY=dev-secret-key-change-in-production
DEBUG=True
LOG_LEVEL=DEBUG
```

---

## Troubleshooting

### Port already in use
```bash
# Use a different port
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Missing dependencies
```bash
pip install --upgrade -r requirements.txt
```

### Database connection issues
- Make sure PostgreSQL is running (if using database)
- Check connection string in environment variables
- The app can run without database in "mock mode"

---

## Testing the API

### Health Check
```bash
curl http://localhost:8080/health
```

### Root Endpoint
```bash
curl http://localhost:8080/
```

### Swagger UI
Open in browser: http://localhost:8080/docs/frame/swagger-ui/index.html

