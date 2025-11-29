# Local Development Setup Guide

## 🏠 Quick Start

Get your local development environment running in minutes!

---

## 📋 Prerequisites

- Docker and Docker Compose installed
- Python 3.12+ (for running scripts)
- Git

---

## 🚀 Option 1: Docker Compose (Recommended)

### Start Everything

```bash
# Start database and API
make local-up

# Or manually:
docker-compose -f docker-compose.dev.yml up -d
```

This starts:
- ✅ PostgreSQL database on port 5432
- ✅ FastAPI server on port 8000
- ✅ PgAdmin on port 5050 (optional)

### Access Services

- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/api/v1/docs
- **PgAdmin**: http://localhost:5050 (admin@glass.local / admin)

### Stop Everything

```bash
make local-down

# Or manually:
docker-compose -f docker-compose.dev.yml down
```

---

## 🗄️ Option 2: Database Only

### Start Database

```bash
make db-up

# Or manually:
docker-compose up -d postgres
```

### Setup Database

```bash
make db-setup

# Or manually:
bash scripts/setup-local-db.sh
```

### Seed Sample Data

```bash
make seed

# Or manually:
python scripts/seed-data.py
```

### Run API Locally

```bash
# Install dependencies
make install

# Start server
make dev

# Or manually:
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

## ⚙️ Environment Configuration

### Create .env File

```bash
cp .env.example .env
```

### Edit .env

```env
# Database (for local PostgreSQL)
POSTGRES_SERVER=localhost
POSTGRES_USER=glass_user
POSTGRES_PASSWORD=glass_local_password
POSTGRES_DB=glass_db
POSTGRES_PORT=5432

# Security
SECRET_KEY=your-local-secret-key
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Application
DEBUG=True
LOG_LEVEL=DEBUG

# Google Cloud (optional for local)
GOOGLE_CLOUD_PROJECT_ID=glass-backend-api
```

---

## 🧪 Testing

### Run Tests

```bash
make test

# Or manually:
bash scripts/run-tests.sh
```

### Run Linter

```bash
make lint
```

### Format Code

```bash
make format
```

---

## 📊 Database Management

### Connect to Database

```bash
# Using psql
psql -h localhost -U glass_user -d glass_db

# Using Docker
docker exec -it glass-postgres psql -U glass_user -d glass_db
```

### Run Migrations

```bash
make migrate

# Or manually:
alembic upgrade head
```

### Create Migration

```bash
make migrate-create MESSAGE="Add new table"

# Or manually:
alembic revision --autogenerate -m "Add new table"
```

### Reset Database

```bash
# Stop containers
docker-compose down -v

# Start fresh
docker-compose up -d postgres
make db-setup
make seed
```

---

## 🔧 Common Commands

### Using Makefile

```bash
make help          # Show all commands
make install       # Install dependencies
make test          # Run tests
make lint          # Run linter
make format        # Format code
make local-up      # Start local environment
make local-down    # Stop local environment
make local-logs    # View logs
make db-setup      # Setup database
make seed          # Seed sample data
make clean         # Clean generated files
```

### Manual Commands

```bash
# Start services
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop services
docker-compose -f docker-compose.dev.yml down

# Restart services
docker-compose -f docker-compose.dev.yml restart
```

---

## 🐛 Troubleshooting

### Port Already in Use

**Error**: `port 5432 is already allocated`

**Solution**:
```bash
# Find process using port
lsof -i :5432

# Kill process
kill -9 PID

# Or change port in docker-compose.yml
```

### Database Connection Failed

**Error**: `could not connect to server`

**Solution**:
```bash
# Check if container is running
docker ps | grep postgres

# Check logs
docker-compose logs postgres

# Restart container
docker-compose restart postgres
```

### Migration Errors

**Error**: `Target database is not up to date`

**Solution**:
```bash
# Check current revision
alembic current

# Upgrade to head
alembic upgrade head

# Or reset database
make db-setup
```

---

## 🔄 Switching Environments

### Local vs Cloud Database

Use the switch script:

```bash
# Use local database
source switch-env.sh local
uvicorn app.main:app --reload

# Use cloud database (requires Cloud SQL Proxy)
source switch-env.sh cloud
uvicorn app.main:app --reload
```

---

## 📝 Development Workflow

### Typical Workflow

1. **Start environment**
   ```bash
   make local-up
   ```

2. **Make changes**
   - Edit code
   - API auto-reloads (if using `--reload`)

3. **Run tests**
   ```bash
   make test
   ```

4. **Check code quality**
   ```bash
   make lint
   make format
   ```

5. **Commit changes**
   ```bash
   git add .
   git commit -m "Your changes"
   git push
   ```

6. **Deploy** (automatic via CI/CD)

---

## 🎯 Next Steps

1. ✅ Integrate with mobile app (see `mobile-integration/INTEGRATION-GUIDE.md`)
2. ✅ Set up monitoring
3. ✅ Configure production environment

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)

---

**Happy coding! 🚀**



