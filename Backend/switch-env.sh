#!/bin/bash

# Environment Switching Script
# Usage: source switch-env.sh [local|cloud]

if [ "$1" == "local" ]; then
    export POSTGRES_SERVER=localhost
    export POSTGRES_USER=glass_user
    export POSTGRES_PASSWORD=your_local_password  # Change this
    export POSTGRES_DB=glass_db
    export POSTGRES_PORT=5432
    export DEBUG=True
    export LOG_LEVEL=DEBUG
    echo "✅ Switched to LOCAL database"
    echo "   POSTGRES_SERVER=localhost"
    echo "   Make sure PostgreSQL is running locally"
elif [ "$1" == "cloud" ]; then
    export POSTGRES_SERVER=/cloudsql/glass-backend-api:us-central1:glass-db
    export POSTGRES_USER=glass_user
    export POSTGRES_PASSWORD=GlassUser2024Secure
    export POSTGRES_DB=glass_db
    export DEBUG=False
    export LOG_LEVEL=INFO
    echo "✅ Switched to CLOUD database"
    echo "   POSTGRES_SERVER=/cloudsql/glass-backend-api:us-central1:glass-db"
    echo "   Make sure Cloud SQL Proxy is running (if testing locally)"
else
    echo "Usage: source switch-env.sh [local|cloud]"
    echo ""
    echo "Examples:"
    echo "  source switch-env.sh local   # Use local PostgreSQL"
    echo "  source switch-env.sh cloud   # Use Cloud SQL"
fi



