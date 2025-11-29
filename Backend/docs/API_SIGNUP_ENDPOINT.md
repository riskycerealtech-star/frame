# Signup API Endpoint Documentation

## 📍 Endpoint

**URL:** `POST /v1/user/signup`

**Full URL (Production):** `https://glass-api-750669515844.us-central1.run.app/v1/user/signup`

**Full URL (Local):** `http://localhost:8000/v1/user/signup`

---

## 📋 Request Parameters

### Required Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `email` | `string` (EmailStr) | Valid email address - must be unique | `"john.doe@example.com"` |
| `firstName` | `string` | User's first name | `"John"` |
| `lastName` | `string` | User's last name | `"Doe"` |
| `phoneNumber` | `string` | Phone number with country code - must be unique | `"+1234567890"` |
| `password` | `string` | Password (minimum 6 characters) | `"SecurePass123!"` |
| `gender` | `string` | User gender | `"MALE"`, `"FEMALE"`, `"OTHER"` |
| `location` | `string` | User location (city, state, country) | `"New York, USA"` |

### Optional Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `occupation` | `string` | User occupation | `"EMPLOYED"`, `"UNEMPLOYED"`, `"STUDENT"`, `"RETIRED"`, `"SELF_EMPLOYED"` |
| `sourceOfFunds` | `string` | Source of income | `"SALARY"`, `"BUSINESS"`, `"INVESTMENT"`, `"GIFT"`, `"OTHER"` |
| `timezone` | `string` | User's timezone | `"America/New_York"`, `"Europe/London"`, `"Asia/Tokyo"` |
| `additionalProperties` | `object` | Additional user properties as key-value pairs | `{"favoriteBrand": "Ray-Ban"}` |

---

## ✅ Validation Rules

1. **Email:**
   - Must be valid email format
   - Must be unique in database
   - Example: `user@example.com`

2. **Phone Number:**
   - Must start with `+` (country code)
   - Must be unique in database
   - Example: `+1234567890`

3. **Password:**
   - Minimum 6 characters
   - No maximum length specified

4. **Occupation** (if provided):
   - Must be one of: `EMPLOYED`, `UNEMPLOYED`, `STUDENT`, `RETIRED`, `SELF_EMPLOYED`

5. **Source of Funds** (if provided):
   - Must be one of: `SALARY`, `BUSINESS`, `INVESTMENT`, `GIFT`, `OTHER`

---

## 📤 Request Examples

### Minimal Request (Required Fields Only)

```json
{
  "email": "john.doe@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890",
  "password": "SecurePass123!",
  "gender": "MALE",
  "location": "New York, USA"
}
```

### Complete Request (All Fields)

```json
{
  "email": "john.doe@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+1234567890",
  "password": "SecurePass123!",
  "gender": "MALE",
  "location": "New York, USA",
  "occupation": "EMPLOYED",
  "sourceOfFunds": "SALARY",
  "timezone": "America/New_York",
  "additionalProperties": {
    "favoriteBrand": "Ray-Ban"
  }
}
```

---

## 📥 Response

### Success Response (200 OK)

```json
{
  "status": "CREATED",
  "email": "john.doe@example.com",
  "userId": "USR123456",
  "phoneNumber": "+1234567890",
  "createdOn": "2024-01-15T15:30:00-05:00",
  "updatedOn": "2024-01-15T15:30:00-05:00"
}
```

**Response Fields:**
- `status`: Status of the operation (usually "CREATED")
- `email`: Registered email address
- `userId`: Unique user ID (format: USR + 6 alphanumeric characters)
- `phoneNumber`: Registered phone number
- `createdOn`: Account creation timestamp (in user's timezone if provided, otherwise UTC)
- `updatedOn`: Last update timestamp (in user's timezone if provided, otherwise UTC)

---

## ❌ Error Responses

### 400 Bad Request - Invalid Input

**Invalid Email:**
```json
{
  "detail": "Invalid email format"
}
```

**Password Too Short:**
```json
{
  "detail": "Password must be at least 6 characters long"
}
```

**Invalid Phone Format:**
```json
{
  "detail": "Phone number must include country code (e.g., +1234567890)"
}
```

**Invalid Occupation:**
```json
{
  "detail": "Occupation must be one of: EMPLOYED, UNEMPLOYED, STUDENT, RETIRED, SELF_EMPLOYED"
}
```

**Invalid Source of Funds:**
```json
{
  "detail": "Source of funds must be one of: SALARY, BUSINESS, INVESTMENT, GIFT, OTHER"
}
```

### 409 Conflict - Duplicate Entry

**Email Already Exists:**
```json
{
  "detail": "User with this email already exists"
}
```

**Phone Number Already Exists:**
```json
{
  "detail": "User with this phone number already exists"
}
```

### 500 Internal Server Error

```json
{
  "detail": "Internal server error during signup"
}
```

---

## 🧪 cURL Examples

### Minimal Request

```bash
curl -X POST "https://glass-api-750669515844.us-central1.run.app/v1/user/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "+1234567890",
    "password": "SecurePass123!",
    "gender": "MALE",
    "location": "New York, USA"
  }'
```

### Complete Request

```bash
curl -X POST "https://glass-api-750669515844.us-central1.run.app/v1/user/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
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

---

## 📱 Flutter Integration Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> signup({
  required String email,
  required String firstName,
  required String lastName,
  required String phoneNumber,
  required String password,
  required String gender,
  required String location,
  String? occupation,
  String? sourceOfFunds,
  String? timezone,
}) async {
  final url = Uri.parse('https://glass-api-750669515844.us-central1.run.app/v1/user/signup');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'password': password,
      'gender': gender,
      'location': location,
      if (occupation != null) 'occupation': occupation,
      if (sourceOfFunds != null) 'sourceOfFunds': sourceOfFunds,
      if (timezone != null) 'timezone': timezone,
    }),
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Signup failed: ${response.body}');
  }
}

// Usage
final result = await signup(
  email: 'john.doe@example.com',
  firstName: 'John',
  lastName: 'Doe',
  phoneNumber: '+1234567890',
  password: 'SecurePass123!',
  gender: 'MALE',
  location: 'New York, USA',
);
print('User ID: ${result['userId']}');
```

---

## 🔗 Related Endpoints

- **Sign In:** `POST /v1/user/signin`
- **Get User:** `GET /v1/user/{userId}`
- **Update User:** `PUT /v1/user/{userId}`

---

## 📚 API Documentation

- **Swagger UI:** https://glass-api-750669515844.us-central1.run.app/docs/frame/swagger-ui/index.html
- **ReDoc:** https://glass-api-750669515844.us-central1.run.app/docs/frame/redoc/index.html
- **OpenAPI JSON:** https://glass-api-750669515844.us-central1.run.app/docs/frame/openapi.json

---

## ⚠️ Important Notes

1. **Phone Number Format:** Must start with `+` followed by country code and number
2. **Email Uniqueness:** Email must be unique - duplicate emails will return 409 error
3. **Phone Uniqueness:** Phone number must be unique - duplicate phones will return 409 error
4. **Password Security:** Password is hashed before storage
5. **Timezone:** If timezone is provided, timestamps in response will be in that timezone
6. **Gender Values:** Common values are `MALE`, `FEMALE`, `OTHER` but any string is accepted

---

**API Endpoint:** `POST /v1/user/signup`



