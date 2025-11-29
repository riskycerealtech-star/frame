#!/bin/bash

# Grant permissions to glass-api-new repository

PROJECT_ID="glass-backend-api"
PROJECT_NUMBER="750669515844"
REPO_NAME="glass-api-new"
REGION="us-central1"

echo "🔧 Granting permissions to ${REPO_NAME} repository..."

# Grant Cloud Build service account permission to push to this repository
gcloud artifacts repositories add-iam-policy-binding ${REPO_NAME} \
    --location=${REGION} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/artifactregistry.writer" \
    --project=${PROJECT_ID}

echo ""
echo "✅ Permissions granted!"
echo ""
echo "Now you can deploy with: ./deploy.sh"





