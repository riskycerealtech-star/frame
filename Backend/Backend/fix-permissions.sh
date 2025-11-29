#!/bin/bash

# Fix Artifact Registry Permissions
# Grants repository-level permissions to Cloud Build service account

set -e

PROJECT_ID="glass-backend-api"
PROJECT_NUMBER="750669515844"
REGION="us-central1"
REPO_NAME="docker-repo"
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Fixing Artifact Registry permissions...${NC}"
echo ""

# Grant permission at repository level
echo -e "${YELLOW}Granting repository-level permissions...${NC}"
gcloud artifacts repositories add-iam-policy-binding ${REPO_NAME} \
    --location=${REGION} \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer" \
    --project=${PROJECT_ID}

echo ""
echo -e "${GREEN}✅ Permission granted at repository level${NC}"
echo ""
echo -e "${BLUE}Now try deploying again:${NC}"
echo -e "   ${GREEN}./deploy.sh${NC}"
echo ""

