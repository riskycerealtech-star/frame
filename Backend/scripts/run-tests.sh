#!/bin/bash

# Test Runner Script
# Runs all tests with coverage

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧪 Running tests...${NC}"
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}⚠️  Virtual environment not found. Creating one...${NC}"
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    pip install pytest pytest-cov pytest-asyncio
else
    source venv/bin/activate
fi

# Install test dependencies if not installed
if ! python -c "import pytest" 2>/dev/null; then
    echo -e "${YELLOW}📦 Installing test dependencies...${NC}"
    pip install pytest pytest-cov pytest-asyncio
fi

# Set test environment variables
export POSTGRES_SERVER=${POSTGRES_SERVER:-localhost}
export POSTGRES_USER=${POSTGRES_USER:-test_user}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-test_password}
export POSTGRES_DB=${POSTGRES_DB:-test_db}
export POSTGRES_PORT=${POSTGRES_PORT:-5432}
export SECRET_KEY=${SECRET_KEY:-test-secret-key}
export DEBUG=True

# Run linter
echo -e "${BLUE}🔍 Running linter...${NC}"
if command -v flake8 &> /dev/null; then
    flake8 app tests --count --select=E9,F63,F7,F82 --show-source --statistics || true
else
    echo -e "${YELLOW}⚠️  flake8 not installed. Skipping linting.${NC}"
fi

# Run tests
echo ""
echo -e "${BLUE}🧪 Running tests with coverage...${NC}"
pytest tests/ -v --cov=app --cov-report=term --cov-report=html --cov-report=xml

# Check if tests passed
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo -e "${BLUE}📊 Coverage report: htmlcov/index.html${NC}"
else
    echo ""
    echo -e "${RED}❌ Tests failed!${NC}"
    exit 1
fi



