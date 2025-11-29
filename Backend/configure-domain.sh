#!/bin/bash

# Custom Domain Configuration Script for Frame Backend API
# Configures www.frameflea.com domain for Cloud Run service

set -e

# Configuration
PROJECT_ID="glass-backend-api"
REGION="us-central1"
SERVICE_NAME="glass-api"
DOMAIN_NAME="www.frameflea.com"
ROOT_DOMAIN="frameflea.com"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🌐 Configuring Custom Domain: ${DOMAIN_NAME}${NC}"
echo ""

# Step 1: Set project
gcloud config set project ${PROJECT_ID} --quiet

# Step 2: Get current service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
    --region ${REGION} \
    --format="value(status.url)" 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    echo -e "${RED}❌ Error: Could not find Cloud Run service: ${SERVICE_NAME}${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found service: ${SERVICE_URL}${NC}"
echo ""

# Step 3: Map custom domain to Cloud Run service
echo -e "${YELLOW}📋 Mapping domain ${DOMAIN_NAME} to Cloud Run service...${NC}"
echo ""

# Map the domain
gcloud run domain-mappings create \
    --service ${SERVICE_NAME} \
    --domain ${DOMAIN_NAME} \
    --region ${REGION} || {
    echo -e "${YELLOW}⚠️  Domain mapping may already exist. Checking status...${NC}"
}

# Step 4: Get DNS records
echo ""
echo -e "${BLUE}📝 DNS Configuration Required:${NC}"
echo ""
echo -e "${YELLOW}Please add the following DNS records to your domain registrar:${NC}"
echo ""

# Get domain mapping details
DOMAIN_MAPPING=$(gcloud run domain-mappings describe ${DOMAIN_NAME} \
    --region ${REGION} \
    --format="yaml" 2>/dev/null || echo "")

if [ -n "$DOMAIN_MAPPING" ]; then
    echo "$DOMAIN_MAPPING" | grep -A 10 "resourceRecords" || {
        echo -e "${YELLOW}Run this command to get DNS records:${NC}"
        echo "gcloud run domain-mappings describe ${DOMAIN_NAME} --region ${REGION}"
    }
else
    echo -e "${YELLOW}To get DNS records, run:${NC}"
    echo "gcloud run domain-mappings describe ${DOMAIN_NAME} --region ${REGION}"
fi

echo ""
echo -e "${GREEN}✅ Domain mapping configuration initiated!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Add the DNS records shown above to your domain registrar"
echo "2. Wait for DNS propagation (can take up to 48 hours, usually 5-30 minutes)"
echo "3. Verify domain is active: gcloud run domain-mappings describe ${DOMAIN_NAME} --region ${REGION}"
echo "4. Test your API: https://${DOMAIN_NAME}/health"
echo ""
echo -e "${BLUE}🔍 To check domain status:${NC}"
echo "gcloud run domain-mappings list --region ${REGION}"
echo ""





