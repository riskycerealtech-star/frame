#!/bin/bash
# Check the latest build logs

BUILD_ID="ef5b7470-ffe5-4d3e-9077-742169b175b0"

echo "📋 Checking build logs for: $BUILD_ID"
echo ""
echo "View in browser:"
echo "https://console.cloud.google.com/cloud-build/builds/${BUILD_ID}?project=750669515844&region=us-central1"
echo ""
echo "Or fetch logs with:"
echo "gcloud builds log ${BUILD_ID} --region=us-central1"
echo ""
echo "Fetching last 150 lines of build log..."
gcloud builds log ${BUILD_ID} --region=us-central1 2>/dev/null | tail -150




