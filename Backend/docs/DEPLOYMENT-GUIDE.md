# Complete Deployment Guide

## 🚀 Deployment Overview

This guide covers all deployment methods for the Frame Backend API.

---

## 📋 Table of Contents

1. [Quick Deploy](#quick-deploy)
2. [Manual Deployment](#manual-deployment)
3. [Local Development](#local-development)
4. [Monitoring](#monitoring)
5. [Troubleshooting](#troubleshooting)

---

## ⚡ Quick Deploy

### Using Makefile

```bash
make deploy
```

### Using Script

```bash
./deploy.sh
```

### Using gcloud CLI

```bash
gcloud run deploy glass-api \
    --source . \
    --region us-central1 \
    --allow-unauthenticated
```

---

## 🛠️ Manual Deployment

### Prerequisites

```bash
# Install gcloud CLI
# Authenticate
gcloud auth login

# Set project
gcloud config set project glass-backend-api
```

### Deploy from Source

```bash
gcloud run deploy glass-api \
    --source . \
    --region us-central1 \
    --project glass-backend-api \
    --allow-unauthenticated \
    --add-cloudsql-instances glass-backend-api:us-central1:glass-db \
    --set-env-vars "POSTGRES_SERVER=/cloudsql/glass-backend-api:us-central1:glass-db,POSTGRES_USER=glass_user,POSTGRES_DB=glass_db,POSTGRES_PASSWORD=GlassUser2024Secure,GOOGLE_CLOUD_PROJECT_ID=glass-backend-api,SECRET_KEY=your-secret-key,DEBUG=False,LOG_LEVEL=INFO" \
    --memory 1Gi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 10 \
    --min-instances 0 \
    --port 8080
```

### Deploy from Docker Image

```bash
# Build and push image first
make build

# Then deploy
gcloud run deploy glass-api \
    --image us-central1-docker.pkg.dev/glass-backend-api/docker-repo/glass-api:latest \
    --region us-central1 \
    --allow-unauthenticated
```

---

## 🏠 Local Development

### Quick Start

```bash
# Start everything
make local-up

# Setup database
make db-setup

# Seed data
make seed

# Start API
make dev
```

See `docs/LOCAL-DEVELOPMENT.md` for detailed instructions.

---

## 📊 Monitoring

### Check Deployment Health

```bash
make check

# Or manually:
bash scripts/check-deployment.sh
```

### View Logs

```bash
# Cloud Run logs
gcloud run services logs read glass-api \
    --region us-central1 \
    --limit 50

# Follow logs
gcloud run services logs tail glass-api \
    --region us-central1
```

### Service Status

```bash
gcloud run services describe glass-api \
    --region us-central1 \
    --format="table(
        status.url,
        status.latestReadyRevisionName,
        status.conditions[0].status
    )"
```

### Health Check

```bash
curl https://glass-api-750669515844.us-central1.run.app/health
```

---

## 🔄 Rollback

### Using gcloud CLI

```bash
# List revisions
gcloud run revisions list \
    --service glass-api \
    --region us-central1

# Rollback
gcloud run services update-traffic glass-api \
    --to-revisions REVISION_NAME=100 \
    --region us-central1
```

---

## 🐛 Troubleshooting

### Deployment Fails

**Check:**
1. ✅ All environment variables are set
2. ✅ Database connection string is correct
3. ✅ Service account has permissions
4. ✅ Dockerfile is correct

**View logs:**
```bash
gcloud builds list --limit=1
gcloud builds log BUILD_ID
```

### Service Not Starting

**Check logs:**
```bash
gcloud run services logs read glass-api \
    --region us-central1 \
    --limit 100
```

**Common issues:**
- Database connection failed
- Missing environment variables
- Port configuration error

### Health Check Fails

**Check:**
1. ✅ Service is deployed
2. ✅ Health endpoint exists
3. ✅ Service is accessible
4. ✅ No errors in logs

---

## 📚 Additional Resources

- [Local Development Guide](LOCAL-DEVELOPMENT.md)
- [API Integration Guide](../mobile-integration/INTEGRATION-GUIDE.md)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)

---

## ✅ Deployment Checklist

- [ ] Environment variables configured
- [ ] Database connection tested
- [ ] Service account permissions set
- [ ] Health check passing
- [ ] Logs accessible
- [ ] Monitoring set up
- [ ] Rollback procedure tested

---

**Your deployment is ready! 🎉**



