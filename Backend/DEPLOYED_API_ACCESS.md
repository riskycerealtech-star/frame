# 🌐 Deployed API Access Guide

## Your Deployed API

**Base URL:** https://frame-750669515844.us-central1.run.app

---

## 📚 API Documentation URLs

### Swagger UI (Interactive API Testing)
- **Primary URL:** https://frame-750669515844.us-central1.run.app/docs/frame/swagger-ui/index.html
- **Alternative URL:** https://frame-750669515844.us-central1.run.app/docs (FastAPI default)

### ReDoc (Alternative Documentation)
- **URL:** https://frame-750669515844.us-central1.run.app/docs/frame/redoc/index.html

### OpenAPI JSON Schema
- **URL:** https://frame-750669515844.us-central1.run.app/docs/frame/openapi.json

---

## 🔐 Authentication Endpoints - How to Access

### 1. **User Signup** - Register New User

**Endpoint:** `POST /v1/user/signup`

**Full URL:** https://frame-750669515844.us-central1.run.app/v1/user/signup

**Using cURL:**
```bash
curl -X POST "https://frame-750669515844.us-central1.run.app/v1/user/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "+1234567890",
    "password": "SecurePass123!",
    "gender": "MALE",
    "location": "New York, USA",
    "occupation": "EMPLOYED",
    "sourceOfFunds": "SALARY",
    "timezone": "America/New_York"
  }'
```

**Using Swagger UI:**
1. Go to: https://frame-750669515844.us-central1.run.app/docs
2. Find **"1. Authentication"** section
3. Click on **POST /v1/user/signup**
4. Click **"Try it out"**
5. Fill in the request body
6. Click **"Execute"**

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

### 2. **User Signin** - Login and Get JWT Token

**Endpoint:** `POST /v1/user/signin/{userId}`

**Full URL:** https://frame-750669515844.us-central1.run.app/v1/user/signin/{userId}

**Note:** Replace `{userId}` with actual user ID (e.g., `1` or `USR123456`)

**Using cURL:**
```bash
curl -X POST "https://frame-750669515844.us-central1.run.app/v1/user/signin/1" \
  -H "Content-Type: application/json" \
  -d '{
    "credential": "user@example.com",
    "password": "SecurePass123!"
  }'
```

**Using Swagger UI:**
1. Go to: https://frame-750669515844.us-central1.run.app/docs
2. Find **POST /v1/user/signin/{userId}**
3. Click **"Try it out"**
4. Enter `userId` in path parameter (e.g., `1`)
5. Fill in credential and password
6. Click **"Execute"**

**Response:**
```json
{
  "fullName": "John Doe",
  "email": "user@example.com",
  "phoneNumber": "+1234567890",
  "statusCode": 200,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Important:** Save the `token` from this response for authenticated requests!

---

### 3. **Refresh Token** - Get New JWT Token

**Endpoint:** `POST /v1/user/refresh-token/{userId}`

**Full URL:** https://frame-750669515844.us-central1.run.app/v1/user/refresh-token/{userId}

**Using cURL:**
```bash
curl -X POST "https://frame-750669515844.us-central1.run.app/v1/user/refresh-token/1" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
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

---

### 4. **Check Token Status** - Verify Token Validity

**Endpoint:** `POST /v1/user/token-status/{userId}`

**Full URL:** https://frame-750669515844.us-central1.run.app/v1/user/token-status/{userId}

**Using cURL:**
```bash
curl -X POST "https://frame-750669515844.us-central1.run.app/v1/user/token-status/1" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
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

### 5. **Get All Users** - List All Users

**Endpoint:** `GET /v1/users/{userId}`

**Full URL:** https://frame-750669515844.us-central1.run.app/v1/users/{userId}

**Using cURL:**
```bash
curl -X GET "https://frame-750669515844.us-central1.run.app/v1/users/1"
```

**Response:**
```json
{
  "users": [
    {
      "userId": "1",
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

### 6. **Update User Account** - Update User Information

**Endpoint:** `PATCH /v1/user/account/{userId}`

**Full URL:** https://frame-750669515844.us-central1.run.app/v1/user/account/{userId}

**Using cURL:**
```bash
curl -X PATCH "https://frame-750669515844.us-central1.run.app/v1/user/account/1" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Smith",
    "location": "Los Angeles, USA",
    "password": "NewSecurePass123!"
  }'
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

## 🧪 Testing with Swagger UI (Easiest Method)

### Step-by-Step Guide:

1. **Open Swagger UI:**
   - Go to: https://frame-750669515844.us-central1.run.app/docs

2. **Find Authentication Endpoints:**
   - Scroll to **"1. Authentication"** section
   - You'll see all 6 authentication endpoints listed

3. **Test an Endpoint:**
   - Click on any endpoint (e.g., `POST /v1/user/signup`)
   - Click **"Try it out"** button
   - Fill in the required fields
   - Click **"Execute"**
   - View the response below

4. **Copy the Token:**
   - After signing in, copy the `token` from the response
   - Use this token for authenticated requests (if needed in future)

---

## 🔍 Health Check Endpoints

### Root Endpoint
**GET** https://frame-750669515844.us-central1.run.app/

```bash
curl https://frame-750669515844.us-central1.run.app/
```

### Health Check
**GET** https://frame-750669515844.us-central1.run.app/health

```bash
curl https://frame-750669515844.us-central1.run.app/health
```

---

## 📱 Using from Flutter/Mobile App

### Example API Call (Dart/Flutter):

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Signup Example
Future<void> signup() async {
  final url = Uri.parse('https://frame-750669515844.us-central1.run.app/v1/user/signup');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'user@example.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'phoneNumber': '+1234567890',
      'password': 'SecurePass123!',
      'gender': 'MALE',
      'location': 'New York, USA',
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('User created: ${data['userId']}');
  }
}

// Signin Example
Future<String?> signin(String email, String password) async {
  final url = Uri.parse('https://frame-750669515844.us-central1.run.app/v1/user/signin/1');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'credential': email,
      'password': password,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['token']; // Save this token for future requests
  }
  return null;
}
```

---

## 🔗 Quick Reference

| Endpoint | Method | Full URL |
|----------|--------|----------|
| Signup | POST | https://frame-750669515844.us-central1.run.app/v1/user/signup |
| Signin | POST | https://frame-750669515844.us-central1.run.app/v1/user/signin/{userId} |
| Refresh Token | POST | https://frame-750669515844.us-central1.run.app/v1/user/refresh-token/{userId} |
| Token Status | POST | https://frame-750669515844.us-central1.run.app/v1/user/token-status/{userId} |
| Get All Users | GET | https://frame-750669515844.us-central1.run.app/v1/users/{userId} |
| Update Account | PATCH | https://frame-750669515844.us-central1.run.app/v1/user/account/{userId} |
| Health Check | GET | https://frame-750669515844.us-central1.run.app/health |
| Swagger UI | GET | https://frame-750669515844.us-central1.run.app/docs |

---

## ✅ Quick Test

Test if your API is working:

```bash
# Health check
curl https://frame-750669515844.us-central1.run.app/health

# Root endpoint
curl https://frame-750669515844.us-central1.run.app/
```

Both should return JSON responses if the API is running correctly.

