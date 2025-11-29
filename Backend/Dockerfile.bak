# Use Python 3.12 slim image for Cloud Run (better package compatibility)
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies (including PostgreSQL dev libraries for psycopg2 and Pillow)
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    libpq-dev \
    python3-dev \
    libjpeg-dev \
    zlib1g-dev \
    libtiff-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for better Docker layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Cloud Run uses PORT environment variable (defaults to 8080)
ENV PORT=8080

# Expose the port
EXPOSE $PORT

# Run the application using uvicorn (better for FastAPI on Cloud Run)
CMD exec uvicorn app.main:app --host 0.0.0.0 --port $PORT --workers 1

