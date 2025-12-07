# How to Check Workflow Errors

## Steps to See What's Failing

1. **Go to GitHub Actions:**
   - https://github.com/riskycerealtech-star/frame/actions

2. **Click on a failed workflow run** (red X)

3. **Click on the failed job** (usually "deploy")

4. **Expand each step** to see the error:
   - Look for steps that show ❌ or have error messages
   - Common failing steps:
     - "Authenticate to Google Cloud" - Workload Identity issue
     - "Build and Push Docker image" - Docker/build issue
     - "Deploy to Cloud Run" - Deployment issue

5. **Copy the error message** - This will tell us exactly what's wrong

## Common Errors and Fixes

### Error: "Permission denied" or "Access denied"
- **Fix:** Workload Identity not configured correctly
- **Solution:** Check IAM bindings and provider configuration

### Error: "Service account not found"
- **Fix:** Service account doesn't exist or wrong name
- **Solution:** Verify service account exists

### Error: "Docker build failed"
- **Fix:** Issue with Dockerfile or dependencies
- **Solution:** Check Dockerfile and requirements.txt

### Error: "Image push failed"
- **Fix:** No permission to push to Container Registry
- **Solution:** Grant Storage Admin role to service account

## What I Just Fixed

I updated the workflow to add `token_format: access_token` which might help with authentication.

## Next Steps

1. Check the workflow logs to see the exact error
2. Share the error message so I can help fix it
3. Or try pushing again - the updated workflow might work now














