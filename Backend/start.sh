#!/bin/bash
set -e

# Get port from environment variable (Cloud Run sets this)
PORT=${PORT:-8080}

# Start the application using uvicorn directly
exec uvicorn main:app --host 0.0.0.0 --port ${PORT}

