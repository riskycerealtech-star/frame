#!/bin/bash

# Check Artifact Registry Images Script

PROJECT_ID="glass-backend-api"
REPO_NAME="glass-api-new"
REGION="us-central1"

echo "📦 Checking images in Artifact Registry repository..."
echo ""

# List images in the repository
gcloud artifacts docker images list us-central1-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME} \
    --include-tags \
    --format="table(package,version,tags,create_time,update_time)"

echo ""
echo "✅ Done!"





