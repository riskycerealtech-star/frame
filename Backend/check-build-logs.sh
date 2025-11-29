#!/bin/bash
# Check the latest build logs

echo "📋 Latest build ID: cb77a458-0b2f-4c3e-9c8d-06d3e008946c"
echo ""
echo "To view the build logs, run:"
echo "gcloud builds log cb77a458-0b2f-4c3e-9c8d-06d3e008946c --region=us-central1"
echo ""
echo "Or open this URL in your browser:"
echo "https://console.cloud.google.com/cloud-build/builds/cb77a458-0b2f-4c3e-9c8d-06d3e008946c?project=750669515844&region=us-central1"
echo ""
echo "Fetching logs now..."
gcloud builds log cb77a458-0b2f-4c3e-9c8d-06d3e008946c --region=us-central1 | tail -100
