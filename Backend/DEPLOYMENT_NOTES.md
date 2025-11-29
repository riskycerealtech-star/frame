# Cloud Run Deployment Notes

## Current Issues
Build is failing. Check the build logs URL provided in the terminal output.

## Two Deployment Options

### Option 1: Using Buildpacks (Current)
```bash
gcloud run deploy glass-backend-api \
    --source . \
    --region us-central1 \
    --platform managed \
    --allow-unauthenticated
```

### Option 2: Using Dockerfile (Recommended - More Control)
```bash
gcloud run deploy glass-backend-api \
    --source . \
    --region us-central1 \
    --platform managed \
    --allow-unauthenticated \
    --dockerfile Dockerfile
```

Or build and push the image first:
```bash
# Build the container image
gcloud builds submit --tag gcr.io/glass-backend-api/glass-backend-api

# Deploy to Cloud Run
gcloud run deploy glass-backend-api \
    --image gcr.io/glass-backend-api/glass-backend-api \
    --region us-central1 \
    --platform managed \
    --allow-unauthenticated
```

## Common Issues Fixed
- ✅ Added missing pydantic-settings
- ✅ Added email-validator
- ✅ Made ML packages optional
- ✅ Fixed PORT environment variable
- ✅ Created Dockerfile as alternative

## Next Steps
1. Check build logs at the URL provided
2. Try Dockerfile deployment if Buildpacks fails
3. Verify all dependencies are in requirements.txt

