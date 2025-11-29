# 🚀 Deploy Backend to Google Cloud

Quick deployment guide for Frame Backend API to Google Cloud Run.

---

## Prerequisites

✅ Google Cloud account with billing enabled  
✅ `gcloud` CLI installed and authenticated  
✅ Project: `glass-backend-api`  
✅ Cloud SQL instance: `glass-db` (already set up)

---

## Option 1: Deploy from Local Machine (Recommended)

### Step 1: Navigate to Backend directory

```bash
cd Backend
```

### Step 2: Authenticate with Google Cloud

```bash
# Login to Google Cloud
gcloud auth login

# Set the project
gcloud config set project glass-backend-api
```

### Step 3: Run the deployment script

```bash
# Make script executable (if not already)
chmod +x deploy.sh

# Deploy
./deploy.sh
```

**What this does:**
- ✅ Verifies your setup
- ✅ Builds Docker image
- ✅ Pushes to Artifact Registry
- ✅ Deploys to Cloud Run
- ✅ Shows you the API URL

**Time:** ~15-20 minutes

---

## Option 2: Deploy from Google Cloud Shell

### Step 1: Open Cloud Shell

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click the Cloud Shell icon (top right)
3. Or visit: https://shell.cloud.google.com

### Step 2: Upload your code (if needed)

```bash
# Option A: Clone from Git (if you have a repo)
git clone <your-repo-url> Glass
cd Glass/Backend

# Option B: Upload files using Cloud Shell Editor
# Click "Open Editor" in Cloud Shell, then upload files
```

### Step 3: Run deployment script

```bash
cd Backend
chmod +x cloudshell-deploy.sh
./cloudshell-deploy.sh
```

---

## Option 3: Manual Deployment

If you prefer step-by-step control:

```bash
# 1. Set project
gcloud config set project glass-backend-api

# 2. Build Docker image
gcloud builds submit --tag us-central1-docker.pkg.dev/glass-backend-api/docker-repo/glass-api --timeout=20m

# 3. Deploy to Cloud Run
gcloud run deploy glass-api \
    --image us-central1-docker.pkg.dev/glass-backend-api/docker-repo/glass-api \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --add-cloudsql-instances glass-backend-api:us-central1:glass-db \
    --set-env-vars "POSTGRES_SERVER=/cloudsql/glass-backend-api:us-central1:glass-db" \
    --set-env-vars "POSTGRES_USER=glass_user" \
    --set-env-vars "POSTGRES_DB=glass_db" \
    --set-env-vars "POSTGRES_PASSWORD=GlassUser2024Secure" \
    --set-env-vars "GOOGLE_CLOUD_PROJECT_ID=glass-backend-api" \
    --set-env-vars "SECRET_KEY=your-secret-key-change-in-production-change-this" \
    --set-env-vars "DEBUG=False" \
    --set-env-vars "LOG_LEVEL=INFO" \
    --set-env-vars "BACKEND_CORS_ORIGINS=https://www.frameflea.com,https://frameflea.com,http://localhost:3000,http://localhost:8080" \
    --memory 1Gi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 10 \
    --min-instances 0 \
    --port 8080
```

---

## After Deployment

### Get your API URL

```bash
gcloud run services describe glass-api \
    --region us-central1 \
    --format="value(status.url)"
```

### Test your API

```bash
# Health check
curl https://glass-api-750669515844.us-central1.run.app/health

# Root endpoint
curl https://glass-api-750669515844.us-central1.run.app/

# Swagger docs
open https://glass-api-750669515844.us-central1.run.app/docs
```

### View logs

```bash
gcloud run services logs read glass-api --region us-central1 --limit 50
```

---

## Troubleshooting

### Build fails

```bash
# Check build logs
gcloud builds list --limit=1 --format="value(id)" | xargs -I {} gcloud builds log {}
```

### Deployment fails

```bash
# Check service logs
gcloud run services logs read glass-api --region us-central1 --limit 50
```

### Permission errors

```bash
# Ensure you have the right permissions
gcloud projects get-iam-policy glass-backend-api
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `./deploy.sh` | Full deployment from local |
| `./cloudshell-deploy.sh` | Quick deployment from Cloud Shell |
| `gcloud run services list` | List all Cloud Run services |
| `gcloud run services describe glass-api --region us-central1` | Service details |
| `gcloud run services logs read glass-api --region us-central1` | View logs |

---

## Next Steps

After successful deployment:

1. ✅ **Configure custom domain**: `./configure-domain.sh`
2. ✅ **Update Flutter app**: Use the new API URL
3. ✅ **Monitor**: Check Cloud Run console for metrics

---

## Support

- 📖 Full guide: `docs/GOOGLE_CLOUD_DEPLOYMENT_GUIDE.md`
- 🔍 Verify setup: `./verify-setup.sh`
- 📚 API docs: `https://glass-api-750669515844.us-central1.run.app/docs`





