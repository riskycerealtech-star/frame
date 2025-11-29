# 🔍 Troubleshooting Deployment - Step by Step Guide

## Current Issue
The deployed API still shows `"Welcome to Frame APIs"` instead of the test message `"TEST - GitHub Auto-Deploy Working! 🚀"`.

---

## Step 1: Check if Code was Pushed to GitHub

### Verify your local changes are committed:
```bash
cd /Users/apple/frame

# Check git status
git status

# Check if changes are committed
git log --oneline -5
```

### If not pushed yet:
```bash
# Stage changes
git add Backend/main.py Backend/app/main.py

# Commit
git commit -m "Test: Update root endpoint message"

# Push to GitHub
git push origin main
```

---

## Step 2: Check GitHub Actions Workflow

### Option A: Via GitHub Web Interface
1. Go to your GitHub repository
2. Click on **"Actions"** tab
3. Look for the latest workflow run
4. Check if it:
   - ✅ **Completed successfully** (green checkmark)
   - ❌ **Failed** (red X)
   - ⏳ **Still running** (yellow circle)

### Option B: Via Command Line
```bash
# Install GitHub CLI if not installed
# brew install gh  # macOS
# gh auth login

# Check workflow runs
gh run list --limit 5

# View latest workflow run
gh run view --web
```

---

## Step 3: Check Which Service is Deployed

The Cloud Run logs show service name **"frame"**, but your workflow might be deploying to **"glass-api"**.

### Check Cloud Run Services:
```bash
# List all Cloud Run services
gcloud run services list --region us-central1 --project glass-backend-api

# Check the "frame" service details
gcloud run services describe frame --region us-central1 --project glass-backend-api

# Check the "glass-api" service details (if it exists)
gcloud run services describe glass-api --region us-central1 --project glass-backend-api
```

### Check which service the URL points to:
```bash
# The URL https://frame-750669515844.us-central1.run.app points to service "frame"
# Check its current image
gcloud run services describe frame \
  --region us-central1 \
  --project glass-backend-api \
  --format="value(spec.template.spec.containers[0].image)"
```

---

## Step 4: Check GitHub Actions Workflow Configuration

### Verify the workflow file exists:
```bash
cat .github/workflows/deploy-backend.yml
```

### Check if workflow is configured for the right service:
- Service name should match: `glass-api` or `frame`
- Project ID should be: `glass-backend-api`
- Region should be: `us-central1`

---

## Step 5: Check Cloud Run Deployment Logs

### View recent deployments:
```bash
# Check Cloud Run revisions
gcloud run revisions list --service frame --region us-central1 --project glass-backend-api

# Check Cloud Run logs
gcloud run services logs read frame \
  --region us-central1 \
  --project glass-backend-api \
  --limit 50
```

### Check Cloud Build logs (if using Cloud Build):
```bash
# List recent builds
gcloud builds list --limit 5 --project glass-backend-api

# View latest build logs
LATEST_BUILD=$(gcloud builds list --limit 1 --format="value(id)" --project glass-backend-api)
gcloud builds log $LATEST_BUILD --project glass-backend-api
```

---

## Step 6: Verify the Deployed Code

### Check what's actually in the deployed container:
```bash
# Get the service URL and test it
curl https://frame-750669515844.us-central1.run.app/

# Check the OpenAPI spec
curl https://frame-750669515844.us-central1.run.app/docs/frame/openapi.json | grep -i "message\|title"
```

---

## Step 7: Manual Deployment Test

If GitHub Actions isn't working, try manual deployment:

```bash
cd /Users/apple/frame/Backend

# Build and deploy manually
./deploy.sh
```

This will:
1. Build the Docker image
2. Push to Artifact Registry
3. Deploy to Cloud Run

---

## Common Issues & Solutions

### Issue 1: Workflow Not Triggering
**Symptoms:** No workflow runs in GitHub Actions

**Solutions:**
- ✅ Check if you pushed to `main` or `master` branch
- ✅ Verify `.github/workflows/deploy-backend.yml` exists
- ✅ Check workflow file syntax is correct

### Issue 2: Workflow Fails
**Symptoms:** Red X in GitHub Actions

**Solutions:**
- ✅ Check workflow logs for error messages
- ✅ Verify GitHub secrets are set correctly
- ✅ Check service account permissions

### Issue 3: Wrong Service Deployed
**Symptoms:** Changes not reflected, but workflow succeeded

**Solutions:**
- ✅ Verify service name in workflow matches Cloud Run service
- ✅ Check if multiple services exist
- ✅ Verify the URL points to the correct service

### Issue 4: Old Code Still Running
**Symptoms:** New deployment completed but old code still shows

**Solutions:**
- ✅ Wait 2-3 minutes for propagation
- ✅ Clear browser cache
- ✅ Check if multiple revisions exist
- ✅ Verify the latest revision is active

---

## Quick Diagnostic Commands

Run these commands to get a full picture:

```bash
# 1. Check git status
echo "=== Git Status ==="
git status
echo ""

# 2. Check recent commits
echo "=== Recent Commits ==="
git log --oneline -3
echo ""

# 3. Check Cloud Run services
echo "=== Cloud Run Services ==="
gcloud run services list --region us-central1 --project glass-backend-api
echo ""

# 4. Check current deployment
echo "=== Current Deployment ==="
gcloud run services describe frame \
  --region us-central1 \
  --project glass-backend-api \
  --format="table(metadata.name,status.url,spec.template.spec.containers[0].image)"
echo ""

# 5. Test the endpoint
echo "=== Testing Endpoint ==="
curl -s https://frame-750669515844.us-central1.run.app/ | jq .
```

---

## Next Steps

1. **Run the diagnostic commands above**
2. **Check GitHub Actions** - Is the workflow running?
3. **Verify service name** - Is it deploying to the right service?
4. **Check deployment logs** - Any errors?
5. **Try manual deployment** - Does `./deploy.sh` work?

---

## Expected Results

After successful deployment, you should see:
- ✅ GitHub Actions workflow completed successfully
- ✅ Cloud Run service updated with new revision
- ✅ Endpoint returns: `{"message": "TEST - GitHub Auto-Deploy Working! 🚀", ...}`
- ✅ Swagger docs show: "Frame Backend APIs"

