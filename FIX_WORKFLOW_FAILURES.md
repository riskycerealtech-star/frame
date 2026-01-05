# Fix GitHub Actions Workflow Failures

## Issue
All workflows are failing. The main issue is likely with Workload Identity Federation authentication.

## Common Issues and Fixes

### Issue 1: Workload Identity Provider Configuration

The provider might not be configured correctly. Check:

```bash
gcloud iam workload-identity-pools providers describe github-provider \
  --project="test-deploy-project-479618" \
  --location="global" \
  --workload-identity-pool="github-pool"
```

### Issue 2: Repository Attribute Mismatch

The IAM binding might not match the repository. Verify:

```bash
gcloud iam service-accounts get-iam-policy \
  github-actions-sa@test-deploy-project-479618.iam.gserviceaccount.com \
  --project=test-deploy-project-479618
```

The binding should include: `attribute.repository/riskycerealtech-star/frame`

### Issue 3: Workflow Needs Update

The workflow might need the correct repository format. GitHub sends the repository as `riskycerealtech-star/frame`.

## Quick Fix: Use Service Account Key Instead

If Workload Identity continues to fail, we can temporarily use a service account key (if your admin allows it) or use Cloud Build which has built-in permissions.

## Check Workflow Logs

To see the exact error:
1. Go to: https://github.com/riskycerealtech-star/frame/actions
2. Click on a failed workflow
3. Click on the failed job
4. Expand the error step to see the exact error message

This will tell us exactly what's failing.















































