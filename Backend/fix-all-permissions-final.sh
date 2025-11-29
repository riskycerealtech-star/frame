#!/bin/bash
# Comprehensive permission fix for Artifact Registry

set -e

echo "🔧 Fixing all Artifact Registry permissions..."

# Get project number
PROJECT_NUMBER=$(gcloud projects describe glass-backend-api --format="value(projectNumber)")

if [ -z "$PROJECT_NUMBER" ]; then
    echo "❌ Failed to get project number."
    exit 1
fi

CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
CLOUD_BUILD_AGENT="service-${PROJECT_NUMBER}@gcp-sa-cloudbuild.iam.gserviceaccount.com"

echo "📋 Project Number: $PROJECT_NUMBER"
echo "📧 Cloud Build Service Account: $CLOUD_BUILD_SA"
echo "📧 Cloud Build Service Agent: $CLOUD_BUILD_AGENT"
echo ""

# Method 1: Project-level permissions
echo "🔑 Method 1: Granting project-level permissions..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer" || echo "⚠️  May already exist"

gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_AGENT}" \
    --role="roles/artifactregistry.writer" || echo "⚠️  May already exist"

# Method 2: Repository-level permissions
echo ""
echo "🔑 Method 2: Granting repository-level permissions..."
gcloud artifacts repositories add-iam-policy-binding cloud-run-source-deploy \
    --location=us-central1 \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer" || echo "⚠️  May already exist"

gcloud artifacts repositories add-iam-policy-binding cloud-run-source-deploy \
    --location=us-central1 \
    --member="serviceAccount:${CLOUD_BUILD_AGENT}" \
    --role="roles/artifactregistry.writer" || echo "⚠️  May already exist"

# Verify permissions
echo ""
echo "🔍 Verifying permissions..."
echo "Project-level permissions for Cloud Build SA:"
gcloud projects get-iam-policy glass-backend-api \
    --flatten="bindings[].members" \
    --filter="bindings.members:${CLOUD_BUILD_SA} AND bindings.role:roles/artifactregistry.writer" \
    --format="table(bindings.role)" || echo "Not found at project level"

echo ""
echo "Repository-level permissions:"
gcloud artifacts repositories get-iam-policy cloud-run-source-deploy \
    --location=us-central1 \
    --format="table(bindings.role,bindings.members)" || echo "Could not retrieve"

echo ""
echo "⏳ Waiting 45 seconds for all permissions to propagate..."
sleep 45

echo ""
echo "✅ Permission setup complete!"
echo ""
echo "🚀 Try deploying again:"
echo "   gcloud run deploy glass-backend-api --source . --region us-central1 --platform managed --allow-unauthenticated"




