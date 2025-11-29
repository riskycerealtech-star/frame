#!/bin/bash

# Cloud Shell Deployment Script for Frame Backend API
# Simplified version for Google Cloud Shell
# No permission setup needed - Cloud Shell has all permissions

set -e

# Configuration
PROJECT_ID="glass-backend-api"
REGION="us-central1"
SERVICE_NAME="glass-api"
REPO_NAME="docker-repo"
IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}"
CONNECTION_NAME="glass-backend-api:${REGION}:glass-db"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Deploying Frame Backend API from Cloud Shell${NC}"
echo ""

# Step 1: Set project
gcloud config set project ${PROJECT_ID} --quiet

# Step 2: Ensure repository exists
REPO_EXISTS=$(gcloud artifacts repositories list \
    --location=${REGION} \
    --format="value(name)" \
    --filter="name:${REPO_NAME}" 2>/dev/null || echo "")

if [ -z "$REPO_EXISTS" ]; then
    echo -e "${YELLOW}Creating Artifact Registry repository...${NC}"
    gcloud artifacts repositories create ${REPO_NAME} \
        --repository-format=docker \
        --location=${REGION} \
        --description="Docker repository for Frame Backend API" \
        --quiet
fi

# Step 3: Build and deploy
echo -e "${YELLOW}Building and deploying...${NC}"
gcloud builds submit --tag ${IMAGE_NAME} --timeout=20m --quiet

gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME} \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --add-cloudsql-instances ${CONNECTION_NAME} \
    --set-env-vars "POSTGRES_SERVER=/cloudsql/${CONNECTION_NAME}" \
    --set-env-vars "POSTGRES_USER=glass_user" \
    --set-env-vars "POSTGRES_DB=glass_db" \
    --set-env-vars "POSTGRES_PASSWORD=GlassUser2024Secure" \
    --set-env-vars "GOOGLE_CLOUD_PROJECT_ID=${PROJECT_ID}" \
    --set-env-vars "SECRET_KEY=your-secret-key-change-in-production-change-this" \
    --set-env-vars "DEBUG=False" \
    --set-env-vars "LOG_LEVEL=INFO" \
    --set-env-vars "BACKEND_CORS_ORIGINS=https://www.frameflea.com,https://frameflea.com,http://localhost:3000,http://localhost:8080" \
    --memory 1Gi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 10 \
    --min-instances 0 \
    --port 8080 \
    --quiet

# Get URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
    --region ${REGION} \
    --format="value(status.url)")

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo -e "${GREEN}   ${SERVICE_URL}${NC}"
echo ""



