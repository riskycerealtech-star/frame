#!/bin/bash

# Setup Local Database Script
# This script initializes the local PostgreSQL database

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🗄️  Setting up local database...${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Check if postgres container is running
if ! docker ps | grep -q glass-postgres; then
    echo -e "${YELLOW}⚠️  PostgreSQL container is not running. Starting it...${NC}"
    docker-compose up -d postgres
    echo -e "${GREEN}✅ Waiting for PostgreSQL to be ready...${NC}"
    sleep 5
fi

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
until docker exec glass-postgres pg_isready -U glass_user -d glass_db > /dev/null 2>&1; do
    echo -e "${YELLOW}   Waiting...${NC}"
    sleep 2
done

echo -e "${GREEN}✅ PostgreSQL is ready!${NC}"
echo ""

# Run migrations
echo -e "${BLUE}📦 Running database migrations...${NC}"
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Set default values if not in .env
export POSTGRES_SERVER=${POSTGRES_SERVER:-localhost}
export POSTGRES_USER=${POSTGRES_USER:-glass_user}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-glass_local_password}
export POSTGRES_DB=${POSTGRES_DB:-glass_db}
export POSTGRES_PORT=${POSTGRES_PORT:-5432}

# Run Alembic migrations
if command -v alembic &> /dev/null; then
    alembic upgrade head
    echo -e "${GREEN}✅ Migrations completed!${NC}"
else
    echo -e "${YELLOW}⚠️  Alembic not found. Installing dependencies...${NC}"
    pip install -r requirements.txt
    alembic upgrade head
    echo -e "${GREEN}✅ Migrations completed!${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Database setup complete!${NC}"
echo ""
echo -e "${BLUE}📊 Database connection info:${NC}"
echo -e "   Host: localhost"
echo -e "   Port: 5432"
echo -e "   Database: glass_db"
echo -e "   User: glass_user"
echo -e "   Password: glass_local_password"
echo ""
echo -e "${BLUE}🔧 Next steps:${NC}"
echo -e "   1. Run seed data: ${GREEN}python scripts/seed-data.py${NC}"
echo -e "   2. Start API server: ${GREEN}uvicorn app.main:app --reload${NC}"
echo ""



