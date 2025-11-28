# Google Cloud Run Deployment Guide

This guide will help you deploy the Frame API to Google Cloud Run.

## Prerequisites

1. **Google Cloud Account**: Sign up at [cloud.google.com](https://cloud.google.com)
2. **Google Cloud CLI**: Install from [cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
3. **Docker**: Optional, but helpful for local testing

## Initial Setup

### 1. Install Google Cloud CLI

```bash
# macOS
brew install google-cloud-sdk

# Or download from: https://cloud.google.com/sdk/docs/install
```

### 2. Authenticate and Set Up Project

```bash
# Login to Google Cloud
gcloud auth login

# Create a new project (or use existing)
gcloud projects create your-project-id --name="Frame API"

# Set the project
gcloud config set project your-project-id

# Set default region
gcloud config set run/region us-central1
```

### 3. Enable Required APIs

```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

## Deployment Methods

### Method 1: Using the Deployment Script (Recommended)

1. **Make the script executable**:
   ```bash
   chmod +x deploy.sh
   ```

2. **Set environment variables**:
   ```bash
   export GOOGLE_CLOUD_PROJECT="your-project-id"
   export SECRET_KEY="your-secret-key-here"  # Generate with: openssl rand -hex 32
   ```

3. **Run the deployment script**:
   ```bash
   ./deploy.sh
   ```

### Method 2: Manual Deployment

1. **Build and push the Docker image**:
   ```bash
   # Set your project ID
   export PROJECT_ID="your-project-id"
   
   # Build and push
   gcloud builds submit --tag gcr.io/${PROJECT_ID}/frame-api
   ```

2. **Deploy to Cloud Run**:
   ```bash
   gcloud run deploy frame-api \
     --image gcr.io/${PROJECT_ID}/frame-api \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --memory 512Mi \
     --set-env-vars "SECRET_KEY=your-secret-key-here"
   ```

### Method 3: Using Cloud Build (CI/CD)

1. **Set up Cloud Build triggers** (for automatic deployments on git push):
   ```bash
   gcloud builds triggers create github \
     --repo-name=frame \
     --repo-owner=your-github-username \
     --branch-pattern="^main$" \
     --build-config=cloudbuild.yaml
   ```

2. **Set substitution variables**:
   ```bash
   gcloud builds triggers update YOUR_TRIGGER_ID \
     --substitutions _SECRET_KEY=your-secret-key,_DATABASE_URL=your-db-url
   ```

## Environment Variables

Set these environment variables in Cloud Run:

- `SECRET_KEY`: Secret key for JWT token signing (required)
- `DATABASE_URL`: Database connection string (optional, defaults to SQLite)
- `ALGORITHM`: JWT algorithm (optional, defaults to HS256)
- `ACCESS_TOKEN_EXPIRE_MINUTES`: Token expiration (optional, defaults to 30)

### Setting Environment Variables

```bash
gcloud run services update frame-api \
  --update-env-vars SECRET_KEY=your-secret-key,DATABASE_URL=your-db-url \
  --region us-central1
```

## Database Options

### Option 1: SQLite (Default - Not Recommended for Production)

SQLite will work but data won't persist between container restarts. Use only for testing.

### Option 2: Cloud SQL (Recommended for Production)

1. **Create a Cloud SQL instance**:
   ```bash
   gcloud sql instances create frame-db \
     --database-version=POSTGRES_15 \
     --tier=db-f1-micro \
     --region=us-central1
   ```

2. **Create a database**:
   ```bash
   gcloud sql databases create frame_db --instance=frame-db
   ```

3. **Create a user**:
   ```bash
   gcloud sql users create frame_user \
     --instance=frame-db \
     --password=your-secure-password
   ```

4. **Connect Cloud Run to Cloud SQL**:
   ```bash
   gcloud run services update frame-api \
     --add-cloudsql-instances=PROJECT_ID:REGION:frame-db \
     --update-env-vars DATABASE_URL="postgresql://frame_user:password@/frame_db?host=/cloudsql/PROJECT_ID:REGION:frame-db" \
     --region us-central1
   ```

5. **Update your database models** to use PostgreSQL:
   - Install: `pip install psycopg2-binary`
   - Update `requirements.txt` to include `psycopg2-binary>=2.9.0`

## Testing the Deployment

After deployment, you'll get a URL like: `https://frame-api-xxxxx-uc.a.run.app`

1. **Test the root endpoint**:
   ```bash
   curl https://your-service-url.run.app/
   ```

2. **View API documentation**:
   Open `https://your-service-url.run.app/docs` in your browser

3. **Test registration**:
   ```bash
   curl -X POST https://your-service-url.run.app/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","username":"testuser","password":"testpass123"}'
   ```

4. **Test login**:
   ```bash
   curl -X POST https://your-service-url.run.app/login \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "username=testuser&password=testpass123"
   ```

## Monitoring and Logs

### View logs:
```bash
gcloud run services logs read frame-api --region us-central1
```

### View service details:
```bash
gcloud run services describe frame-api --region us-central1
```

## Updating the Deployment

To update your service:

1. **Make your code changes**
2. **Rebuild and redeploy**:
   ```bash
   ./deploy.sh
   ```

Or manually:
```bash
gcloud builds submit --tag gcr.io/${PROJECT_ID}/frame-api
gcloud run deploy frame-api --image gcr.io/${PROJECT_ID}/frame-api --region us-central1
```

## Troubleshooting

### Common Issues:

1. **"Permission denied" errors**:
   - Make sure you're authenticated: `gcloud auth login`
   - Check project permissions: `gcloud projects get-iam-policy your-project-id`

2. **Container fails to start**:
   - Check logs: `gcloud run services logs read frame-api --region us-central1`
   - Verify environment variables are set correctly

3. **Database connection issues**:
   - For Cloud SQL, ensure the Cloud SQL connection is added to the service
   - Check database credentials and connection string format

4. **Port binding errors**:
   - Cloud Run automatically sets the PORT environment variable
   - The Dockerfile uses `$PORT` which Cloud Run provides

## Cost Estimation

Cloud Run pricing:
- **Free tier**: 2 million requests/month, 360,000 GB-seconds, 180,000 vCPU-seconds
- **After free tier**: Pay per use (requests, memory, CPU time)

For a small API, you'll likely stay within the free tier.

## Security Best Practices

1. **Use Secret Manager** for sensitive data:
   ```bash
   # Store secret
   echo -n "your-secret-key" | gcloud secrets create secret-key --data-file=-
   
   # Grant access to Cloud Run
   gcloud secrets add-iam-policy-binding secret-key \
     --member="serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
     --role="roles/secretmanager.secretAccessor"
   
   # Use in Cloud Run
   gcloud run services update frame-api \
     --update-secrets SECRET_KEY=secret-key:latest
   ```

2. **Enable authentication** (remove `--allow-unauthenticated`):
   ```bash
   gcloud run services update frame-api \
     --no-allow-unauthenticated
   ```

3. **Use HTTPS only** (enabled by default on Cloud Run)

## Next Steps

- Set up custom domain: [Cloud Run Custom Domains](https://cloud.google.com/run/docs/mapping-custom-domains)
- Set up CI/CD with Cloud Build
- Configure monitoring and alerts
- Set up Cloud SQL for production database

