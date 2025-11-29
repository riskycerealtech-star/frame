#!/bin/bash
# Grant repository-level permissions for Artifact Registry

echo "🔧 Granting repository-level Artifact Registry permissions..."

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

# Grant repository-level permissions
echo "🔑 Granting repository-level Artifact Registry Writer permission..."
gcloud artifacts repositories add-iam-policy-binding cloud-run-source-deploy \
    --location=us-central1 \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Repository-level permission granted successfully!"
    echo ""
    echo "⏳ Waiting 30 seconds for permissions to fully propagate..."
    sleep 30
    echo ""
    echo "🚀 You can now deploy your service:"
    echo "   gcloud run deploy glass-backend-api --source . --region us-central1 --platform managed --allow-unauthenticated"
else
    echo "❌ Failed to grant permission."
    exit 1
fi




