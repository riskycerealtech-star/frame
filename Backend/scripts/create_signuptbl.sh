#!/bin/bash

# Script to create signuptbl table in PostgreSQL database
# Usage: ./scripts/create_signuptbl.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Creating signuptbl table in PostgreSQL...${NC}"

# Check if .env file exists
if [ -f .env ]; then
    source .env
elif [ -f ../.env ]; then
    source ../.env
fi

# Database connection parameters (from environment or defaults)
DB_HOST="${POSTGRES_SERVER:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-glass_db}"
DB_USER="${POSTGRES_USER:-glass_user}"
DB_PASSWORD="${POSTGRES_PASSWORD}"

# Check if password is set
if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}Error: POSTGRES_PASSWORD not set in environment${NC}"
    echo "Please set POSTGRES_PASSWORD in your .env file or export it:"
    echo "export POSTGRES_PASSWORD='your_password'"
    exit 1
fi

# SQL file path
SQL_FILE="$(dirname "$0")/create_signuptbl.sql"

# Check if SQL file exists
if [ ! -f "$SQL_FILE" ]; then
    echo -e "${RED}Error: SQL file not found: $SQL_FILE${NC}"
    exit 1
fi

# For Cloud SQL, use Unix socket connection
if [[ "$DB_HOST" == *"/cloudsql"* ]]; then
    echo -e "${YELLOW}Connecting to Cloud SQL via Unix socket...${NC}"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE"
else
    echo -e "${YELLOW}Connecting to PostgreSQL at $DB_HOST:$DB_PORT...${NC}"
    export PGPASSWORD="$DB_PASSWORD"
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ signuptbl table created successfully!${NC}"
    echo ""
    echo "Table structure:"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "\d signuptbl" 2>/dev/null || \
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "\d signuptbl" 2>/dev/null
else
    echo -e "${RED}❌ Error creating signuptbl table${NC}"
    exit 1
fi



