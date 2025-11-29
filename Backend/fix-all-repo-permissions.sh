#!/bin/bash
# Fix permissions for both Artifact Registry and Container Registry

set -e

echo "🔧 Fixing all repository permissions for Cloud Build..."

# Get project number
PROJECT_NUMBER=$(gcloud projects describe glass-backend-api --format="value(projectNumber)")

if [ -z "$PROJECT_NUMBER" ]; then
    echo "❌ Failed to get project number."
    exit 1
fi

CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

echo "📋 Project Number: $PROJECT_NUMBER"
echo "📧 Cloud Build Service Account: $CLOUD_BUILD_SA"
echo ""

# Enable Container Registry API (for legacy gcr.io support)
echo "📡 Enabling Container Registry API..."
gcloud services enable containerregistry.googleapis.com --project=glass-backend-api || echo "Already enabled"

# Grant Storage Admin for Container Registry (gcr.io uses Cloud Storage)
echo "🔑 Granting Storage Admin for Container Registry access..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/storage.admin" || echo "Already has permission"

# Grant Artifact Registry Writer at project level
echo "🔑 Granting Artifact Registry Writer at project level..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer" || echo "Already has permission"

# Grant Artifact Registry Writer at repository level for cloud-run-source-deploy
echo "🔑 Granting Artifact Registry Writer at repository level..."
gcloud artifacts repositories add-iam-policy-binding cloud-run-source-deploy \
    --location=us-central1 \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer" || echo "Already has permission"

echo ""
echo "⏳ Waiting 30 seconds for permissions to propagate..."
sleep 30

echo ""
echo "✅ All permissions granted!"
echo ""
echo "🚀 Now try deploying again:"
echo "   gcloud run deploy glass-backend-api --source . --region us-central1 --platform managed --allow-unauthenticated"




