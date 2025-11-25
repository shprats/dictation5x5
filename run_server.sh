#!/bin/bash

# Speech Server Startup Script
# Edit the variables below with your actual values

# Your Google Cloud Project ID
export GOOGLE_CLOUD_PROJECT="grpc-speech-project"

# Your Speech Recognizer full name
# Format: projects/PROJECT_ID/locations/LOCATION/recognizers/RECOGNIZER_NAME
# Example: projects/grpc-speech-project/locations/us-central1/recognizers/my-recognizer
export RECOGNIZER_FULL_NAME="projects/grpc-speech-project/locations/us-central1/recognizers/dictation-chirp-recognizer"

# Audio settings
export SPEECH_SAMPLE_RATE=16000
export SPEECH_LANGUAGE="en-US"
export SPEECH_MODEL="chirp"

# Server settings
export PORT=8080
export WEBSOCKET_HOST="0.0.0.0"
export LOG_LEVEL="INFO"

# Optional settings
export COMPOSITE_INTERIMS="true"
export USE_NATIVE_IS_FINAL="true"
export STOP_FINAL_GRACE_SECONDS="0"

# Run the server
echo "Starting Speech Server..."
echo "Project: $GOOGLE_CLOUD_PROJECT"
echo "Recognizer: $RECOGNIZER_FULL_NAME"
echo "Port: $PORT"
echo ""

python3 speech_server.py

