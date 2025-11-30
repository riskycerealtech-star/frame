#!/bin/bash

# Quick Deployment Diagnostic Script

echo "🔍 Checking Deployment Status..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ID="glass-backend-api"
REGION="us-central1"

echo -e "${BLUE}=== 1. Git Status ===${NC}"
cd /Users/apple/frame
git status --short
echo ""

echo -e "${BLUE}=== 2. Recent Commits ===${NC}"
git log --oneline -3
echo ""

echo -e "${BLUE}=== 3. Cloud Run Services ===${NC}"
gcloud run services list --region $REGION --project $PROJECT_ID 2>/dev/null || echo -e "${RED}❌ Error: Could not list services. Check authentication.${NC}"
echo ""

echo -e "${BLUE}=== 4. Service 'frame' Details ===${NC}"
gcloud run services describe frame \
  --region $REGION \
  --project $PROJECT_ID \
  --format="table(metadata.name,status.url,spec.template.spec.containers[0].image,metadata.creationTimestamp)" 2>/dev/null || echo -e "${YELLOW}⚠️  Service 'frame' not found${NC}"
echo ""

echo -e "${BLUE}=== 5. Service 'glass-api' Details ===${NC}"
gcloud run services describe glass-api \
  --region $REGION \
  --project $PROJECT_ID \
  --format="table(metadata.name,status.url,spec.template.spec.containers[0].image,metadata.creationTimestamp)" 2>/dev/null || echo -e "${YELLOW}⚠️  Service 'glass-api' not found${NC}"
echo ""

echo -e "${BLUE}=== 6. Testing Endpoint ===${NC}"
RESPONSE=$(curl -s https://frame-750669515844.us-central1.run.app/)
echo "Response: $RESPONSE"
echo ""

echo -e "${BLUE}=== 7. Check GitHub Actions (Manual) ===${NC}"
echo "Go to: https://github.com/your-username/your-repo/actions"
echo ""

echo -e "${BLUE}=== Summary ===${NC}"
if echo "$RESPONSE" | grep -q "TEST - GitHub Auto-Deploy"; then
    echo -e "${GREEN}✅ New code is deployed!${NC}"
elif echo "$RESPONSE" | grep -q "Welcome to Frame"; then
    echo -e "${YELLOW}⚠️  Old code still running${NC}"
    echo "   - Check if GitHub Actions workflow ran"
    echo "   - Check if workflow deployed to correct service"
    echo "   - Service 'frame' might be different from 'glass-api'"
else
    echo -e "${RED}❌ Could not test endpoint${NC}"
fi



