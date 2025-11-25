# Dictation5x5

A real-time speech-to-text iOS application that streams audio to a WebSocket server for transcription using Google Cloud Speech-to-Text API.

## Features

- Real-time audio streaming to WebSocket server
- Live transcription with interim and final results
- Configurable server URL (local development or Cloud Run)
- Session history and recording playback
- Low-latency audio processing

## Architecture

### iOS App
- **SpeechStreamingManager**: Handles WebSocket connection and audio streaming
- **ServerConfig**: Manages server URL configuration
- **TranscriptModel**: Manages transcript state (final + interim)
- **RecordingStore**: Persists transcripts and audio files

### Python Server (`speech_server.py`)
- WebSocket server that receives audio streams
- Integrates with Google Cloud Speech-to-Text API v2
- Handles interim and final transcription results
- Supports multiple audio encodings (LINEAR16, WEBM_OPUS, OGG_OPUS, MP3)

## Setup

### Prerequisites

1. **Python 3.8+** with pip
2. **Google Cloud Project** with Speech-to-Text API enabled
3. **Google Cloud Speech Recognizer** created (v2 API)
4. **Xcode 14+** for iOS development

### Python Server Setup

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Set up Google Cloud authentication:**
   ```bash
   gcloud auth application-default login
   ```

3. **Create a Speech Recognizer** (if not already created):
   ```bash
   gcloud alpha speech recognizers create RECOGNIZER_NAME \
     --location=us-central1 \
     --model=chirp \
     --language-codes=en-US
   ```

4. **Set environment variables:**
   ```bash
   export GOOGLE_CLOUD_PROJECT="your-project-id"
   export RECOGNIZER_FULL_NAME="projects/your-project-id/locations/us-central1/recognizers/RECOGNIZER_NAME"
   export SPEECH_SAMPLE_RATE=16000
   export SPEECH_LANGUAGE="en-US"
   export SPEECH_MODEL="chirp"
   export PORT=8080
   export LOG_LEVEL=INFO
   ```

5. **Run the server:**
   ```bash
   python speech_server.py
   ```

   The server will start on `ws://localhost:8080` (or the port specified in `PORT`).

### iOS App Setup

1. **Open the project in Xcode:**
   ```bash
   open Dictation5x5.xcodeproj
   ```

2. **Configure server URL:**
   - Run the app
   - Tap the settings (gear) icon
   - Enter your server URL:
     - Local development: `ws://localhost:8080` (requires iOS Simulator or network access)
     - Cloud Run: `wss://your-server-url.run.app`
   - Tap "Save"

3. **For local development with iOS Simulator:**
   - Use `ws://localhost:8080` if running server on your Mac
   - Use `ws://your-mac-ip:8080` if testing on a physical device

4. **For Cloud Run deployment:**
   - Deploy the server to Cloud Run (see Cloud Run deployment section)
   - Use the Cloud Run URL with `wss://` protocol

## Usage

1. **Start the Python server** (if running locally)
2. **Launch the iOS app**
3. **Configure server URL** in settings if needed
4. **Tap "Start"** to begin recording
5. **Speak** - you'll see interim results in real-time
6. **Tap "Stop"** to finalize the transcript
7. **View history** by tapping the history icon

## Server Configuration

The Python server supports various environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `GOOGLE_CLOUD_PROJECT` | (required) | GCP project ID |
| `RECOGNIZER_FULL_NAME` | (required) | Full recognizer resource name |
| `SPEECH_SAMPLE_RATE` | 16000 | Target sample rate (8000-48000) |
| `SPEECH_LANGUAGE` | en-US | Language code |
| `SPEECH_MODEL` | chirp | Speech model |
| `PORT` | 8080 | Server port |
| `WEBSOCKET_HOST` | 0.0.0.0 | Bind address |
| `GCP_LOCATION` | us-central1 | GCP region |
| `LOG_LEVEL` | DEBUG | Logging level |
| `COMPOSITE_INTERIMS` | true | Composite multiple interim results |
| `USE_NATIVE_IS_FINAL` | true | Use native is_final flag |
| `STOP_FINAL_GRACE_SECONDS` | 0 | Grace period after stop |

## Cloud Run Deployment

To deploy the server to Google Cloud Run:

### Quick Deploy (Recommended)

1. **Use the deployment script:**
   ```bash
   ./deploy.sh [SERVICE_NAME]
   ```
   
   Example:
   ```bash
   ./deploy.sh speech-server
   ```
   
   The script will:
   - Build the Docker image
   - Deploy to Cloud Run
   - Display the WebSocket URL for your iOS app

2. **Update your iOS app:**
   - Open the app settings (gear icon)
   - Enter the WebSocket URL shown by the deploy script (format: `wss://your-service-url.run.app`)
   - Save and connect

### Manual Deploy

1. **Build the Docker image:**
   ```bash
   gcloud builds submit --tag gcr.io/grpc-speech-project/speech-server
   ```

2. **Deploy to Cloud Run:**
   ```bash
   gcloud run deploy speech-server \
     --image gcr.io/grpc-speech-project/speech-server \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --port 8080 \
     --memory 512Mi \
     --set-env-vars "GOOGLE_CLOUD_PROJECT=grpc-speech-project,SPEECH_SAMPLE_RATE=16000,SPEECH_LANGUAGE=en-US,SPEECH_MODEL=chirp" \
     --set-env-vars "RECOGNIZER_FULL_NAME=projects/grpc-speech-project/locations/us-central1/recognizers/dictation-chirp-recognizer"
   ```

3. **Get the service URL:**
   ```bash
   gcloud run services describe speech-server --region us-central1 --format 'value(status.url)'
   ```

4. **Update iOS app** with the Cloud Run URL (convert `https://` to `wss://`)

## Protocol

### Client → Server Messages

- `CONFIG_ENCODING:LINEAR16` - First message, specifies audio encoding
- Raw PCM bytes (Int16, little-endian, 16kHz, mono) - Audio data
- `STOP_RECORDING` - Signal to stop and finalize

### Server → Client Messages

- `INTERIM: <text>` - Interim transcription result
- `FINAL: <text>` - Final transcription (cumulative)
- `ACK: STOP_RECEIVED` - Acknowledgment of stop command
- `DONE` - Stream finished
- `ERROR: <message>` - Error occurred

## Audio Format

- **Encoding**: LINEAR16 (PCM)
- **Sample Rate**: 16,000 Hz
- **Channels**: 1 (mono)
- **Bit Depth**: 16-bit
- **Byte Order**: Little-endian

## Troubleshooting

### Server Issues

- **"Failed to init speech client"**: Check GCP authentication and project ID
- **"Invalid recognizer name format"**: Ensure `RECOGNIZER_FULL_NAME` follows format: `projects/.../locations/.../recognizers/...`
- **Connection refused**: Check firewall and port settings

### iOS App Issues

- **Cannot connect**: Verify server URL and that server is running
- **No audio**: Check microphone permissions in iOS Settings
- **No transcription**: Verify server is receiving audio and GCP credentials are valid

## License

[Your License Here]

