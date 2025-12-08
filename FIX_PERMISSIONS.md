# Fix Cloud Run Console Permissions

## Issue
You're seeing: "You don't have permission to list Cloud Run resources" in Google Cloud Console.

## Solution: Grant Cloud Run Viewer Role

Run this command to grant yourself the necessary permissions:

```bash
gcloud projects add-iam-policy-binding test-deploy-project-479618 \
  --member="user:riskycerealtech@gmail.com" \
  --role="roles/run.viewer"
```

Or if you want full access:

```bash
gcloud projects add-iam-policy-binding test-deploy-project-479618 \
  --member="user:riskycerealtech@gmail.com" \
  --role="roles/run.admin"
```

## Alternative: Check Deployment via Command Line

Even without console access, you can check deployment status:

```bash
# List services
gcloud run services list --project=test-deploy-project-479618 --region=us-central1

# Get service URL
gcloud run services describe frame-api \
  --project=test-deploy-project-479618 \
  --region=us-central1 \
  --format="value(status.url)"
```

## Check GitHub Actions

The easiest way to get your service URL is from GitHub Actions:

1. Go to: https://github.com/riskycerealtech-star/frame/actions
2. Click on the latest workflow run
3. Look for the output: "🌐 Service URL: https://..."
4. Add `/docs` to access Swagger

## Quick Fix Command

Run this to grant yourself viewer access:

```bash
gcloud projects add-iam-policy-binding test-deploy-project-479618 \
  --member="user:riskycerealtech@gmail.com" \
  --role="roles/run.viewer"
```

Then refresh the Cloud Run console page.
















