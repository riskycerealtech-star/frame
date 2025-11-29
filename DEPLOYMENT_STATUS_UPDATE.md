# Deployment Status Update

## Current Situation

You have **two deployment methods** set up:

### 1. GitHub Actions Workflow ✅ (Primary)
- Uses Workload Identity Federation
- No service account keys needed
- Check status: https://github.com/riskycerealtech-star/frame/actions

### 2. Cloud Build Trigger ❌ (Failing)
- Trigger name: `auto-deploy-frame`
- Status: Recent builds are failing
- Issue: Missing substitution variables (SECRET_KEY, DATABASE_URL)

## Fix Cloud Build Trigger

The Cloud Build trigger needs substitution variables. You can either:

### Option A: Configure Substitution Variables in Trigger

1. Go to: https://console.cloud.google.com/cloud-build/triggers?project=test-deploy-project-479618
2. Click on "auto-deploy-frame" trigger
3. Click "Edit"
4. Scroll to "Substitution variables"
5. Add:
   - `_SECRET_KEY` = `9c4fcb5c1a4367dcd60a57dc1846d62f22f0ea5c392898c07a21254f915917ce`
   - `_DATABASE_URL` = `sqlite:///./app.db`
6. Save

### Option B: Use GitHub Actions Only (Recommended)

Since GitHub Actions is already set up and working, you can:
- Disable or delete the Cloud Build trigger
- Use only GitHub Actions for deployment

## Check GitHub Actions Status

The GitHub Actions workflow should be running. Check:
- https://github.com/riskycerealtech-star/frame/actions

If it's successful, you'll see the service URL in the workflow output.

## Access Swagger

Once deployment completes (via either method):
- Swagger UI: `https://your-service-url.run.app/docs`
- ReDoc: `https://your-service-url.run.app/redoc`



