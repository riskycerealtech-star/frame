# Local Development Setup Guide

## 🏠 Local Database Setup

### Option 1: Local PostgreSQL (Recommended for Development)

#### 1. Install PostgreSQL

**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**Windows:**
Download and install from [PostgreSQL Downloads](https://www.postgresql.org/download/windows/)

#### 2. Create Database and User

```bash
# Connect to PostgreSQL
psql postgres

# Create database
CREATE DATABASE glass_db;

# Create user
CREATE USER glass_user WITH PASSWORD 'your_local_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE glass_db TO glass_user;

# Exit
\q
```

#### 3. Configure Environment Variables

Create a `.env` file in the `Backend` directory:

```bash
cp .env.example .env
```

Edit `.env` with your local settings:

```env
POSTGRES_SERVER=localhost
POSTGRES_USER=glass_user
POSTGRES_PASSWORD=your_local_password
POSTGRES_DB=glass_db
POSTGRES_PORT=5432
SECRET_KEY=your-local-secret-key
DEBUG=True
LOG_LEVEL=DEBUG
```

#### 4. Run Database Migrations

```bash
cd Backend
alembic upgrade head
```

#### 5. Start Local Server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Your API will be available at: `http://localhost:8000`

---

### Option 2: Cloud SQL Proxy (Connect to Production Database)

Use this if you want to test against your production database locally.

#### 1. Install Cloud SQL Proxy

**macOS:**
```bash
brew install cloud-sql-proxy
```

**Linux:**
```bash
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy
sudo mv cloud-sql-proxy /usr/local/bin/
```

#### 2. Authenticate

```bash
gcloud auth application-default login
```

#### 3. Start Cloud SQL Proxy

```bash
cloud-sql-proxy glass-backend-api:us-central1:glass-db \
    --port 5432
```

Keep this terminal open. The proxy will forward connections to Cloud SQL.

#### 4. Update .env

```env
POSTGRES_SERVER=localhost
POSTGRES_USER=glass_user
POSTGRES_PASSWORD=GlassUser2024Secure
POSTGRES_DB=glass_db
POSTGRES_PORT=5432
```

#### 5. Start Local Server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

## 🔄 Switching Between Local and Production

### Environment Detection

The app automatically detects the environment:

- **Local Development**: Uses `localhost` or TCP connection
- **Cloud Run**: Uses Unix socket (`/cloudsql/...`)

### Quick Switch Script

Create `switch-env.sh`:

```bash
#!/bin/bash

if [ "$1" == "local" ]; then
    export POSTGRES_SERVER=localhost
    export POSTGRES_USER=glass_user
    export POSTGRES_PASSWORD=your_local_password
    export POSTGRES_DB=glass_db
    echo "✅ Switched to LOCAL database"
elif [ "$1" == "cloud" ]; then
    export POSTGRES_SERVER=/cloudsql/glass-backend-api:us-central1:glass-db
    export POSTGRES_USER=glass_user
    export POSTGRES_PASSWORD=GlassUser2024Secure
    export POSTGRES_DB=glass_db
    echo "✅ Switched to CLOUD database"
else
    echo "Usage: source switch-env.sh [local|cloud]"
fi
```

Usage:
```bash
source switch-env.sh local
uvicorn app.main:app --reload
```

---

## 🧪 Testing Locally

### 1. Health Check

```bash
curl http://localhost:8000/health
```

### 2. API Documentation

Open in browser: `http://localhost:8000/api/v1/docs`

### 3. Test Endpoints

```bash
# Test authentication
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

---

## 🐛 Debugging

### View Logs

```bash
# Application logs
tail -f server.log

# Database queries (if DEBUG=True)
# SQL queries will be printed to console
```

### Database Connection Issues

1. **Check PostgreSQL is running:**
   ```bash
   # macOS
   brew services list
   
   # Linux
   sudo systemctl status postgresql
   ```

2. **Test connection:**
   ```bash
   psql -h localhost -U glass_user -d glass_db
   ```

3. **Check firewall:**
   ```bash
   # macOS
   sudo pfctl -s rules
   ```

---

## 📝 Environment Variables Reference

| Variable | Local | Production |
|----------|-------|------------|
| `POSTGRES_SERVER` | `localhost` | `/cloudsql/...` |
| `POSTGRES_USER` | `glass_user` | `glass_user` |
| `POSTGRES_PASSWORD` | Your local password | Production password |
| `POSTGRES_DB` | `glass_db` | `glass_db` |
| `DEBUG` | `True` | `False` |
| `LOG_LEVEL` | `DEBUG` | `INFO` |

---

## 🚀 Quick Start Commands

```bash
# 1. Setup local database
createdb glass_db
createuser glass_user

# 2. Copy environment file
cp .env.example .env
# Edit .env with your settings

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run migrations
alembic upgrade head

# 5. Start server
uvicorn app.main:app --reload
```

---

## 🔐 Security Notes

- **Never commit `.env` file** to git
- Use different passwords for local and production
- Use strong `SECRET_KEY` in production
- Keep `DEBUG=False` in production

---

## 📚 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Cloud SQL Proxy Documentation](https://cloud.google.com/sql/docs/postgres/sql-proxy)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)



