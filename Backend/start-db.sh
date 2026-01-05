#!/bin/bash
# Script to start PostgreSQL database using Docker Compose

echo "Starting PostgreSQL database..."
cd "$(dirname "$0")"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed"
    exit 1
fi

# Start PostgreSQL
docker-compose up -d postgres

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 5

# Check if PostgreSQL is running
if docker ps | grep -q glass-postgres; then
    echo "✓ PostgreSQL is running"
    echo ""
    echo "Connection details:"
    echo "  Host: localhost"
    echo "  Port: 5432"
    echo "  Database: glass_db"
    echo "  User: glass_user"
    echo "  Password: glass_local_password"
    echo ""
    echo "To connect via psql:"
    echo "  docker exec -it glass-postgres psql -U glass_user -d glass_db"
    echo ""
    echo "To view logs:"
    echo "  docker logs glass-postgres"
else
    echo "✗ Failed to start PostgreSQL"
    exit 1
fi

