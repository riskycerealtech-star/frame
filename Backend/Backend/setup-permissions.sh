#!/bin/bash

# Setup Permissions Script for Glass Backend API
# This script sets up all required permissions and APIs for Cloud Run deployment

set -e  # Exit on error

# Configuration
PROJECT_ID="glass-backend-api"
REGION="us-central1"
SERVICE_NAME="glass-api"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up permissions for Glass Backend API${NC}"
echo ""

# Step 1: Set the project
echo -e "${YELLOW}📋 Setting project to ${PROJECT_ID}...${NC}"
gcloud config set project ${PROJECT_ID} --quiet

# Step 2: Get project number
echo -e "${YELLOW}🔍 Getting project number...${NC}"
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
if [ -z "$PROJECT_NUMBER" ]; then
    echo -e "${RED}❌ Error: Could not get project number${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Project number: ${PROJECT_NUMBER}${NC}"
echo ""

# Step 3: Enable required APIs
echo -e "${YELLOW}🔌 Enabling required Google Cloud APIs...${NC}"

APIS=(
    "cloudbuild.googleapis.com"
    "run.googleapis.com"
    "artifactregistry.googleapis.com"
    "containerregistry.googleapis.com"
    "sqladmin.googleapis.com"
    "secretmanager.googleapis.com"
    "vision.googleapis.com"
)

for API in "${APIS[@]}"; do
    echo -e "  Enabling ${API}..."
    gcloud services enable ${API} --project=${PROJECT_ID} --quiet || true
done

echo -e "${GREEN}✅ All APIs enabled${NC}"
echo ""

# Step 4: Grant permissions to Cloud Build service account
echo -e "${YELLOW}🔐 Granting permissions to Cloud Build service account...${NC}"

CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Grant Storage Admin (for Container Registry)
echo -e "  Granting roles/storage.admin..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/storage.admin" \
    --condition=None \
    --quiet || echo -e "  ${YELLOW}⚠️  Storage admin role may already be granted${NC}"

# Grant Artifact Registry Writer (for pushing Docker images)
echo -e "  Granting roles/artifactregistry.writer..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/artifactregistry.writer" \
    --condition=None \
    --quiet || echo -e "  ${YELLOW}⚠️  Artifact Registry writer role may already be granted${NC}"

# Grant Cloud Run Admin (for deploying services)
echo -e "  Granting roles/run.admin..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/run.admin" \
    --condition=None \
    --quiet || echo -e "  ${YELLOW}⚠️  Cloud Run admin role may already be granted${NC}"

# Grant Service Account User (to act as service accounts)
echo -e "  Granting roles/iam.serviceAccountUser..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/iam.serviceAccountUser" \
    --condition=None \
    --quiet || echo -e "  ${YELLOW}⚠️  Service Account User role may already be granted${NC}"

# Grant Logging Writer (for logs)
echo -e "  Granting roles/logging.logWriter..."
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${CLOUD_BUILD_SA}" \
    --role="roles/logging.logWriter" \
    --condition=None \
    --quiet || echo -e "  ${YELLOW}⚠️  Logging writer role may already be granted${NC}"

echo -e "${GREEN}✅ Permissions granted${NC}"
echo ""

# Step 5: Create Artifact Registry repository (if it doesn't exist)
echo -e "${YELLOW}📦 Setting up Artifact Registry repository...${NC}"

REPO_NAME="docker-repo"
REPO_EXISTS=$(gcloud artifacts repositories list \
    --location=${REGION} \
    --format="value(name)" \
    --filter="name:${REPO_NAME}" 2>/dev/null || echo "")

if [ -z "$REPO_EXISTS" ]; then
    echo -e "  Creating Artifact Registry repository: ${REPO_NAME}..."
    gcloud artifacts repositories create ${REPO_NAME} \
        --repository-format=docker \
        --location=${REGION} \
        --description="Docker repository for Glass Backend API" \
        --quiet || echo -e "  ${YELLOW}⚠️  Repository may already exist or creation failed${NC}"
    echo -e "${GREEN}✅ Repository created${NC}"
else
    echo -e "${GREEN}✅ Repository already exists${NC}"
fi
echo ""

# Step 6: Verify setup
echo -e "${YELLOW}🔍 Verifying setup...${NC}"

# Check if Cloud Build service account has required roles
echo -e "  Checking Cloud Build service account permissions..."
IAM_BINDINGS=$(gcloud projects get-iam-policy ${PROJECT_ID} \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:${CLOUD_BUILD_SA}" \
    --format="value(bindings.role)" 2>/dev/null || echo "")

if echo "$IAM_BINDINGS" | grep -q "storage.admin"; then
    echo -e "  ${GREEN}✅ Storage Admin: Granted${NC}"
else
    echo -e "  ${RED}❌ Storage Admin: Missing${NC}"
fi

if echo "$IAM_BINDINGS" | grep -q "artifactregistry.writer"; then
    echo -e "  ${GREEN}✅ Artifact Registry Writer: Granted${NC}"
else
    echo -e "  ${YELLOW}⚠️  Artifact Registry Writer: May need manual setup${NC}"
fi

if echo "$IAM_BINDINGS" | grep -q "run.admin"; then
    echo -e "  ${GREEN}✅ Cloud Run Admin: Granted${NC}"
else
    echo -e "  ${YELLOW}⚠️  Cloud Run Admin: May need manual setup${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${BLUE}📝 Next steps:${NC}"
echo -e "  1. Run: ${GREEN}./deploy.sh${NC}"
echo -e "  2. Wait for deployment to complete"
echo -e "  3. Your API will be available at the URL shown"
echo ""

