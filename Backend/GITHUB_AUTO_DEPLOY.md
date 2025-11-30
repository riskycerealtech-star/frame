# 🚀 GitHub Auto-Deployment Guide

## Current Status

✅ **You have GitHub Actions workflows configured!**

However, they need to be updated to match your actual deployment setup.

---

## How It Currently Works

### When you push to GitHub:

1. **Push to `main` or `master` branch** → Triggers workflow automatically
2. **GitHub Actions runs** → Builds and deploys your code
3. **Deployment completes** → Your API is live!

### Workflow Files:

- `.github/workflows/deploy.yml` - Direct Docker deployment
- `.github/workflows/deploy-cloudbuild.yml` - Cloud Build deployment

---

## ⚠️ Issues to Fix

Your current workflows have these issues:

1. **Wrong directory** - They deploy from root, but your Backend is in `Backend/` folder
2. **Wrong service name** - Uses `frame-api`, but your service is `glass-api`
3. **Wrong project** - Uses `test-deploy-project-479618`, but should be `glass-backend-api`
4. **Missing environment variables** - Doesn't include all your Cloud SQL and other env vars

---

## ✅ Fixed Workflow

I'll create an updated workflow that:
- ✅ Deploys from `Backend/` directory
- ✅ Uses correct service name: `glass-api`
- ✅ Uses correct project: `glass-backend-api`
- ✅ Includes all environment variables
- ✅ Uses your Artifact Registry setup

---

## Required GitHub Secrets

Make sure these secrets are set in your GitHub repository:

1. Go to: **GitHub Repo → Settings → Secrets and variables → Actions**

2. Add/Update these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `GCP_PROJECT_ID` | `glass-backend-api` | Your GCP project ID |
| `SECRET_KEY` | (your secret key) | JWT secret key |
| `POSTGRES_SERVER` | `/cloudsql/glass-backend-api:us-central1:glass-db` | Cloud SQL connection |
| `POSTGRES_USER` | `glass_user` | Database username |
| `POSTGRES_PASSWORD` | `GlassUser2024Secure` | Database password |
| `POSTGRES_DB` | `glass_db` | Database name |

---

## How to Set Up Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the name and value above
5. Click **Add secret**

---

## After Fixing the Workflow

Once the workflow is updated:

1. **Push to GitHub:**
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "Update GitHub Actions workflow for Backend deployment"
   git push
   ```

2. **Watch it deploy:**
   - Go to: `https://github.com/your-username/your-repo/actions`
   - You'll see the workflow running
   - It will deploy automatically!

3. **Check deployment:**
   - After completion, your API will be live at:
   - `https://glass-api-750669515844.us-central1.run.app`

---

## Manual Trigger

You can also trigger deployment manually:

1. Go to **Actions** tab in GitHub
2. Select **Deploy to Google Cloud Run** workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

---

## Deployment Time

- **Build time:** ~10-15 minutes
- **Deploy time:** ~2-5 minutes
- **Total:** ~15-20 minutes per deployment

---

## What Gets Deployed

The workflow will:
1. ✅ Build Docker image from `Backend/Dockerfile`
2. ✅ Push to Artifact Registry: `us-central1-docker.pkg.dev/glass-backend-api/docker-repo/glass-api`
3. ✅ Deploy to Cloud Run service: `glass-api`
4. ✅ Set all environment variables
5. ✅ Connect to Cloud SQL database

---

## Troubleshooting

### Workflow doesn't trigger
- ✅ Make sure you're pushing to `main` or `master` branch
- ✅ Check that `.github/workflows/deploy.yml` exists

### Deployment fails
- ✅ Check GitHub Actions logs
- ✅ Verify all secrets are set correctly
- ✅ Make sure service account has permissions

### Wrong service deployed
- ✅ Check the workflow file uses correct service name
- ✅ Verify project ID is correct

---

## Next Steps

1. I'll update the workflow file to match your setup
2. You push it to GitHub
3. Every push to `main` will auto-deploy! 🎉



