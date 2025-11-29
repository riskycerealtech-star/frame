#!/bin/bash
# Test script to verify the Dockerfile builds locally
# This helps catch issues before deploying to Cloud Run

echo "Building Docker image locally..."
docker build -t glass-backend-api:test .

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "To test locally, run:"
    echo "docker run -p 8080:8080 -e PORT=8080 glass-backend-api:test"
else
    echo "❌ Build failed! Check the error messages above."
    exit 1
fi

