#!/bin/bash

# Comprehensive Permission Fix Script
# Fixes all Artifact Registry permissions for Cloud Build

set -e

PROJECT_ID="glass-backend-api"
PROJECT_NUMBER="750669515844"
REPO_NAME="glass-api-new"
REGION="us-central1"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔧 Fixing All Artifact Registry Permissions${NC}"
echo ""

# Set project
gcloud config set project ${PROJECT_ID} --quiet

echo -e "${YELLOW}Granting permissions to Cloud Build service accounts...${NC}"

# Grant permissions to the main Cloud Build service account
gcloud artifacts repositories add-iam-policy-binding ${REPO_NAME} \
    --location=${REGION} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/artifactregistry.writer" \
    --project=${PROJECT_ID}

# Also grant to the Cloud Build service agent
gcloud artifacts repositories add-iam-policy-binding ${REPO_NAME} \
    --location=${REGION} \
    --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-cloudbuild.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer" \
    --project=${PROJECT_ID}

# Grant at project level as well (for broader access)
echo -e "${YELLOW}Granting project-level permissions...${NC}"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-cloudbuild.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"

# Grant Storage Admin for Cloud Build (needed for builds)
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/storage.admin"

echo ""
echo -e "${GREEN}✅ All permissions granted!${NC}"
echo ""
echo -e "${YELLOW}⏳ Wait 1-2 minutes for permissions to propagate...${NC}"
echo ""
echo -e "${BLUE}Then deploy with: ./deploy.sh${NC}"
echo ""





