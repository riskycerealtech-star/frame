#!/bin/bash

# Verification Script for Frame Backend API Deployment
# This script checks if all requirements are met before deployment

set -e

# Configuration
PROJECT_ID="glass-backend-api"
PROJECT_NUMBER="750669515844"
REGION="us-central1"
SERVICE_NAME="glass-api"
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Verifying deployment setup for Frame Backend API${NC}"
echo ""

# Track overall status
ALL_GOOD=true

# Step 1: Check project
echo -e "${BLUE}1. Checking project configuration...${NC}"
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
if [ "$CURRENT_PROJECT" = "$PROJECT_ID" ]; then
    echo -e "   ${GREEN}✅ Project is set to: ${PROJECT_ID}${NC}"
else
    echo -e "   ${RED}❌ Project mismatch. Current: ${CURRENT_PROJECT}, Expected: ${PROJECT_ID}${NC}"
    echo -e "   ${YELLOW}   Fix: gcloud config set project ${PROJECT_ID}${NC}"
    ALL_GOOD=false
fi
echo ""

# Step 2: Check APIs
echo -e "${BLUE}2. Checking required APIs...${NC}"
APIS=(
    "cloudbuild.googleapis.com:Cloud Build API"
    "run.googleapis.com:Cloud Run API"
    "artifactregistry.googleapis.com:Artifact Registry API"
    "containerregistry.googleapis.com:Container Registry API"
    "sqladmin.googleapis.com:Cloud SQL Admin API"
    "secretmanager.googleapis.com:Secret Manager API"
    "vision.googleapis.com:Cloud Vision API"
)

for API_INFO in "${APIS[@]}"; do
    IFS=':' read -r API_NAME API_DESC <<< "$API_INFO"
    if gcloud services list --enabled --filter="name:${API_NAME}" --format="value(name)" 2>/dev/null | grep -q "${API_NAME}"; then
        echo -e "   ${GREEN}✅ ${API_DESC}${NC}"
    else
        echo -e "   ${RED}❌ ${API_DESC} - NOT ENABLED${NC}"
        echo -e "      ${YELLOW}Fix: gcloud services enable ${API_NAME}${NC}"
        ALL_GOOD=false
    fi
done
echo ""

# Step 3: Check IAM permissions
echo -e "${BLUE}3. Checking IAM permissions for Cloud Build service account...${NC}"
echo -e "   Service Account: ${CLOUD_BUILD_SA}"

REQUIRED_ROLES=(
    "roles/artifactregistry.writer:Artifact Registry Writer"
    "roles/run.admin:Cloud Run Admin"
    "roles/iam.serviceAccountUser:Service Account User"
    "roles/storage.admin:Storage Admin"
)

IAM_BINDINGS=$(gcloud projects get-iam-policy ${PROJECT_ID} \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:${CLOUD_BUILD_SA}" \
    --format="value(bindings.role)" 2>/dev/null || echo "")

for ROLE_INFO in "${REQUIRED_ROLES[@]}"; do
    IFS=':' read -r ROLE_NAME ROLE_DESC <<< "$ROLE_INFO"
    if echo "$IAM_BINDINGS" | grep -q "^${ROLE_NAME}$"; then
        echo -e "   ${GREEN}✅ ${ROLE_DESC}${NC}"
    else
        echo -e "   ${RED}❌ ${ROLE_DESC} - NOT GRANTED${NC}"
        echo -e "      ${YELLOW}Fix: gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=\"serviceAccount:${CLOUD_BUILD_SA}\" --role=\"${ROLE_NAME}\"${NC}"
        ALL_GOOD=false
    fi
done
echo ""

# Step 4: Check Artifact Registry repository
echo -e "${BLUE}4. Checking Artifact Registry repository...${NC}"
REPO_NAME="docker-repo"
REPO_EXISTS=$(gcloud artifacts repositories list \
    --location=${REGION} \
    --format="value(name)" \
    --filter="name:${REPO_NAME}" 2>/dev/null || echo "")

if [ -n "$REPO_EXISTS" ]; then
    echo -e "   ${GREEN}✅ Repository '${REPO_NAME}' exists in ${REGION}${NC}"
else
    echo -e "   ${YELLOW}⚠️  Repository '${REPO_NAME}' does not exist${NC}"
    echo -e "      ${YELLOW}Fix: gcloud artifacts repositories create ${REPO_NAME} --repository-format=docker --location=${REGION}${NC}"
    # Not critical, we can create it during deployment
fi
echo ""

# Step 5: Check Cloud SQL instance
echo -e "${BLUE}5. Checking Cloud SQL instance...${NC}"
DB_INSTANCE="glass-db"
INSTANCE_EXISTS=$(gcloud sql instances list \
    --filter="name:${DB_INSTANCE}" \
    --format="value(name)" 2>/dev/null || echo "")

if [ -n "$INSTANCE_EXISTS" ]; then
    echo -e "   ${GREEN}✅ Cloud SQL instance '${DB_INSTANCE}' exists${NC}"
    
    # Check database
    DB_EXISTS=$(gcloud sql databases list --instance=${DB_INSTANCE} --format="value(name)" --filter="name:glass_db" 2>/dev/null || echo "")
    if [ -n "$DB_EXISTS" ]; then
        echo -e "   ${GREEN}✅ Database 'glass_db' exists${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Database 'glass_db' does not exist${NC}"
    fi
    
    # Check user
    USER_EXISTS=$(gcloud sql users list --instance=${DB_INSTANCE} --format="value(name)" --filter="name:glass_user" 2>/dev/null || echo "")
    if [ -n "$USER_EXISTS" ]; then
        echo -e "   ${GREEN}✅ Database user 'glass_user' exists${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Database user 'glass_user' does not exist${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  Cloud SQL instance '${DB_INSTANCE}' does not exist${NC}"
fi
echo ""

# Step 6: Check Dockerfile
echo -e "${BLUE}6. Checking required files...${NC}"
if [ -f "Dockerfile" ]; then
    echo -e "   ${GREEN}✅ Dockerfile exists${NC}"
else
    echo -e "   ${RED}❌ Dockerfile not found${NC}"
    ALL_GOOD=false
fi

if [ -f "requirements.txt" ]; then
    echo -e "   ${GREEN}✅ requirements.txt exists${NC}"
else
    echo -e "   ${RED}❌ requirements.txt not found${NC}"
    ALL_GOOD=false
fi

if [ -f "app/main.py" ]; then
    echo -e "   ${GREEN}✅ app/main.py exists${NC}"
else
    echo -e "   ${YELLOW}⚠️  app/main.py not found (check your app structure)${NC}"
fi
echo ""

# Final summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$ALL_GOOD" = true ]; then
    echo -e "${GREEN}✅ All critical requirements are met!${NC}"
    echo -e "${GREEN}   You can proceed with deployment.${NC}"
    echo ""
    echo -e "${BLUE}Next step:${NC}"
    echo -e "   ${GREEN}./deploy.sh${NC}"
    exit 0
else
    echo -e "${RED}❌ Some requirements are missing!${NC}"
    echo -e "${YELLOW}   Please fix the issues above before deploying.${NC}"
    echo ""
    echo -e "${BLUE}Quick fix:${NC}"
    echo -e "   ${GREEN}./setup-permissions.sh${NC}"
    exit 1
fi



