#!/bin/bash

# Build and Push Docker Image Script
# Builds Docker image and pushes to Artifact Registry

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ID="glass-backend-api"
REGION="us-central1"
SERVICE_NAME="glass-api"
REPO_NAME="docker-repo"
IMAGE_NAME="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}"

echo -e "${BLUE}🔨 Building and pushing Docker image...${NC}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI is not installed.${NC}"
    exit 1
fi

# Set project
echo -e "${YELLOW}📋 Setting project to ${PROJECT_ID}...${NC}"
gcloud config set project ${PROJECT_ID} --quiet

# Authenticate Docker
echo -e "${YELLOW}🔐 Authenticating Docker...${NC}"
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# Build and push
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
echo -e "   Image: ${IMAGE_NAME}"
echo ""

gcloud builds submit \
    --tag ${IMAGE_NAME}:latest \
    --tag ${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S) \
    --timeout=20m \
    --quiet

echo ""
echo -e "${GREEN}✅ Image built and pushed successfully!${NC}"
echo -e "${BLUE}📦 Image: ${IMAGE_NAME}:latest${NC}"
echo ""



