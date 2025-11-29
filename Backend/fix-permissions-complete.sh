#!/bin/bash
# Complete script to fix all Artifact Registry and Cloud Build permissions

set -e  # Exit on error

echo "🔧 Fixing Cloud Run deployment permissions..."

# Enable required APIs
echo "📡 Enabling required Google Cloud APIs..."
gcloud services enable artifactregistry.googleapis.com --project=glass-backend-api
gcloud services enable cloudbuild.googleapis.com --project=glass-backend-api
gcloud services enable run.googleapis.com --project=glass-backend-api

# Get project number
echo "📋 Getting project information..."
PROJECT_NUMBER=$(gcloud projects describe glass-backend-api --format="value(projectNumber)")

if [ -z "$PROJECT_NUMBER" ]; then
    echo "❌ Failed to get project number. Are you authenticated?"
    exit 1
fi

CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
echo "✅ Project Number: $PROJECT_NUMBER"
echo "✅ Cloud Build Service Account: $CLOUD_BUILD_SA"

# Check and create Artifact Registry repository
echo ""
echo "🔍 Checking Artifact Registry repository..."
if ! gcloud artifacts repositories describe cloud-run-source-deploy \
    --location=us-central1 \
    --format="value(name)" &>/dev/null; then
    echo "📦 Creating Artifact Registry repository..."
    gcloud artifacts repositories create cloud-run-source-deploy \
        --repository-format=docker \
        --location=us-central1 \
        --description="Docker repository for Cloud Run source deployments" || {
        echo "⚠️  Repository creation failed or already exists, continuing..."
    }
else
    echo "✅ Repository already exists."
fi

# Grant all necessary permissions
echo ""
echo "🔑 Granting IAM permissions..."

# Artifact Registry Writer
echo "  - Granting Artifact Registry Writer role..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer" \
    --condition=None || echo "  ⚠️  Permission may already exist"

# Cloud Run Admin (for deployments)
echo "  - Granting Cloud Run Admin role..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/run.admin" \
    --condition=None || echo "  ⚠️  Permission may already exist"

# Service Account User (to deploy services)
echo "  - Granting Service Account User role..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/iam.serviceAccountUser" \
    --condition=None || echo "  ⚠️  Permission may already exist"

# Storage Admin (for accessing build sources)
echo "  - Granting Storage Admin role..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/storage.admin" \
    --condition=None || echo "  ⚠️  Permission may already exist"

echo ""
echo "✅ Permission setup complete!"
echo ""
echo "🚀 You can now deploy your service:"
echo "   gcloud run deploy glass-backend-api --source . --region us-central1 --platform managed --allow-unauthenticated"
echo ""
echo "💡 If you still get errors, wait 1-2 minutes for IAM permissions to propagate."




