# 🔧 Fix GitHub Actions Workflow Failures

## Current Issue
All workflows are failing (red X) within 26-57 seconds, indicating early failure (likely authentication or setup).

## Workflows That Are Failing

1. **"Deploy Backend to Google Cloud Run"** - Fails in ~26s
2. **"Deploy to Cloud Run via Cloud Build"** - Fails in ~31-33s  
3. **"Deploy to Google Cloud Run"** - Fails in ~57s

## How to Check the Actual Error

### Option 1: Via GitHub Web Interface
1. Go to: https://github.com/riskycerealtech-star/frame/actions
2. Click on the failed workflow (red X)
3. Click on the failed job (usually "deploy")
4. Expand each step to see the error message
5. Look for steps showing ❌ or error messages

### Option 2: Via GitHub CLI
```bash
# Install GitHub CLI if needed
# brew install gh
# gh auth login

# List recent workflow runs
gh run list --limit 5

# View latest failed run
gh run view --log --failed
```

## Common Failure Causes

### 1. Missing GitHub Secrets
The workflows need these secrets in GitHub:
- `GCP_SA_KEY` - Service account JSON key
- `POSTGRES_USER` - Database username
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_DB` - Database name
- `SECRET_KEY` - JWT secret key

**Check:** GitHub Repo → Settings → Secrets and variables → Actions

### 2. Authentication Issues
- Service account key might be invalid
- Service account might not have required permissions
- Workload Identity might not be configured correctly

### 3. Wrong Project/Service Configuration
- Project ID mismatch
- Service name doesn't exist
- Region mismatch

## Quick Fix Steps

### Step 1: Check Which Workflow Should Run

You have 3 workflows. You probably only need **one**. Let's use:
- **"Deploy Backend to Google Cloud Run"** (deploy-backend.yml) - This is the one we updated

### Step 2: Disable Other Workflows (Optional)

To avoid confusion, you can disable the other workflows by renaming them:
```bash
cd /Users/apple/frame
mv .github/workflows/deploy.yml .github/workflows/deploy.yml.disabled
mv .github/workflows/deploy-cloudbuild.yml .github/workflows/deploy-cloudbuild.yml.disabled
```

### Step 3: Check Required Secrets

Make sure these secrets exist in GitHub:
1. Go to: https://github.com/riskycerealtech-star/frame/settings/secrets/actions
2. Verify these secrets exist:
   - `GCP_SA_KEY`
   - `POSTGRES_USER`
   - `POSTGRES_PASSWORD`
   - `POSTGRES_DB`
   - `SECRET_KEY`

### Step 4: Get the Actual Error

The fastest way to see what's wrong:
1. Go to: https://github.com/riskycerealtech-star/frame/actions
2. Click on the most recent failed run
3. Click on the "deploy" job
4. Look for the red ❌ step
5. Click on it to see the error message

## Most Likely Issues

Based on the quick failure times:

### Issue 1: Missing GCP_SA_KEY Secret
**Error:** "credentials_json: ${{ secrets.GCP_SA_KEY }}" not found

**Fix:**
1. Create a service account key in Google Cloud
2. Add it as `GCP_SA_KEY` secret in GitHub

### Issue 2: Authentication Failure
**Error:** "Permission denied" or "Access denied"

**Fix:**
- Verify service account has required permissions:
  - Cloud Run Admin
  - Artifact Registry Writer
  - Service Account User

### Issue 3: Docker Build Failure
**Error:** "Docker build failed" or "Cannot find Dockerfile"

**Fix:**
- Verify Dockerfile exists in Backend/ directory
- Check Dockerfile syntax

## Next Steps

1. **Check the actual error** in GitHub Actions logs
2. **Share the error message** so I can help fix it
3. **Or try these fixes** based on common issues above

## Manual Deployment (Temporary Workaround)

While fixing the workflow, you can deploy manually:

```bash
cd /Users/apple/frame/Backend
./deploy.sh
```

This will deploy directly without GitHub Actions.



