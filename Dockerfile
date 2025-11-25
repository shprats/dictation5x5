FROM python:3.11-slim

WORKDIR /app

# Install system dependencies if needed
RUN apt-get update && apt-get install -y \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the server code
COPY speech_server.py .

# Expose the port
EXPOSE 8080

# Set environment variables (can be overridden in Cloud Run)
ENV PORT=8080
ENV WEBSOCKET_HOST=0.0.0.0
ENV LOG_LEVEL=INFO

# Run the server
CMD ["python", "speech_server.py"]

