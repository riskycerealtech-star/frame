# Google Cloud Deployment Guide for Glass Backend API

## 📋 Table of Contents
1. [Overview](#overview)
2. [Application Architecture](#application-architecture)
3. [Google Cloud Hosting Options](#google-cloud-hosting-options)
4. [Recommended Solution: Cloud Run](#recommended-solution-cloud-run)
5. [Prerequisites](#prerequisites)
6. [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
7. [Database Setup (Cloud SQL)](#database-setup-cloud-sql)
8. [Environment Variables & Secrets](#environment-variables--secrets)
9. [Cost Estimates](#cost-estimates)
10. [Monitoring & Logging](#monitoring--logging)
11. [Troubleshooting](#troubleshooting)

---

## Overview

Your **Glass Backend API** is a FastAPI application that provides:
- ✅ User authentication (JWT tokens)
- ✅ AI-powered sunglasses detection (Google Cloud Vision API)
- ✅ RESTful API with Swagger documentation
- ✅ PostgreSQL database integration
- ✅ Product, order, and review management

**Current Stack:**
- **Framework**: FastAPI (Python)
- **Database**: PostgreSQL
- **ORM**: SQLAlchemy
- **AI Service**: Google Cloud Vision API
- **Authentication**: JWT tokens

---

## Application Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Mobile)       │
└────────┬────────┘
         │ HTTPS
         ▼
┌─────────────────────────────────────┐
│   Google Cloud Run                  │
│   (FastAPI Backend)                 │
│   - User Authentication             │
│   - AI Validation                   │
│   - Product Management              │
└────────┬────────────────────────────┘
         │
         ├─────────────────┐
         │                 │
         ▼                 ▼
┌──────────────┐  ┌──────────────────┐
│  Cloud SQL   │  │  Cloud Vision    │
│  PostgreSQL  │  │  API             │
└──────────────┘  └──────────────────┘
```

---

## Google Cloud Hosting Options

### Option 1: Cloud Run ⭐ **RECOMMENDED**

**What it is:**
- Fully managed serverless platform for containers
- Auto-scales from 0 to thousands of instances
- Pay only for what you use (per request)
- No server management required

**Pros:**
- ✅ **Cost-effective**: Pay per request, scales to zero
- ✅ **Easy deployment**: Just push a Docker container
- ✅ **Auto-scaling**: Handles traffic spikes automatically
- ✅ **Fast cold starts**: ~1-2 seconds
- ✅ **HTTPS included**: Free SSL certificates
- ✅ **Perfect for FastAPI**: Designed for stateless APIs

**Cons:**
- ⚠️ Cold starts (1-2 seconds) if no traffic for a while
- ⚠️ 60-minute request timeout limit
- ⚠️ 2GB memory limit per instance (can be increased)

**Best for:** Production APIs, microservices, cost-effective scaling

**Estimated Cost:** $0.40 per million requests + compute time

---

### Option 2: App Engine (Flexible Environment)

**What it is:**
- Fully managed platform-as-a-service (PaaS)
- Automatically handles infrastructure, scaling, and load balancing

**Pros:**
- ✅ No Docker knowledge required
- ✅ Automatic scaling and load balancing
- ✅ Built-in health checks
- ✅ Version management and traffic splitting

**Cons:**
- ⚠️ More expensive than Cloud Run
- ⚠️ Slower deployments
- ⚠️ Less flexible than containers
- ⚠️ Minimum cost even with no traffic

**Best for:** Traditional web apps, teams without Docker experience

**Estimated Cost:** ~$50-100/month minimum (even with no traffic)

---

### Option 3: Compute Engine (VMs)

**What it is:**
- Virtual machines on Google Cloud
- Full control over the operating system and software

**Pros:**
- ✅ Full control and flexibility
- ✅ Can run any software
- ✅ Predictable pricing

**Cons:**
- ❌ You manage everything (OS updates, security, scaling)
- ❌ More expensive for low traffic
- ❌ Requires DevOps knowledge
- ❌ Manual scaling setup

**Best for:** Legacy applications, specific OS requirements, high control needs

**Estimated Cost:** ~$25-50/month minimum (always running)

---

## Recommended Solution: Cloud Run

**Why Cloud Run is best for your FastAPI backend:**

1. **Cost-Effective**: Pay only when requests are processed
2. **Auto-Scaling**: Handles traffic spikes automatically
3. **Easy Deployment**: Simple Docker-based deployment
4. **FastAPI Optimized**: Perfect for stateless REST APIs
5. **Production Ready**: Built-in HTTPS, logging, monitoring

---

## Prerequisites

Before deploying, ensure you have:

1. ✅ **Google Cloud Account**
   - Sign up at [cloud.google.com](https://cloud.google.com)
   - Free tier includes $300 credit for 90 days

2. ✅ **Google Cloud SDK (gcloud CLI)**
   ```bash
   # Install gcloud CLI
   # macOS:
   brew install google-cloud-sdk
   
   # Or download from:
   # https://cloud.google.com/sdk/docs/install
   ```

3. ✅ **Docker** (for building containers)
   ```bash
   # Install Docker Desktop
   # https://www.docker.com/products/docker-desktop
   ```

4. ✅ **Google Cloud Project**
   ```bash
   # Create a new project
   gcloud projects create glass-backend-api --name="Glass Backend API"
   
   # Set as default project
   gcloud config set project glass-backend-api
   ```

5. ✅ **Enable Required APIs**
   ```bash
   # Enable Cloud Run API
   gcloud services enable run.googleapis.com
   
   # Enable Cloud SQL Admin API
   gcloud services enable sqladmin.googleapis.com
   
   # Enable Cloud Build API (for building containers)
   gcloud services enable cloudbuild.googleapis.com
   
   # Enable Vision API (if not already enabled)
   gcloud services enable vision.googleapis.com
   
   # Enable Secret Manager API (for storing secrets)
   gcloud services enable secretmanager.googleapis.com
   ```

---

## Step-by-Step Deployment Guide

### Step 1: Prepare Your Application

#### 1.1 Create Dockerfile

Create a `Dockerfile` in your Backend directory:

```dockerfile
# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port (Cloud Run uses PORT environment variable)
EXPOSE 8080

# Use environment variable for port (Cloud Run requirement)
ENV PORT=8080

# Run the application
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080} --workers 1
```

#### 1.2 Create .dockerignore

Create `.dockerignore` to exclude unnecessary files:

```
__pycache__
*.pyc
*.pyo
*.pyd
.Python
venv/
env/
.venv
.env
*.log
.git
.gitignore
README.md
.pytest_cache
.coverage
htmlcov/
.mypy_cache
.dockerignore
Dockerfile
alembic.ini
migrations/
tests/
docs/
server.log
```

#### 1.3 Create requirements.txt

If you don't have one, create `requirements.txt` with your dependencies:

```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
pydantic==2.5.0
pydantic-settings==2.1.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
google-cloud-vision==3.4.5
google-auth==2.23.4
pillow==10.1.0
alembic==1.12.1
```

#### 1.4 Update main.py for Cloud Run

Ensure your FastAPI app can read the PORT environment variable:

```python
import os
port = int(os.environ.get("PORT", 8000))
```

---

### Step 2: Set Up Cloud SQL (PostgreSQL Database)

#### 2.1 Create Cloud SQL Instance

```bash
# Create a PostgreSQL instance
gcloud sql instances create glass-db \
    --database-version=POSTGRES_15 \
    --tier=db-f1-micro \
    --region=us-central1 \
    --root-password=YOUR_SECURE_PASSWORD

# Note: Replace YOUR_SECURE_PASSWORD with a strong password
# Note: db-f1-micro is the smallest/cheapest tier (shared-core, 0.6GB RAM)
# For production, consider db-g1-small or higher
```

**Instance Tiers:**
- `db-f1-micro`: $7.67/month (shared-core, 0.6GB RAM) - **Development**
- `db-g1-small`: $25/month (1 vCPU, 1.7GB RAM) - **Production (small)**
- `db-n1-standard-1`: $50/month (1 vCPU, 3.75GB RAM) - **Production (medium)**

#### 2.2 Create Database

```bash
# Create database
gcloud sql databases create glass_db --instance=glass-db
```

#### 2.3 Create Database User

```bash
# Create user
gcloud sql users create glass_user \
    --instance=glass-db \
    --password=YOUR_DB_PASSWORD
```

#### 2.4 Get Connection Name

```bash
# Get connection name (needed for Cloud Run)
gcloud sql instances describe glass-db --format="value(connectionName)"
# Output: PROJECT_ID:REGION:glass-db
```

---

### Step 3: Store Secrets in Secret Manager

#### 3.1 Store Database Password

```bash
# Store database password
echo -n "YOUR_DB_PASSWORD" | gcloud secrets create db-password --data-file=-

# Store database user
echo -n "glass_user" | gcloud secrets create db-user --data-file=-

# Store JWT secret key
echo -n "your-super-secret-jwt-key-change-in-production" | gcloud secrets create jwt-secret --data-file=-
```

#### 3.2 Grant Cloud Run Access to Secrets

```bash
# Get your service account email
PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="${PROJECT_ID}@appspot.gserviceaccount.com"

# Grant access to secrets
gcloud secrets add-iam-policy-binding db-password \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding db-user \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding jwt-secret \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor"
```

---

### Step 4: Build and Deploy to Cloud Run

#### 4.1 Build Container Image

```bash
# Navigate to Backend directory
cd Backend

# Build using Cloud Build
gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/glass-api

# Or build locally and push
docker build -t gcr.io/$(gcloud config get-value project)/glass-api .
docker push gcr.io/$(gcloud config get-value project)/glass-api
```

#### 4.2 Deploy to Cloud Run

```bash
# Get connection name
CONNECTION_NAME=$(gcloud sql instances describe glass-db --format="value(connectionName)")
PROJECT_ID=$(gcloud config get-value project)

# Deploy to Cloud Run
gcloud run deploy glass-api \
    --image gcr.io/${PROJECT_ID}/glass-api \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --add-cloudsql-instances ${CONNECTION_NAME} \
    --set-env-vars "POSTGRES_SERVER=/cloudsql/${CONNECTION_NAME}" \
    --set-env-vars "POSTGRES_USER=glass_user" \
    --set-env-vars "POSTGRES_DB=glass_db" \
    --set-secrets "POSTGRES_PASSWORD=db-password:latest" \
    --set-secrets "SECRET_KEY=jwt-secret:latest" \
    --set-env-vars "GOOGLE_CLOUD_PROJECT_ID=${PROJECT_ID}" \
    --memory 1Gi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 10 \
    --min-instances 0
```

**Deployment Options Explained:**
- `--memory 1Gi`: 1GB RAM (adjust based on needs)
- `--cpu 1`: 1 vCPU
- `--timeout 300`: 5-minute request timeout
- `--max-instances 10`: Maximum concurrent instances
- `--min-instances 0`: Scale to zero when no traffic (saves money)
- `--allow-unauthenticated`: Public API (remove for private APIs)

#### 4.3 Update Database Connection String

Your app needs to use Unix socket for Cloud SQL connection. Update `app/db/session.py`:

```python
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# Cloud SQL connection
if os.environ.get("POSTGRES_SERVER", "").startswith("/cloudsql/"):
    # Cloud SQL Unix socket connection
    DATABASE_URL = f"postgresql+psycopg2://{settings.POSTGRES_USER}:{settings.POSTGRES_PASSWORD}@{settings.POSTGRES_SERVER}/{settings.POSTGRES_DB}"
else:
    # Standard TCP connection (local development)
    DATABASE_URL = settings.DATABASE_URL

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    echo=settings.LOG_LEVEL == "DEBUG"
)
```

---

### Step 5: Run Database Migrations

#### 5.1 Create Migration Job (One-time)

```bash
# Deploy a one-time migration job
gcloud run jobs create glass-migrate \
    --image gcr.io/${PROJECT_ID}/glass-api \
    --region us-central1 \
    --add-cloudsql-instances ${CONNECTION_NAME} \
    --set-env-vars "POSTGRES_SERVER=/cloudsql/${CONNECTION_NAME}" \
    --set-env-vars "POSTGRES_USER=glass_user" \
    --set-env-vars "POSTGRES_DB=glass_db" \
    --set-secrets "POSTGRES_PASSWORD=db-password:latest" \
    --command "alembic" \
    --args "upgrade,head" \
    --memory 512Mi \
    --cpu 1

# Execute the migration
gcloud run jobs execute glass-migrate --region us-central1
```

---

### Step 6: Configure CORS for Your Flutter App

Update your Cloud Run service to allow your Flutter app's domain:

```bash
# Update CORS settings (you'll need to update your FastAPI CORS middleware)
# In your main.py, update:
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://your-flutter-app-domain.com",
        "http://localhost:3000",  # For local development
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

### Step 7: Get Your API URL

After deployment, get your API URL:

```bash
# Get service URL
gcloud run services describe glass-api --region us-central1 --format="value(status.url)"

# Example output: https://glass-api-xxxxx-uc.a.run.app
```

Your API will be available at:
- **API Base URL**: `https://glass-api-xxxxx-uc.a.run.app`
- **Swagger Docs**: `https://glass-api-xxxxx-uc.a.run.app/docs/frame/swagger-ui/index.html`
- **Health Check**: `https://glass-api-xxxxx-uc.a.run.app/health`

---

## Database Setup (Cloud SQL)

### Connection Methods

**1. Unix Socket (Recommended for Cloud Run)**
```
postgresql+psycopg2://user:password@/cloudsql/PROJECT:REGION:INSTANCE/dbname
```

**2. Private IP (Recommended for production)**
- Enable private IP on Cloud SQL instance
- Connect from Cloud Run using private IP

**3. Public IP (Not recommended for production)**
- Requires authorized networks
- Less secure

### Enable Private IP (Optional but Recommended)

```bash
# Allocate IP range
gcloud compute addresses create google-managed-services-default \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --network=default

# Create VPC peering
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-default \
    --network=default

# Update Cloud SQL instance to use private IP
gcloud sql instances patch glass-db \
    --network=default \
    --no-assign-ip
```

---

## Environment Variables & Secrets

### Required Environment Variables

| Variable | Source | Description |
|----------|--------|-------------|
| `POSTGRES_SERVER` | Env Var | Cloud SQL connection name or IP |
| `POSTGRES_USER` | Env Var | Database username |
| `POSTGRES_PASSWORD` | Secret | Database password |
| `POSTGRES_DB` | Env Var | Database name |
| `SECRET_KEY` | Secret | JWT signing key |
| `GOOGLE_CLOUD_PROJECT_ID` | Env Var | GCP project ID |
| `PORT` | Auto-set | Cloud Run port (8080) |

### Update Environment Variables

```bash
# Update environment variables
gcloud run services update glass-api \
    --region us-central1 \
    --update-env-vars "NEW_VAR=value"

# Update secrets
gcloud run services update glass-api \
    --region us-central1 \
    --update-secrets "SECRET_NAME=secret-name:latest"
```

---

## Cost Estimates

### Monthly Cost Breakdown (Estimated)

**Cloud Run:**
- Free tier: 2 million requests/month
- After free tier: $0.40 per million requests
- Compute: $0.00002400 per vCPU-second, $0.00000250 per GiB-second
- **Estimated**: $5-20/month (depending on traffic)

**Cloud SQL (db-f1-micro):**
- **$7.67/month** (always running)
- Storage: $0.17 per GB/month
- Backups: $0.08 per GB/month
- **Estimated**: $10-15/month

**Cloud Vision API:**
- First 1,000 units/month: **FREE**
- 1,001-5,000,000: $1.50 per 1,000 units
- **Estimated**: $0-50/month (depending on usage)

**Secret Manager:**
- First 6 secrets: **FREE**
- Additional: $0.06 per secret per month

**Total Estimated Cost:**
- **Low traffic** (< 1M requests/month): **~$15-25/month**
- **Medium traffic** (1-10M requests/month): **~$25-75/month**
- **High traffic** (> 10M requests/month): **~$75-200/month**

**Note:** Google Cloud offers $300 free credit for 90 days for new accounts!

---

## Monitoring & Logging

### View Logs

```bash
# View logs in real-time
gcloud run services logs read glass-api --region us-central1 --follow

# View logs in Cloud Console
# https://console.cloud.google.com/run
```

### Set Up Monitoring

1. **Cloud Monitoring**: Automatic metrics collection
2. **Cloud Logging**: Centralized log management
3. **Error Reporting**: Automatic error tracking
4. **Uptime Checks**: Monitor API availability

### Create Uptime Check

```bash
# Create uptime check
gcloud monitoring uptime-checks create glass-api-check \
    --display-name="Glass API Health Check" \
    --http-check-path="/health" \
    --http-check-use-ssl \
    --resource-type=uptime-url \
    --hostname=glass-api-xxxxx-uc.a.run.app
```

---

## Troubleshooting

### Common Issues

#### 1. "Connection refused" to Cloud SQL

**Solution:**
- Ensure Cloud SQL instance is running
- Check connection name format: `/cloudsql/PROJECT:REGION:INSTANCE`
- Verify Cloud Run service has Cloud SQL connection added

#### 2. "Secret not found" error

**Solution:**
- Verify secret exists: `gcloud secrets list`
- Check IAM permissions for service account
- Ensure secret version is correct (use `:latest`)

#### 3. Cold start delays

**Solution:**
- Set `--min-instances 1` to keep one instance warm
- Optimize Docker image size
- Reduce startup time in application code

#### 4. "Out of memory" errors

**Solution:**
- Increase memory: `--memory 2Gi`
- Optimize application memory usage
- Check for memory leaks

#### 5. Database connection pool exhausted

**Solution:**
- Increase Cloud SQL instance size
- Optimize connection pooling in SQLAlchemy
- Reduce connection timeout

### Useful Commands

```bash
# View service details
gcloud run services describe glass-api --region us-central1

# View service logs
gcloud run services logs read glass-api --region us-central1

# Update service
gcloud run services update glass-api --region us-central1 --memory 2Gi

# Delete service
gcloud run services delete glass-api --region us-central1

# List all services
gcloud run services list
```

---

## Next Steps

1. ✅ **Set up CI/CD**: Automate deployments with Cloud Build
2. ✅ **Enable CDN**: Use Cloud CDN for faster response times
3. ✅ **Set up custom domain**: Map your domain to Cloud Run
4. ✅ **Enable authentication**: Use Cloud IAM for private APIs
5. ✅ **Set up alerts**: Configure monitoring alerts
6. ✅ **Backup strategy**: Set up automated Cloud SQL backups
7. ✅ **Load testing**: Test your API under load

---

## Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [FastAPI Deployment Guide](https://fastapi.tiangolo.com/deployment/)
- [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator)

---

## Summary

**Recommended Deployment:**
- **Platform**: Cloud Run
- **Database**: Cloud SQL (PostgreSQL)
- **Secrets**: Secret Manager
- **Monitoring**: Cloud Logging & Monitoring

**Estimated Monthly Cost**: $15-75 (depending on traffic)

**Deployment Time**: 1-2 hours (first time)

This setup provides a production-ready, scalable, and cost-effective solution for your FastAPI backend! 🚀

