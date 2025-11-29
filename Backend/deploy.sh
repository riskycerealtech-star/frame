#!/bin/bash

# Cloud Run Deployment Script for Frame Backend API
# Project: glass-backend-api
# Framework: FastAPI

set -e  # Exit on error

# Configuration
PROJECT_ID="glass-backend-api"
PROJECT_NUMBER="750669515844"
REGION="us-central1"
SERVICE_NAME="glass-api"
REPO_NAME="docker-repo"
# Use Artifact Registry
IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}"
CONNECTION_NAME="glass-backend-api:${REGION}:glass-db"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Deploying Frame Backend API to Cloud Run${NC}"
echo -e "${BLUE}   Project: ${PROJECT_ID}${NC}"
echo -e "${BLUE}   Region: ${REGION}${NC}"
echo -e "${BLUE}   Service: ${SERVICE_NAME}${NC}"
echo ""

# Step 1: Verify setup
echo -e "${YELLOW}📋 Step 1: Verifying setup...${NC}"
if [ -f "verify-setup.sh" ]; then
    if ! bash verify-setup.sh; then
        echo -e "${RED}❌ Setup verification failed. Please fix the issues above.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  verify-setup.sh not found, skipping verification${NC}"
fi
echo ""

# Step 2: Set project explicitly
echo -e "${YELLOW}📋 Step 2: Setting project...${NC}"
gcloud config set project ${PROJECT_ID} --quiet
echo -e "${GREEN}✅ Project set to ${PROJECT_ID}${NC}"
echo ""

# Step 3: Ensure Artifact Registry repository exists
echo -e "${YELLOW}📋 Step 3: Checking Artifact Registry repository...${NC}"
REPO_EXISTS=$(gcloud artifacts repositories list \
    --location=${REGION} \
    --format="value(name)" \
    --filter="name:${REPO_NAME}" 2>/dev/null || echo "")

if [ -z "$REPO_EXISTS" ]; then
    echo -e "  Creating Artifact Registry repository: ${REPO_NAME}..."
    if gcloud artifacts repositories create ${REPO_NAME} \
        --repository-format=docker \
        --location=${REGION} \
        --description="Docker repository for Frame Backend API" \
        --quiet; then
        echo -e "${GREEN}✅ Repository created${NC}"
    else
        echo -e "${RED}❌ Failed to create repository${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Repository already exists${NC}"
fi
echo ""

# Step 4: Build Docker image
echo -e "${YELLOW}📋 Step 4: Building Docker image...${NC}"
echo -e "  Image: ${IMAGE_NAME}"
echo -e "  This may take 10-15 minutes..."
echo ""

BUILD_START_TIME=$(date +%s)

if gcloud builds submit \
    --tag ${IMAGE_NAME} \
    --project=${PROJECT_ID} \
    --region=${REGION} \
    --timeout=20m \
    --quiet; then
    BUILD_END_TIME=$(date +%s)
    BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
    echo -e "${GREEN}✅ Image built successfully (took ${BUILD_DURATION} seconds)${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    echo ""
    echo -e "${YELLOW}💡 To check build logs, run:${NC}"
    echo -e "   gcloud builds list --limit=1 --format=\"value(id)\" | xargs -I {} gcloud builds log {}"
    exit 1
fi
echo ""

# Step 5: Deploy to Cloud Run
echo -e "${YELLOW}📋 Step 5: Deploying to Cloud Run...${NC}"
echo -e "  This may take 5-10 minutes..."
echo ""

DEPLOY_START_TIME=$(date +%s)

if gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME} \
    --platform managed \
    --region ${REGION} \
    --project ${PROJECT_ID} \
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
    --memory 1Gi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 10 \
    --min-instances 0 \
    --port 8080 \
    --quiet; then
    DEPLOY_END_TIME=$(date +%s)
    DEPLOY_DURATION=$((DEPLOY_END_TIME - DEPLOY_START_TIME))
    echo -e "${GREEN}✅ Deployment successful (took ${DEPLOY_DURATION} seconds)${NC}"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    echo ""
    echo -e "${YELLOW}💡 To check deployment logs, run:${NC}"
    echo -e "   gcloud run services logs read ${SERVICE_NAME} --region ${REGION} --limit 50"
    exit 1
fi
echo ""

# Step 6: Get service URL and test
echo -e "${YELLOW}📋 Step 6: Getting service information...${NC}"
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
    --region ${REGION} \
    --project ${PROJECT_ID} \
    --format="value(status.url)" 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    echo -e "${YELLOW}⚠️  Could not retrieve service URL${NC}"
    echo -e "${YELLOW}   Check Cloud Run console: https://console.cloud.google.com/run?project=${PROJECT_ID}${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📍 Your API is live at:${NC}"
echo -e "${GREEN}   ${SERVICE_URL}${NC}"
echo ""
echo -e "${BLUE}📚 API Documentation:${NC}"
echo -e "   ${SERVICE_URL}/api/v1/docs"
echo ""
echo -e "${BLUE}❤️  Health Check:${NC}"
echo -e "   ${SERVICE_URL}/health"
echo ""
echo -e "${BLUE}🔍 Test your API:${NC}"
echo -e "   curl ${SERVICE_URL}/health"
echo ""
echo -e "${BLUE}📊 View logs:${NC}"
echo -e "   gcloud run services logs read ${SERVICE_NAME} --region ${REGION} --limit 50"
echo ""
echo -e "${BLUE}🔧 Update service:${NC}"
echo -e "   ./deploy.sh"
echo ""
