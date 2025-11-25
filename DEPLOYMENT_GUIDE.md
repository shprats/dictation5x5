# Dictation5x5 Server Deployment Guide

## Quick Start: Making Changes and Redeploying

### Step 1: Make Your Changes

Edit `speech_server.py` with your changes:
```bash
cd /Users/pratik/Documents/Dictation5x5
# Edit the file
nano speech_server.py  # or use your preferred editor
```

**Common changes:**
- Environment variable defaults (line 75: `MODEL`, etc.)
- Transcription logic (lines 350-435: INTERIM/FINAL handling)
- Error handling (lines 439-497)
- Audio processing configuration

### Step 2: Test Syntax

Always check for errors before deploying:
```bash
python3 -m py_compile speech_server.py
```
No output = success. Errors = fix them first.

### Step 3: Test Locally (Optional but Recommended)

1. **Set environment variables:**
   ```bash
   export GOOGLE_CLOUD_PROJECT="grpc-speech-project"
   export RECOGNIZER_FULL_NAME="projects/grpc-speech-project/locations/us-central1/recognizers/dictation-chirp-recognizer"
   export SPEECH_SAMPLE_RATE=16000
   export SPEECH_MODEL=chirp
   export PORT=8080
   ```

2. **Run server:**
   ```bash
   python3 speech_server.py
   ```

3. **Test with iOS app:**
   - Settings → Change URL to `ws://localhost:8080`
   - Test your changes
   - Stop server: `Ctrl+C`

---

## Deploying to Cloud Run

### Method 1: Quick Deploy (Recommended)

```bash
cd /Users/pratik/Documents/Dictation5x5
./deploy.sh speech-server
```

**What happens:**
1. Builds Docker image with your changes
2. Pushes to Google Container Registry
3. Deploys to Cloud Run
4. Shows WebSocket URL

**Time:** 2-5 minutes (first time), 1-3 minutes (subsequent)

### Method 2: Manual Deploy

```bash
# Build image
gcloud builds submit --tag gcr.io/grpc-speech-project/speech-server

# Deploy
gcloud run deploy speech-server \
  --image gcr.io/grpc-speech-project/speech-server \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --set-env-vars "GOOGLE_CLOUD_PROJECT=grpc-speech-project,SPEECH_SAMPLE_RATE=16000,SPEECH_LANGUAGE=en-US,SPEECH_MODEL=chirp,LOG_LEVEL=INFO,COMPOSITE_INTERIMS=true,USE_NATIVE_IS_FINAL=true" \
  --set-env-vars "RECOGNIZER_FULL_NAME=projects/grpc-speech-project/locations/us-central1/recognizers/dictation-chirp-recognizer"
```

---

## Common Changes

### Change Environment Variables

**Example:** Change default model

1. **Edit `speech_server.py` (line 75):**
   ```python
   MODEL = os.environ.get("SPEECH_MODEL", "long")  # Changed from "chirp"
   ```

2. **Edit `deploy.sh` (line 40):**
   ```bash
   --set-env-vars "...SPEECH_MODEL=long,..."
   ```

3. **Deploy:**
   ```bash
   ./deploy.sh speech-server
   ```

### Modify Transcription Logic

**Example:** Change INTERIM message handling

1. **Edit `speech_server.py` (lines 410-425)**
2. **Test locally** (optional)
3. **Deploy:**
   ```bash
   ./deploy.sh speech-server
   ```

---

## Troubleshooting

### Deployment Fails

**Check syntax:**
```bash
python3 -m py_compile speech_server.py
```

**Check authentication:**
```bash
gcloud auth list
gcloud config get-value project  # Should show: grpc-speech-project
```

### Server Crashes After Deployment

**View logs:**
```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=speech-server" \
  --limit 30 --project grpc-speech-project \
  --format="table(timestamp,severity,textPayload)" | grep ERROR
```

**Common issues:**
- Missing environment variables
- Invalid recognizer name
- Python syntax errors
- Import errors

### Changes Not Appearing

**Verify deployment:**
```bash
gcloud run services describe speech-server --region us-central1
```
Check revision number - should increment with each deploy.

**Force new revision:**
```bash
gcloud run services update speech-server --region us-central1 --no-traffic
```

### iOS App Can't Connect

**Check service status:**
```bash
gcloud run services describe speech-server \
  --region us-central1 \
  --format 'value(status.conditions[0].status)'
```
Should return "True"

**Verify WebSocket URL:**
- Must be `wss://` (not `https://`)
- No trailing slash
- Format: `wss://speech-server-xxxxx-uc.a.run.app`

---

## Quick Reference

### View Service URL
```bash
gcloud run services describe speech-server \
  --region us-central1 \
  --format 'value(status.url)'
```

### View Recent Logs
```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=speech-server" \
  --limit 20 --project grpc-speech-project \
  --format="table(timestamp,severity,textPayload)"
```

### Rollback to Previous Version
```bash
# List revisions
gcloud run revisions list --service speech-server --region us-central1

# Rollback
gcloud run services update-traffic speech-server \
  --region us-central1 \
  --to-revisions PREVIOUS_REVISION_NAME=100
```

---

## Environment Variables

Set these in `deploy.sh` or Cloud Run console:

| Variable | Default | Description |
|----------|---------|-------------|
| `GOOGLE_CLOUD_PROJECT` | (required) | grpc-speech-project |
| `RECOGNIZER_FULL_NAME` | (required) | projects/.../recognizers/dictation-chirp-recognizer |
| `SPEECH_SAMPLE_RATE` | 16000 | Audio sample rate |
| `SPEECH_MODEL` | chirp | Speech model (chirp, long, short) |
| `LOG_LEVEL` | INFO | DEBUG, INFO, WARNING, ERROR |
| `COMPOSITE_INTERIMS` | true | Composite interim results |

---

## Complete Workflow

```
1. Edit speech_server.py
   ↓
2. python3 -m py_compile speech_server.py  (check syntax)
   ↓
3. (Optional) python3 speech_server.py  (test locally)
   ↓
4. ./deploy.sh speech-server  (deploy)
   ↓
5. Check logs if issues occur
   ↓
6. git add . && git commit -m "..." && git push  (save changes)
```

---

## Important Files

- **`speech_server.py`** - Main server code (edit this)
- **`deploy.sh`** - Deployment script (update env vars here)
- **`Dockerfile`** - Docker configuration (rarely need to change)
- **`requirements.txt`** - Python dependencies

---

**Repository:** https://github.com/shprats/dictation5x5  
**Service URL:** https://speech-server-3usq2qjv7a-uc.a.run.app  
**WebSocket URL:** wss://speech-server-3usq2qjv7a-uc.a.run.app
