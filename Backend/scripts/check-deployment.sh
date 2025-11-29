#!/bin/bash

# Deployment Health Check Script
# Verifies deployment is healthy and accessible

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ID="glass-backend-api"
SERVICE_NAME="glass-api"
REGION="us-central1"

echo -e "${BLUE}🏥 Checking deployment health...${NC}"
echo ""

# Get service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
    --region ${REGION} \
    --project ${PROJECT_ID} \
    --format="value(status.url)" 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    echo -e "${RED}❌ Could not get service URL${NC}"
    exit 1
fi

echo -e "${BLUE}🌐 Service URL: ${SERVICE_URL}${NC}"
echo ""

# Check health endpoint
echo -e "${YELLOW}🔍 Checking health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" ${SERVICE_URL}/health || echo -e "\n000")

HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Health check passed!${NC}"
    echo -e "   Response: ${BODY}"
else
    echo -e "${RED}❌ Health check failed!${NC}"
    echo -e "   HTTP Code: ${HTTP_CODE}"
    echo -e "   Response: ${BODY}"
    exit 1
fi

echo ""

# Check API docs
echo -e "${YELLOW}🔍 Checking API documentation...${NC}"
DOCS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" ${SERVICE_URL}/api/v1/docs || echo "000")

if [ "$DOCS_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ API documentation accessible!${NC}"
    echo -e "   URL: ${SERVICE_URL}/api/v1/docs"
else
    echo -e "${YELLOW}⚠️  API documentation not accessible (HTTP ${DOCS_RESPONSE})${NC}"
fi

echo ""

# Get service details
echo -e "${YELLOW}📊 Service details:${NC}"
gcloud run services describe ${SERVICE_NAME} \
    --region ${REGION} \
    --project ${PROJECT_ID} \
    --format="table(
        status.url,
        status.latestReadyRevisionName,
        status.conditions[0].status,
        spec.template.spec.containers[0].image
    )"

echo ""
echo -e "${GREEN}✅ Deployment check complete!${NC}"



