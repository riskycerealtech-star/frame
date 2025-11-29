# Deployment Guide for Frame Backend API

## 🚀 Quick Start

### Option 1: Deploy from Your Local Machine (Recommended)

1. **Verify setup:**
   ```bash
   ./verify-setup.sh
   ```

2. **Deploy:**
   ```bash
   ./deploy.sh
   ```

### Option 2: Deploy from Google Cloud Shell

1. **Open Cloud Shell** in Google Cloud Console
2. **Upload your Backend folder** to Cloud Shell
3. **Run:**
   ```bash
   ./cloudshell-deploy.sh
   ```

---

## 📋 Prerequisites

Before deploying, ensure you have:

- ✅ Google Cloud account with billing enabled
- ✅ Project: `glass-backend-api`
- ✅ All required APIs enabled
- ✅ Cloud Build service account has required permissions
- ✅ Cloud SQL instance created (`glass-db`)
- ✅ Database and user created

---

## 🔍 Verification Script

**File:** `verify-setup.sh`

**What it does:**
- Checks if project is set correctly
- Verifies all required APIs are enabled
- Checks IAM permissions for Cloud Build service account
- Verifies Artifact Registry repository exists
- Checks Cloud SQL setup
- Validates required files exist

**Run it:**
```bash
./verify-setup.sh
```

**Output:**
- ✅ Green checkmarks = Everything is good
- ❌ Red X = Something needs to be fixed
- ⚠️ Yellow warning = Optional, but recommended

---

## 🚀 Deployment Script

**File:** `deploy.sh`

**What it does:**
1. Runs verification first
2. Sets project explicitly
3. Creates Artifact Registry repository if needed
4. Builds Docker image (10-15 minutes)
5. Deploys to Cloud Run (5-10 minutes)
6. Shows your API URL

**Run it:**
```bash
./deploy.sh
```

**Features:**
- ✅ Automatic verification
- ✅ Explicit project/region flags
- ✅ 20-minute build timeout
- ✅ Clear error messages
- ✅ Shows deployment duration
- ✅ Provides helpful commands if it fails

---

## ☁️ Cloud Shell Deployment

**File:** `cloudshell-deploy.sh`

**When to use:**
- If you're having permission issues locally
- If you want to deploy from Google Cloud Console
- If you prefer a simpler deployment process

**How to use:**
1. Open [Google Cloud Shell](https://shell.cloud.google.com/)
2. Upload your `Backend` folder
3. Run:
   ```bash
   chmod +x cloudshell-deploy.sh
   ./cloudshell-deploy.sh
   ```

**Advantages:**
- No permission setup needed
- Cloud Shell has all required permissions
- Faster deployment (no local upload)

---

## 🔧 Troubleshooting

### Error: "Permission denied"

**Solution:**
```bash
# Run the setup script
./setup-permissions.sh

# Or manually grant permissions
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:750669515844@cloudbuild.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"
```

---

### Error: "API not enabled"

**Solution:**
```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
```

---

### Error: "Build failed"

**Check build logs:**
```bash
# Get latest build ID
BUILD_ID=$(gcloud builds list --limit=1 --format="value(id)")

# View logs
gcloud builds log ${BUILD_ID}
```

**Common causes:**
- Missing dependencies in requirements.txt
- Dockerfile syntax error
- Python version incompatibility

---

### Error: "Deployment failed"

**Check deployment logs:**
```bash
gcloud run services logs read glass-api --region us-central1 --limit 50
```

**Common causes:**
- Database connection issues
- Missing environment variables
- Application startup errors

---

### Error: "Repository not found"

**Create repository:**
```bash
gcloud artifacts repositories create docker-repo \
    --repository-format=docker \
    --location=us-central1
```

---

## 📊 Checking Deployment Status

### View service details:
```bash
gcloud run services describe glass-api --region us-central1
```

### View logs:
```bash
gcloud run services logs read glass-api --region us-central1 --limit 50
```

### View recent builds:
```bash
gcloud builds list --limit=5
```

### Get service URL:
```bash
gcloud run services describe glass-api --region us-central1 --format="value(status.url)"
```

---

## 🔄 Updating Your Deployment

To update your API after making changes:

1. **Make your code changes**
2. **Run deploy again:**
   ```bash
   ./deploy.sh
   ```

The script will:
- Build a new Docker image
- Deploy the new version
- Keep the same URL (no changes needed in your Flutter app)

---

## 🗑️ Deleting Deployment

If you need to delete the service:

```bash
gcloud run services delete glass-api --region us-central1
```

**Note:** This does NOT delete:
- Cloud SQL database
- Artifact Registry images
- Other resources

---

## 📝 Environment Variables

Your deployment uses these environment variables:

| Variable | Value | Description |
|----------|-------|-------------|
| `POSTGRES_SERVER` | `/cloudsql/glass-backend-api:us-central1:glass-db` | Cloud SQL connection |
| `POSTGRES_USER` | `glass_user` | Database username |
| `POSTGRES_DB` | `glass_db` | Database name |
| `POSTGRES_PASSWORD` | `GlassUser2024Secure` | Database password |
| `GOOGLE_CLOUD_PROJECT_ID` | `glass-backend-api` | GCP project ID |
| `SECRET_KEY` | `your-secret-key...` | JWT secret (change in production!) |
| `DEBUG` | `False` | Debug mode |
| `LOG_LEVEL` | `INFO` | Logging level |

**To update environment variables:**
```bash
gcloud run services update glass-api \
    --region us-central1 \
    --update-env-vars "NEW_VAR=value"
```

---

## 🔐 Security Notes

**Important:** Before going to production:

1. **Change SECRET_KEY:**
   - Generate a strong random key
   - Update in deployment script
   - Store in Secret Manager (recommended)

2. **Change database password:**
   - Use a strong password
   - Store in Secret Manager

3. **Restrict CORS:**
   - Update CORS settings in your FastAPI app
   - Only allow your Flutter app's domain

4. **Use Secret Manager:**
   - Store sensitive values in Secret Manager
   - Reference them in Cloud Run

---

## 📞 Getting Help

If you encounter issues:

1. **Run verification:**
   ```bash
   ./verify-setup.sh
   ```

2. **Check logs:**
   ```bash
   gcloud run services logs read glass-api --region us-central1
   ```

3. **Check build logs:**
   ```bash
   gcloud builds list --limit=1
   gcloud builds log <BUILD_ID>
   ```

4. **Common issues:**
   - See Troubleshooting section above
   - Check Google Cloud Console for errors
   - Verify all permissions are granted

---

## ✅ Success Checklist

After deployment, verify:

- [ ] Service is running: `gcloud run services list`
- [ ] Health check works: `curl https://YOUR-URL/health`
- [ ] API docs accessible: Visit `/api/v1/docs`
- [ ] Database connection works: Check logs for connection errors
- [ ] Authentication works: Test signup/signin endpoints

---

## 🎯 Next Steps

After successful deployment:

1. **Update your Flutter app** with the API URL
2. **Test all endpoints** from your mobile app
3. **Monitor logs** for any errors
4. **Set up monitoring** in Cloud Console
5. **Configure custom domain** (optional)

---

**Your API URL will be:** `https://glass-api-xxxxx-uc.a.run.app`

**Happy deploying! 🚀**



