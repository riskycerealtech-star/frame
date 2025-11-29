#!/bin/bash

# Script to verify signup data is saved in Google Cloud Database
# Usage: ./scripts/verify_signup_db.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Verify Signup Data in Database${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if .env file exists
if [ -f .env ]; then
    source .env
elif [ -f ../.env ]; then
    source ../.env
fi

# Database connection parameters
DB_HOST="${POSTGRES_SERVER:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-glass_db}"
DB_USER="${POSTGRES_USER:-glass_user}"
DB_PASSWORD="${POSTGRES_PASSWORD}"

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}Error: POSTGRES_PASSWORD not set${NC}"
    exit 1
fi

echo -e "${YELLOW}Connecting to database...${NC}"
echo ""

# For Cloud SQL, use Unix socket connection
if [[ "$DB_HOST" == *"/cloudsql"* ]]; then
    echo -e "${YELLOW}Using Cloud SQL Unix socket connection...${NC}"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" <<EOF
-- Query to verify signup data
SELECT 
    id,
    email,
    username,
    first_name,
    last_name,
    phone_number,
    additional_properties->>'gender' as gender,
    additional_properties->>'location' as location,
    occupation,
    source_of_funds,
    created_at,
    updated_at,
    is_verified
FROM users
ORDER BY created_at DESC
LIMIT 10;
EOF
else
    echo -e "${YELLOW}Using TCP connection to $DB_HOST:$DB_PORT...${NC}"
    export PGPASSWORD="$DB_PASSWORD"
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<EOF
-- Query to verify signup data
SELECT 
    id,
    email,
    username,
    first_name,
    last_name,
    phone_number,
    additional_properties->>'gender' as gender,
    additional_properties->>'location' as location,
    occupation,
    source_of_funds,
    created_at,
    updated_at,
    is_verified
FROM users
ORDER BY created_at DESC
LIMIT 10;
EOF
fi

echo ""
echo -e "${GREEN}✅ Database verification complete!${NC}"



