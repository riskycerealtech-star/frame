# 📚 Frame API - Complete Endpoint List

## Base URL
- **Local**: http://localhost:8080
- **Production**: https://glass-api-xxxxx-uc.a.run.app

## Swagger Documentation
- **Swagger UI**: `/docs/frame/swagger-ui/index.html`
- **ReDoc**: `/docs/frame/redoc/index.html`
- **OpenAPI JSON**: `/docs/frame/openapi.json`

---

## 🔐 1. Authentication Endpoints

### 1.1 User Signup
**POST** `/v1/user/signup`

Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890",
  "password": "SecurePass123!",
  "gender": "MALE",
  "location": "New York, USA",
  "occupation": "EMPLOYED",
  "sourceOfFunds": "SALARY",
  "timezone": "America/New_York",
  "additionalProperties": {}
}
```

**Response:**
```json
{
  "status": "CREATED",
  "email": "user@example.com",
  "userId": "USR123456",
  "phoneNumber": "+1234567890",
  "createdOn": "2024-01-15T10:30:00-05:00",
  "updatedOn": "2024-01-15T10:30:00-05:00"
}
```

---

### 1.2 User Signin
**POST** `/v1/user/signin/{userId}`

Authenticate user and get JWT token.

**Path Parameters:**
- `userId` (string): User ID

**Request Body:**
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

---

### 1.3 Refresh Token
**POST** `/v1/user/refresh-token/{userId}`

Generate a new access token using existing token.

**Path Parameters:**
- `userId` (string): User ID

**Request Body:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response:**
```json
{
  "status": "SUCCESS",
  "message": "Token refreshed successfully",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "statusCode": 200,
  "expiresAt": "2024-01-15T11:00:00Z"
}
```

---

### 1.4 Check Token Status
**POST** `/v1/user/token-status/{userId}`

Check if JWT token is valid and when it expires.

**Path Parameters:**
- `userId` (string): User ID

**Request Body:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
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
  "message": "Token is valid"
}
```

---

### 1.5 Get All Users
**GET** `/v1/users/{userId}`

Retrieve list of all users.

**Path Parameters:**
- `userId` (string): User ID for authorization

**Response:**
```json
{
  "users": [
    {
      "userId": "USR123456",
      "email": "user@example.com",
      "fullName": "John Doe",
      "phoneNumber": "+1234567890",
      "createdOn": "2024-01-15T10:30:00Z",
      "updatedOn": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1
}
```

---

### 1.6 Update User Account
**PATCH** `/v1/user/account/{userId}`

Update user information (firstName, lastName, location, password).

**Path Parameters:**
- `userId` (string): User ID

**Request Body:**
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

---

## 🤖 2. AI Validation Endpoints

### 2.1 Validate Sunglasses (File Upload)
**POST** `/validate-sunglasses`

Upload an image file to detect if it contains sunglasses.

**Request:**
- Content-Type: `multipart/form-data`
- Body: File upload (image file)

**Supported Formats:**
- JPEG (.jpg, .jpeg)
- PNG (.png)
- WebP (.webp)

**File Size Limit:** 50MB

**Response (Success):**
```json
{
  "status": "accepted",
  "confidence": 0.95,
  "message": "Sunglasses detected with 95.0% confidence",
  "details": "Detected: sunglasses with 95.0% confidence",
  "analysis": {
    "sunglasses_detected": true,
    "confidence": 0.95,
    "objects": [
      {
        "object": "Sunglasses",
        "confidence": 0.95,
        "bounding_box": {
          "x": 0.25,
          "y": 0.3,
          "width": 0.5,
          "height": 0.2
        }
      }
    ],
    "labels": [
      {
        "label": "Sunglasses",
        "confidence": 0.95
      }
    ],
    "analysis_method": "hugging_face_resnet50"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

**Response (Rejected):**
```json
{
  "status": "rejected",
  "confidence": 0.0,
  "message": "No sunglasses found in the image",
  "details": "Please upload an image containing sunglasses (dark/tinted lenses)",
  "analysis": {
    "sunglasses_detected": false,
    "confidence": 0.0,
    "objects": [],
    "labels": [
      {
        "label": "No sunglasses detected",
        "confidence": 0.0
      }
    ],
    "analysis_method": "hugging_face_resnet50"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

### 2.2 Validate Sunglasses (Base64)
**POST** `/validate-sunglasses-base64`

Submit an image as base64-encoded string for sunglasses detection.

**Request Body:**
```json
{
  "image": "iVBORw0KGgoAAAANSUhEUgAA..."
}
```

**Response:** Same as `/validate-sunglasses` endpoint

---

## 🔍 3. Utility Endpoints

### 3.1 Root Endpoint
**GET** `/`

Simple health check.

**Response:**
```json
{
  "message": "Sunglasses Detection API is running",
  "status": "healthy"
}
```

---

### 3.2 Health Check
**GET** `/health`

Detailed health information.

**Response:**
```json
{
  "status": "healthy",
  "vision_api": "connected",
  "version": "1.0.0"
}
```

---

### 3.3 Swagger Login (Internal)
**POST** `/swagger-login`

Authenticate to access Swagger documentation (if enabled).

**Request Body:**
```json
{
  "clientId": "frame_api_admin",
  "clientSecret": "frame_api_secret_2024"
}
```

---

## 📊 Summary Table

| Method | Endpoint | Description | Tag |
|--------|----------|-------------|-----|
| GET | `/` | Root/Health check | Authentication |
| GET | `/health` | Detailed health check | Authentication |
| POST | `/swagger-login` | Swagger authentication | - |
| POST | `/v1/user/signup` | User registration | Authentication |
| POST | `/v1/user/signin/{userId}` | User login | Authentication |
| POST | `/v1/user/refresh-token/{userId}` | Refresh JWT token | Authentication |
| POST | `/v1/user/token-status/{userId}` | Check token status | Authentication |
| GET | `/v1/users/{userId}` | Get all users | Authentication |
| PATCH | `/v1/user/account/{userId}` | Update user account | Authentication |
| POST | `/validate-sunglasses` | Validate sunglasses (file) | AI Validation |
| POST | `/validate-sunglasses-base64` | Validate sunglasses (base64) | AI Validation |

---

## 🔗 Quick Links

- **Swagger UI**: http://localhost:8080/docs/frame/swagger-ui/index.html
- **ReDoc**: http://localhost:8080/docs/frame/redoc/index.html
- **OpenAPI JSON**: http://localhost:8080/docs/frame/openapi.json

---

## 📝 Notes

1. All timestamps are in ISO 8601 format
2. JWT tokens expire after 30 minutes
3. Token refresh is recommended when `shouldRefresh: true` in token status
4. Image validation supports multiple analysis methods:
   - Hugging Face AI Model (primary)
   - Google Cloud Vision API (fallback)
   - Mock mode (development)
5. Minimum confidence threshold for sunglasses detection: 10%

