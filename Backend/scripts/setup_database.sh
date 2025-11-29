#!/bin/bash

# Script to set up the database tables
# Usage: ./scripts/setup_database.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setting up Database Tables${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

SQL_FILE="$(dirname "$0")/create_users_table.sql"

if [ ! -f "$SQL_FILE" ]; then
    echo -e "${RED}Error: SQL file not found: $SQL_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}To create the users table, run this command in your Cloud SQL connection:${NC}"
echo ""
echo -e "${GREEN}In psql (after connecting with gcloud sql connect):${NC}"
echo ""
echo -e "${YELLOW}\c glass_db${NC}"
echo -e "${YELLOW}\\i $SQL_FILE${NC}"
echo ""
echo -e "${BLUE}Or copy and paste the SQL from: $SQL_FILE${NC}"
echo ""



