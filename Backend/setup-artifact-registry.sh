#!/bin/bash
# Comprehensive script to setup Artifact Registry and fix permissions

echo "🔧 Setting up Artifact Registry for Cloud Run deployments..."

# Check if repository exists
echo "🔍 Checking if Artifact Registry repository exists..."
REPO_EXISTS=$(gcloud artifacts repositories describe cloud-run-source-deploy \
    --location=us-central1 \
    --format="value(name)" 2>/dev/null)

if [ -z "$REPO_EXISTS" ]; then
    echo "📦 Repository doesn't exist. Creating it..."
    gcloud artifacts repositories create cloud-run-source-deploy \
        --repository-format=docker \
        --location=us-central1 \
        --description="Docker repository for Cloud Run source deployments"
    
    if [ $? -eq 0 ]; then
        echo "✅ Repository created successfully!"
    else
        echo "❌ Failed to create repository. Check your permissions."
        exit 1
    fi
else
    echo "✅ Repository already exists."
fi

# Get project number
PROJECT_NUMBER=$(gcloud projects describe glass-backend-api --format="value(projectNumber)")

if [ -z "$PROJECT_NUMBER" ]; then
    echo "❌ Failed to get project number."
    exit 1
fi

echo "📋 Project Number: $PROJECT_NUMBER"
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
echo "📧 Cloud Build Service Account: $CLOUD_BUILD_SA"

# Check if permission already exists
echo "🔍 Checking existing permissions..."
HAS_PERMISSION=$(gcloud projects get-iam-policy glass-backend-api \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" \
    --filter="bindings.members:${CLOUD_BUILD_SA} AND bindings.role:roles/artifactregistry.writer" 2>/dev/null)

if [ -z "$HAS_PERMISSION" ]; then
    echo "🔑 Granting Artifact Registry Writer permission..."
    gcloud projects add-iam-policy-binding glass-backend-api \
        --member="serviceAccount:${CLOUD_BUILD_SA}" \
        --role="roles/artifactregistry.writer"
    
    if [ $? -eq 0 ]; then
        echo "✅ Permission granted successfully!"
    else
        echo "❌ Failed to grant permission."
        exit 1
    fi
else
    echo "✅ Permission already exists."
fi

echo ""
echo "✨ Setup complete! You can now deploy:"
echo "   gcloud run deploy glass-backend-api --source . --region us-central1 --platform managed --allow-unauthenticated"




