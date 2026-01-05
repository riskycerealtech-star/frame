# Dockerfile for Frame Backend (Cloud Run)
# Builds and runs the full Backend FastAPI app (`Backend/app/main.py`)

# Use a stable Python runtime supported by all dependencies
FROM python:3.11-slim

# Base working directory
WORKDIR /app

# Install system dependencies required by PostgreSQL, Pillow, etc.
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    postgresql-client \
    libpq-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Use Backend/requirements.txt so Cloud Run matches the local Backend env
COPY Backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy only the Backend code into the image
COPY Backend ./Backend

# Ensure the Backend package (`app.*`) is importable
ENV PYTHONPATH=/app/Backend

# Cloud Run uses PORT env var; default to 8080
ENV PORT=8080
ENV PYTHONUNBUFFERED=1

EXPOSE 8080

# Run the Backend FastAPI app with gunicorn + uvicorn workers
CMD exec gunicorn -w 4 -k uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:${PORT} \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    app.main:app



