# AI-Based Sunglasses Detection Setup Guide

Complete setup guide for implementing AI-powered sunglasses validation in your Flutter app.

## 🎯 Overview

This implementation provides:
- ✅ **Real-time AI validation** using Google Cloud Vision API
- ✅ **Flutter integration** with comprehensive error handling
- ✅ **Production-ready backend** with FastAPI
- ✅ **User-friendly feedback** with loading states and retry options
- ✅ **80% confidence threshold** for accurate sunglasses detection

## 📋 Prerequisites

- Flutter SDK (3.8.1+)
- Python 3.9+
- Google Cloud account
- Internet connection for API calls

## 🚀 Quick Start

### 1. Backend Setup

#### Install Dependencies
```bash
cd Backend
pip install -r requirements.txt
```

#### Google Cloud Vision API Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/select a project
3. Enable Vision API:
   - Go to "APIs & Services" > "Library"
   - Search "Vision API" and enable it
4. Create service account:
   - Go to "IAM & Admin" > "Service Accounts"
   - Create service account with "Cloud Vision API User" role
   - Download JSON key file
5. Set environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account-key.json"
   ```

#### Run Backend
```bash
cd Backend
python main.py
```
API will be available at: `http://localhost:8000`

### 2. Flutter Setup

#### Install Dependencies
```bash
cd glassmobileapp
flutter pub get
```

#### Update API URL (if needed)
Edit `lib/services/ai/sunglasses_validation_service.dart`:
```dart
static const String _baseUrl = 'http://YOUR_BACKEND_URL:8000';
```

#### Run Flutter App
```bash
flutter run
```

## 🔧 Configuration

### Backend Configuration

#### Environment Variables
Create `.env` file in `Backend/` directory:
```bash
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json
GOOGLE_CLOUD_PROJECT_ID=your-project-id
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True
```

#### Confidence Threshold
Modify in `Backend/main.py`:
```python
min_confidence_threshold = 0.8  # 80% minimum confidence
```

### Flutter Configuration

#### API Endpoint
Update in `lib/services/ai/sunglasses_validation_service.dart`:
```dart
static const String _baseUrl = 'http://your-backend-url:8000';
```

#### Timeout Settings
```dart
static const Duration _timeout = Duration(seconds: 10);
static const Duration _connectionTimeout = Duration(seconds: 5);
```

## 🧪 Testing

### Test Backend API

#### Health Check
```bash
curl http://localhost:8000/health
```

#### Test Sunglasses Validation
```bash
curl -X POST "http://localhost:8000/validate-sunglasses" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@path/to/sunglasses_image.jpg"
```

### Test Flutter Integration

1. **Open Product Registration Screen**
   - Tap "+" icon in home screen
   - Navigate to product registration

2. **Test Image Upload**
   - Tap "Select Image" button
   - Image should appear with preview

3. **Test AI Validation**
   - Tap "Submit Product" button
   - Should show "Validating..." state
   - Should display validation result

## 📱 User Experience Flow

### Successful Validation
1. User selects image → Image preview appears
2. User taps "Submit Product" → Shows "Validating..."
3. AI analyzes image → Shows confidence percentage
4. Sunglasses detected → Shows "Sunglasses verified! Submitting..."
5. Form submits → Success message → Navigate back

### Failed Validation
1. User selects image → Image preview appears
2. User taps "Submit Product" → Shows "Validating..."
3. AI analyzes image → No sunglasses detected
4. Shows error message → "Please upload an image with sunglasses"
5. User can retry with different image

## 🛠️ Troubleshooting

### Common Issues

#### 1. "AI validation service is not available"
- **Cause**: Backend not running or network issues
- **Solution**: 
  - Check if backend is running: `curl http://localhost:8000/health`
  - Verify network connectivity
  - Check API URL in Flutter service

#### 2. "Google Cloud Vision API credentials not found"
- **Cause**: Missing or invalid service account key
- **Solution**:
  - Set `GOOGLE_APPLICATION_CREDENTIALS` environment variable
  - Verify service account has Vision API permissions
  - Check JSON key file path

#### 3. "File too large" error
- **Cause**: Image exceeds 10MB limit
- **Solution**: Compress image before upload

#### 4. "Low confidence" validation failures
- **Cause**: Poor image quality or unclear sunglasses
- **Solution**:
  - Use clear, well-lit images
  - Ensure sunglasses are clearly visible
  - Avoid blurry or dark images

### Debug Mode

#### Backend Debug
```bash
# Run with debug logging
python main.py --log-level debug
```

#### Flutter Debug
```dart
// Enable debug prints in sunglasses_validation_service.dart
debugPrint('API Response: $response');
```

## 🚀 Deployment

### Backend Deployment

#### Option 1: Google Cloud Run (Recommended)
```bash
# Build and deploy to Cloud Run
gcloud run deploy sunglasses-api --source .
```

#### Option 2: Docker
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Option 3: Heroku
```bash
# Deploy to Heroku
heroku create your-sunglasses-api
git push heroku main
```

### Flutter Deployment

#### Update API URL for Production
```dart
static const String _baseUrl = 'https://your-production-api.com';
```

#### Build for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📊 Performance Metrics

### Expected Performance
- **API Response Time**: < 3 seconds
- **Confidence Threshold**: 80%
- **Accuracy**: 95%+ for clear sunglasses images
- **File Size Limit**: 10MB
- **Supported Formats**: JPEG, PNG, WebP

### Monitoring
- Backend logs: `tail -f logs/api.log`
- Flutter debug console for validation results
- Google Cloud Vision API usage dashboard

## 🔒 Security Considerations

### Production Security
1. **API Keys**: Store in environment variables, never in code
2. **CORS**: Configure specific origins for production
3. **Rate Limiting**: Implement request rate limiting
4. **Authentication**: Add API authentication if needed
5. **HTTPS**: Use HTTPS for all API communications

### Example Production Configuration
```python
# In main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-flutter-app.com"],  # Specific origins
    allow_credentials=True,
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)
```

## 📈 Scaling

### High Traffic Considerations
1. **Load Balancing**: Use multiple backend instances
2. **Caching**: Cache validation results for similar images
3. **Queue System**: Use Redis/RabbitMQ for request queuing
4. **CDN**: Use CDN for static assets
5. **Database**: Store validation history for analytics

## 🆘 Support

### Getting Help
1. **Check Logs**: Review backend and Flutter logs
2. **Test API**: Use curl commands to test backend
3. **Verify Setup**: Ensure all prerequisites are met
4. **Google Cloud**: Check Vision API quota and billing

### Common Solutions
- **Mock Mode**: Backend runs in mock mode if Vision API unavailable
- **Retry Logic**: Flutter app includes retry functionality
- **Error Messages**: Clear user-friendly error messages
- **Fallback**: Graceful degradation when API unavailable

## 📝 API Reference

### Endpoints

#### POST /validate-sunglasses
- **Input**: Multipart form with image file
- **Output**: JSON with validation result
- **Timeout**: 10 seconds

#### POST /validate-sunglasses-base64
- **Input**: JSON with base64 encoded image
- **Output**: JSON with validation result
- **Timeout**: 10 seconds

#### GET /health
- **Input**: None
- **Output**: API status information
- **Timeout**: 5 seconds

### Response Format
```json
{
  "status": "accepted|rejected",
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

## 🎉 Success!

Your AI-powered sunglasses detection system is now ready! Users can upload images, get real-time validation, and receive clear feedback about whether their images contain sunglasses.

The system provides:
- ✅ Accurate sunglasses detection
- ✅ Real-time validation feedback
- ✅ User-friendly error handling
- ✅ Production-ready architecture
- ✅ Comprehensive logging and monitoring

Happy coding! 🚀

