#!/bin/bash

# Deploy Speech Server to Google Cloud Run
# Usage: ./deploy.sh [SERVICE_NAME]

set -e

PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-grpc-speech-project}"
REGION="${GCP_LOCATION:-us-central1}"
SERVICE_NAME="${1:-speech-server}"

echo "=========================================="
echo "Deploying to Google Cloud Run"
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "Service: $SERVICE_NAME"
echo "=========================================="

# Set the project
gcloud config set project "$PROJECT_ID"

# Build the Docker image
echo ""
echo "Building Docker image..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME

# Deploy to Cloud Run
echo ""
echo "Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --timeout 3600 \
  --max-instances 10 \
  --set-env-vars "GOOGLE_CLOUD_PROJECT=$PROJECT_ID,SPEECH_SAMPLE_RATE=16000,SPEECH_LANGUAGE=en-US,SPEECH_MODEL=chirp,LOG_LEVEL=INFO,COMPOSITE_INTERIMS=true,USE_NATIVE_IS_FINAL=true" \
  --set-env-vars "RECOGNIZER_FULL_NAME=projects/$PROJECT_ID/locations/$REGION/recognizers/dictation-chirp-recognizer"

# Get the service URL
echo ""
echo "=========================================="
echo "Deployment complete!"
echo ""
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)')
echo "Service URL: $SERVICE_URL"
echo ""
echo "WebSocket URL: ${SERVICE_URL/http/ws}"
echo ""
echo "Update your iOS app settings with:"
echo "  ${SERVICE_URL/http/ws}"
echo "=========================================="

