#!/bin/bash
# Script to fix Artifact Registry permissions for Cloud Build

echo "🔧 Fixing Artifact Registry permissions..."

# Get project number
PROJECT_NUMBER=$(gcloud projects describe glass-backend-api --format="value(projectNumber)")

if [ -z "$PROJECT_NUMBER" ]; then
    echo "❌ Failed to get project number. Make sure you're authenticated."
    exit 1
fi

echo "📋 Project Number: $PROJECT_NUMBER"
echo "📧 Cloud Build Service Account: ${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Grant Artifact Registry Writer permission
echo "🔑 Granting Artifact Registry Writer permission..."
gcloud projects add-iam-policy-binding glass-backend-api \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/artifactregistry.writer" \
    --condition=None

if [ $? -eq 0 ]; then
    echo "✅ Successfully granted Artifact Registry Writer permission!"
    echo ""
    echo "🚀 You can now try deploying again:"
    echo "   gcloud run deploy glass-backend-api --source . --region us-central1 --platform managed --allow-unauthenticated"
else
    echo "❌ Failed to grant permission. You may need to run this with appropriate permissions."
    exit 1
fi
