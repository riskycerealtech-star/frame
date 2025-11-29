# Sunglasses Detection API

AI-powered sunglasses validation using Google Cloud Vision API for Flutter mobile applications.

## Features

- ✅ **Accurate Detection**: Uses Google Cloud Vision API for reliable sunglasses detection
- ✅ **Real-time Validation**: Fast API responses (under 3 seconds)
- ✅ **High Confidence**: 80% minimum confidence threshold for sunglasses detection
- ✅ **Multiple Input Formats**: Supports both file upload and base64 encoding
- ✅ **Production Ready**: Comprehensive error handling and logging
- ✅ **CORS Enabled**: Ready for Flutter app integration

## Quick Start

### 1. Install Dependencies

```bash
cd Backend
pip install -r requirements.txt
```

### 2. Google Cloud Vision API Setup

#### Option A: Using Service Account Key (Recommended for Development)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the **Vision API**:
   - Go to "APIs & Services" > "Library"
   - Search for "Vision API" and enable it
4. Create a service account:
   - Go to "IAM & Admin" > "Service Accounts"
   - Click "Create Service Account"
   - Name: "sunglasses-detection-api"
   - Role: "Cloud Vision API User"
5. Download the JSON key file
6. Set environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account-key.json"
   ```

#### Option B: Using Google Cloud SDK (For Production)

```bash
# Install Google Cloud SDK
gcloud auth application-default login
```

### 3. Run the API

```bash
# Development mode
python main.py

# Or using uvicorn directly
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at: `http://localhost:8000`

### 4. Access API Documentation (Swagger UI)

**🎉 Interactive API Documentation is now available!**

Once the server is running, open your browser and visit:

- **Swagger UI**: http://localhost:8000/docs/frame/swagger-ui/index.html
- **ReDoc**: http://localhost:8000/docs/frame/redoc/index.html

Features:
- 📚 View all API endpoints
- 📝 Read detailed descriptions
- 🧪 Test endpoints directly from the browser
- 📊 See request/response examples
- 🔍 Search functionality

#### Swagger UI Authentication (Optional)

By default, Swagger UI is publicly accessible. To enable authentication:

1. Set `ENABLE_SWAGGER_AUTH=True` in `app/core/config.py` or environment variables
2. Default credentials:
   - **clientId**: `frame_api_admin`
   - **clientSecret**: `frame_api_secret_2024`

**Login Endpoint:**
```bash
curl -X POST 'http://localhost:8000/swagger-login' \
  -H 'Content-Type: application/json' \
  -d '{
    "clientId": "frame_api_admin",
    "clientSecret": "frame_api_secret_2024"
  }'
```

**Custom Credentials:**
Update in `app/core/config.py`:
- `SWAGGER_CLIENT_ID`: Your custom client ID
- `SWAGGER_CLIENT_SECRET`: Your custom client secret

### 5. Test the API

```bash
# Health check
curl http://localhost:8000/health

# Test sunglasses validation
curl -X POST "http://localhost:8000/validate-sunglasses" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@path/to/sunglasses_image.jpg"
```

## API Endpoints

### Authentication APIs

#### POST /v1/user/signup

Create a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890",
  "password": "SecurePass123!",
  "gender": "MALE",
  "location": "New York, USA"
}
```

**Response:**
```json
{
  "status": "CREATED",
  "email": "user@example.com",
  "userId": "USR123456",
  "phoneNumber": "+1234567890",
  "createdOn": "2024-01-15T10:30:00Z",
  "updatedOn": "2024-01-15T10:30:00Z"
}
```

#### POST /v1/user/signin/{userId}

Sign in to the application. Returns JWT token for authentication.

**Request:**
```json
{
  "credential": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response:**
```json
{
  "fullName": "John Doe",
  "email": "user@example.com",
  "phoneNumber": "+1234567890",
  "statusCode": 200,
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

#### PATCH /v1/user/account/{userId}

Update user account information. User must be logged in.

**Request:**
```json
{
  "firstName": "John",
  "lastName": "Smith",
  "location": "Los Angeles, USA",
  "password": "NewSecurePass123!"
}
```

**Response:**
```json
{
  "status": "SUCCESS",
  "message": "User information updated successfully",
  "email": "user@example.com",
  "userId": "1",
  "updatedFields": ["firstName", "lastName", "location", "password"],
  "updatedOn": "2024-01-15T10:30:00Z"
}
```

#### POST /v1/user/refresh-token/{userId}

Refresh the user's JWT access token. User must be logged in.

**Request:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "status": "SUCCESS",
  "message": "Token refreshed successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "statusCode": 200,
  "expiresAt": "2024-01-15T11:00:00Z"
}
```

#### POST /v1/user/token-status/{userId}

Check the status of a JWT token to determine if it needs to be refreshed. Useful for auto-refresh logic.

**Request:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "isValid": true,
  "isExpiringSoon": false,
  "expiresAt": "2024-01-15T11:00:00Z",
  "remainingMinutes": 25,
  "shouldRefresh": false,
  "statusCode": 200,
  "message": "Token is valid. Remaining: 25 minutes"
}
```

**Auto-Refresh Logic:**
- When `shouldRefresh` = `true`, call `/v1/user/refresh-token/{userId}` to get a new token
- Poll this endpoint periodically on the client side
- Token expires within 5 minutes when `shouldRefresh` = `true`

#### GET /v1/users/{userId}

Get all users. **Requires authorization.**

**Response:**
```json
{
  "users": [
    {
      "userId": "USR123456",
      "email": "john.doe@example.com",
      "fullName": "John Doe",
      "phoneNumber": "+1234567890",
      "createdOn": "2024-01-15T10:30:00Z",
      "updatedOn": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1
}
```

### Sunglasses Detection APIs

#### POST /validate-sunglasses

Validates if uploaded image contains sunglasses.

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: image file

**Response:**
```json
{
  "status": "accepted",
  "confidence": 0.95,
  "message": "Sunglasses detected with 95% confidence",
  "details": "Detected: Sunglasses with 95% confidence",
  "analysis": {
    "sunglasses_detected": true,
    "confidence": 0.95,
    "objects": [...],
    "labels": [...],
    "analysis_method": "google_cloud_vision"
  }
}
```

#### POST /validate-sunglasses-base64

Alternative endpoint for base64 encoded images.

**Request:**
```json
{
  "image": "base64_encoded_image_data"
}
```

## Configuration

### Environment Variables

Create a `.env` file (copy from `env_example.txt`):

```bash
# Google Cloud Vision API
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json
GOOGLE_CLOUD_PROJECT_ID=your-project-id

# API Settings
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
```

### Confidence Threshold

The API uses an 80% confidence threshold for sunglasses detection. You can modify this in `main.py`:

```python
min_confidence_threshold = 0.8  # 80% minimum confidence
```

## Deployment

### Local Development

```bash
python main.py
```

### Production (Docker)

```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Cloud Deployment

1. **Google Cloud Run** (Recommended)
2. **AWS Lambda** with API Gateway
3. **Heroku** with Google Cloud Vision API
4. **DigitalOcean App Platform**

## Error Handling

The API handles various error scenarios:

- ❌ Invalid file types
- ❌ Empty files
- ❌ Files too large (>50MB)
- ❌ Network errors
- ❌ Vision API quota exceeded
- ❌ Invalid credentials

## Testing

### Test with Sample Images

```bash
# Test with sunglasses image
curl -X POST "http://localhost:8000/validate-sunglasses" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@test_images/sunglasses.jpg"

# Test with regular glasses
curl -X POST "http://localhost:8000/validate-sunglasses" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@test_images/regular_glasses.jpg"
```

### Expected Results

- ✅ **Sunglasses**: `"status": "accepted"`
- ❌ **Regular Glasses**: `"status": "rejected"`
- ❌ **No Eyewear**: `"status": "rejected"`

## Troubleshooting

### Common Issues

1. **"Vision API credentials not found"**
   - Set `GOOGLE_APPLICATION_CREDENTIALS` environment variable
   - Ensure the service account has Vision API permissions

2. **"CORS error"**
   - The API includes CORS middleware for Flutter integration
   - For production, configure specific origins in `main.py`

3. **"File too large"**
   - Maximum file size is 50MB
   - Compress images before upload

4. **"Low confidence"**
   - Ensure images are clear and well-lit
   - Sunglasses should be clearly visible
   - Avoid blurry or dark images

### Mock Mode

If Google Cloud Vision API is not available, the API runs in mock mode for development:

- Returns simulated results based on image characteristics
- Useful for testing Flutter integration
- Replace with actual Vision API for production

## API Documentation

### Swagger UI

The API includes fully interactive Swagger documentation. For detailed information, see:

**[📖 Complete Swagger Guide](docs/SWAGGER_GUIDE.md)**

### Quick Access

- **Swagger UI**: http://localhost:8000/docs/frame/swagger-ui/index.html
- **ReDoc**: http://localhost:8000/docs/frame/redoc/index.html  
- **OpenAPI JSON**: http://localhost:8000/docs/frame/openapi.json

### Features

- ✅ Interactive endpoint testing
- ✅ Request/response examples
- ✅ Detailed parameter descriptions
- ✅ Organized by tags (1. Authentication, Sunglasses Detection)
- ✅ Export OpenAPI specification
- ✅ Generate client code

## Support

For issues and questions:

1. Check the logs: `tail -f server.log`
2. Test with sample images
3. Verify Google Cloud Vision API setup
4. Check network connectivity
5. Review the [Swagger documentation guide](docs/SWAGGER_GUIDE.md)

## License

MIT License - Feel free to use in your projects.

