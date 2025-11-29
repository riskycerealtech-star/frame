#!/bin/bash
set -e

# Get port from environment variable (Cloud Run sets this)
PORT=${PORT:-8080}

# Start the application using gunicorn with uvicorn workers
exec gunicorn -w 4 -k uvicorn.workers.UvicornWorker \
    --bind "0.0.0.0:${PORT}" \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    main:app

