# GitHub Automatic Deployment Setup

This guide will help you set up automatic deployment to Google Cloud Run whenever you push to GitHub. **No Docker installation required on your laptop!**

## Prerequisites

1. **Google Cloud Account** with a project created
2. **GitHub Account** with your repository
3. **Google Cloud CLI** installed (only for initial setup, not needed after)

## Step 1: Initial Google Cloud Setup

### 1.1 Install Google Cloud CLI (One-time setup)

```bash
# macOS
brew install google-cloud-sdk

# Or download from: https://cloud.google.com/sdk/docs/install
```

### 1.2 Authenticate and Create Project

```bash
# Login
gcloud auth login

# Create project (or use existing)
gcloud projects create your-project-id --name="Frame API"

# Set the project
gcloud config set project your-project-id
```

### 1.3 Enable Required APIs

```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable iam.googleapis.com
```

## Step 2: Create Service Account for GitHub Actions

### 2.1 Create Service Account

```bash
# Set variables
export PROJECT_ID="your-project-id"
export SA_NAME="github-actions-sa"
export SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create service account
gcloud iam service-accounts create ${SA_NAME} \
  --display-name="GitHub Actions Service Account" \
  --project=${PROJECT_ID}
```

### 2.2 Grant Required Permissions

```bash
# Grant Cloud Run Admin
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/run.admin"

# Grant Service Account User (to deploy to Cloud Run)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

# Grant Storage Admin (to push images)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.admin"

# Grant Cloud Build Service Account permissions
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/run.admin"
```

### 2.3 Create and Download Service Account Key

```bash
# Create key
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=${SA_EMAIL}

# Display the key (you'll need to copy this)
cat github-actions-key.json

# Delete the local file after copying (for security)
rm github-actions-key.json
```

## Step 3: Set Up GitHub Secrets

### 3.1 Go to Your GitHub Repository

1. Navigate to your repository on GitHub
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### 3.2 Add the Following Secrets

Add these secrets one by one:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `GCP_PROJECT_ID` | `your-project-id` | Your Google Cloud project ID |
| `GCP_SA_KEY` | `{paste the entire JSON from github-actions-key.json}` | Service account key JSON |
| `SECRET_KEY` | `$(openssl rand -hex 32)` | JWT secret key (generate with: `openssl rand -hex 32`) |
| `DATABASE_URL` | `sqlite:///./app.db` | Database URL (optional, defaults to SQLite) |

**To generate SECRET_KEY:**
```bash
openssl rand -hex 32
```

**Important:** For `GCP_SA_KEY`, paste the **entire JSON content** from the service account key file, including the curly braces `{}`.

## Step 4: Choose Deployment Method

You have two workflow files. Choose one:

### Option A: Direct GitHub Actions Deployment (Recommended)

Uses: `.github/workflows/deploy.yml`

- Builds Docker image in GitHub Actions
- Pushes to Google Container Registry
- Deploys to Cloud Run
- **No additional setup needed**

### Option B: Cloud Build Deployment

Uses: `.github/workflows/deploy-cloudbuild.yml`

- Submits build to Google Cloud Build
- Uses `cloudbuild.yaml` configuration
- Requires Cloud Build API enabled (already done in Step 1.3)

**For most users, Option A is recommended.**

## Step 5: Push to GitHub

### 5.1 Initialize Git (if not already done)

```bash
cd /Users/apple/frame
git init
git add .
git commit -m "Initial commit with GitHub Actions deployment"
```

### 5.2 Add GitHub Remote

```bash
# Create a new repository on GitHub first, then:
git remote add origin https://github.com/your-username/your-repo-name.git
git branch -M main
git push -u origin main
```

### 5.3 Watch the Deployment

1. Go to your GitHub repository
2. Click on the **Actions** tab
3. You should see the workflow running
4. Click on it to see the deployment progress

## Step 6: Verify Deployment

After the workflow completes:

1. Go to the workflow run details
2. Look for the "Output Service URL" step
3. Click on the service URL to test your API
4. Visit `{service-url}/docs` for API documentation

## How It Works

1. **You push code to GitHub** (main/master branch)
2. **GitHub Actions triggers** automatically
3. **Workflow runs on GitHub's servers** (no Docker needed on your laptop!)
4. **Builds Docker image** in the cloud
5. **Deploys to Cloud Run** automatically
6. **Your API is live!**

## Manual Deployment Trigger

You can also trigger deployment manually:

1. Go to **Actions** tab in GitHub
2. Select **Deploy to Google Cloud Run** workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## Updating Environment Variables

To update environment variables (like SECRET_KEY or DATABASE_URL):

1. Go to GitHub repository → **Settings** → **Secrets and variables** → **Actions**
2. Update the secret value
3. Push a new commit or manually trigger the workflow

## Troubleshooting

### Workflow Fails with "Permission Denied"

- Check that service account has correct permissions
- Verify `GCP_SA_KEY` secret is correctly formatted (full JSON)
- Ensure APIs are enabled

### Build Fails

- Check the Actions logs for specific errors
- Verify `Dockerfile` is correct
- Ensure all files are committed to git

### Deployment Fails

- Check Cloud Run service exists: `gcloud run services list`
- Verify service account has Cloud Run Admin role
- Check Cloud Run logs: `gcloud run services logs read frame-api --region us-central1`

### Service Not Accessible

- Check if service allows unauthenticated access
- Verify the service URL in Cloud Run console
- Check Cloud Run logs for errors

## Viewing Logs

### GitHub Actions Logs
- Go to **Actions** tab → Click on workflow run → View logs

### Cloud Run Logs
```bash
gcloud run services logs read frame-api --region us-central1 --project your-project-id
```

Or in Google Cloud Console:
- Go to Cloud Run → Select service → Logs tab

## Cost

- **GitHub Actions**: Free for public repos, 2000 minutes/month for private repos
- **Google Cloud Run**: Free tier includes 2 million requests/month
- **Container Registry**: Free for first 0.5 GB storage

For small projects, this setup is essentially **free**!

## Next Steps

- Set up a custom domain
- Configure Cloud SQL for production database
- Set up monitoring and alerts
- Add staging environment (deploy on push to `develop` branch)

## Security Notes

1. **Never commit** `github-actions-key.json` to git
2. **Rotate secrets** periodically
3. **Use Secret Manager** for production (see DEPLOYMENT.md)
4. **Review service account permissions** regularly

---

**That's it!** Now every time you push to GitHub, your API will automatically deploy to Google Cloud Run. No Docker needed on your laptop! 🚀

