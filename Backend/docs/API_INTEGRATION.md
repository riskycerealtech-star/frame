# API Integration Guide

## 🌐 API Base URL

**Production:**
```
https://glass-api-750669515844.us-central1.run.app
```

**Local Development:**
```
http://localhost:8000
```

---

## 📚 API Documentation

### Interactive Documentation (Swagger UI)

**Production:**
```
https://glass-api-750669515844.us-central1.run.app/api/v1/docs
```

**Local:**
```
http://localhost:8000/api/v1/docs
```

### OpenAPI Schema

**Production:**
```
https://glass-api-750669515844.us-central1.run.app/api/v1/openapi.json
```

**Local:**
```
http://localhost:8000/api/v1/openapi.json
```

---

## 🔌 Flutter Integration

### 1. Update API Base URL

Create or update `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Production
  static const String baseUrl = 'https://glass-api-750669515844.us-central1.run.app';
  
  // Local development (uncomment for local testing)
  // static const String baseUrl = 'http://localhost:8000';
  
  // API endpoints
  static const String apiVersion = '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  // Specific endpoints
  static String get health => '$baseUrl/health';
  static String get auth => '$apiBaseUrl/auth';
  static String get products => '$apiBaseUrl/products';
  static String get users => '$apiBaseUrl/users';
}
```

### 2. HTTP Client Setup

Create `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.apiBaseUrl}$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.apiBaseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.apiBaseUrl}$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
```

### 3. Authentication Service

Create `lib/services/auth_service.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class AuthService {
  final ApiService _api = ApiService();
  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response['access_token'] != null) {
      await _saveToken(response['access_token']);
      _api.setToken(response['access_token']);
    }

    return response;
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await _api.post('/auth/register', {
      'email': email,
      'password': password,
      'full_name': fullName,
    });

    if (response['access_token'] != null) {
      await _saveToken(response['access_token']);
      _api.setToken(response['access_token']);
    }

    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _api.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null) {
      _api.setToken(token);
      return true;
    }
    return false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
}
```

### 4. Add Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

Run:
```bash
flutter pub get
```

---

## 🧪 Testing API Integration

### Health Check

```dart
Future<void> checkHealth() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/health'),
    );
    print('Health: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### Test Authentication

```dart
final authService = AuthService();

// Register
await authService.register(
  'user@example.com',
  'password123',
  'John Doe',
);

// Login
await authService.login(
  'user@example.com',
  'password123',
);
```

---

## 🔒 CORS Configuration

If you're testing from a web browser, ensure CORS is configured:

Update `app/main.py`:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # Web app
        "http://localhost:8080",  # Alternative port
        # Add your Flutter web app URL when deployed
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 📱 Mobile App Configuration

### Android Network Security

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

For production, use HTTPS only and remove `usesCleartextTraffic`.

### iOS Network Security

Update `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

For production, configure proper App Transport Security.

---

## 🔍 Error Handling

### API Error Response Format

```json
{
  "detail": "Error message here"
}
```

### Error Handling in Flutter

```dart
try {
  final response = await ApiService().get('/endpoint');
  // Handle success
} on Exception catch (e) {
  // Handle error
  print('API Error: $e');
}
```

---

## 📊 Monitoring

### Check API Status

```bash
curl https://glass-api-750669515844.us-central1.run.app/health
```

### View Logs

```bash
gcloud run services logs read glass-api \
    --region us-central1 \
    --limit 50
```

---

## 🚀 Best Practices

1. **Use Environment Variables:**
   - Store API URL in environment config
   - Different URLs for dev/staging/production

2. **Token Management:**
   - Store tokens securely
   - Refresh tokens before expiry
   - Clear tokens on logout

3. **Error Handling:**
   - Handle network errors gracefully
   - Show user-friendly error messages
   - Log errors for debugging

4. **Rate Limiting:**
   - Implement request throttling
   - Handle 429 (Too Many Requests) responses

5. **Caching:**
   - Cache static data
   - Use appropriate cache headers

---

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [REST API Best Practices](https://restfulapi.net/)

---

**Your API is ready for integration! 🎉**



