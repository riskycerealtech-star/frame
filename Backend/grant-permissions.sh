#!/bin/bash
# Grant Artifact Registry permissions to Cloud Build service account

echo "🔧 Granting Artifact Registry permissions..."

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

# Grant Artifact Registry Writer role
echo "🔑 Granting Artifact Registry Writer permission..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Permission granted successfully!"
    echo ""
    echo "⏳ Waiting 10 seconds for permissions to propagate..."
    sleep 10
    echo ""
    echo "🚀 You can now deploy your service:"
    echo "   gcloud run deploy glass-backend-api --source . --region us-central1 --platform managed --allow-unauthenticated"
else
    echo "❌ Failed to grant permission."
    exit 1
fi




