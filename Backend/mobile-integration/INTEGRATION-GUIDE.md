# Mobile App Integration Guide

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

## 📱 Flutter Integration

### 1. Add Dependencies

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

### 2. Copy API Client

Copy `flutter-api-client.dart` to your Flutter project:
```bash
cp mobile-integration/flutter-api-client.dart lib/services/api_client.dart
```

### 3. Initialize API Service

In your app initialization:

```dart
import 'package:your_app/services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  await ApiService().initialize();
  
  runApp(MyApp());
}
```

### 4. Usage Examples

#### Authentication

```dart
final authService = AuthService();

// Login
final loginResponse = await authService.login(
  'user@example.com',
  'password123',
);

if (loginResponse.success) {
  print('Logged in successfully!');
  // Navigate to home
} else {
  print('Error: ${loginResponse.error}');
}

// Register
final registerResponse = await authService.register(
  email: 'newuser@example.com',
  password: 'password123',
  fullName: 'John Doe',
);

// Check if logged in
final isLoggedIn = await authService.isLoggedIn();

// Logout
await authService.logout();
```

#### Products

```dart
final productService = ProductService();

// Get all products
final productsResponse = await productService.getProducts(limit: 20);

if (productsResponse.success) {
  final products = productsResponse.data!['items'];
  // Display products
}

// Get single product
final productResponse = await productService.getProduct(1);

// Create product
final createResponse = await productService.createProduct({
  'name': 'New Sunglasses',
  'description': 'Description here',
  'price': 99.99,
  'category': 'Aviator',
  'brand': 'GlassBrand',
});
```

#### Health Check

```dart
final apiService = ApiService();
final isHealthy = await apiService.checkHealth();

if (isHealthy) {
  print('API is healthy!');
} else {
  print('API is not responding');
}
```

---

## 📱 React Native Integration

### 1. Install Dependencies

```bash
npm install @react-native-async-storage/async-storage
# or
yarn add @react-native-async-storage/async-storage
```

### 2. Copy API Client

Copy `react-native-api.js` to your React Native project:
```bash
cp mobile-integration/react-native-api.js src/services/api.js
```

### 3. Usage Examples

```javascript
import { authService, productService, apiService } from './services/api';

// Login
const loginResponse = await authService.login('user@example.com', 'password123');

if (loginResponse.success) {
  console.log('Logged in!');
} else {
  console.error('Error:', loginResponse.error);
}

// Get products
const productsResponse = await productService.getProducts(20, 0);

if (productsResponse.success) {
  const products = productsResponse.data.items;
  // Display products
}

// Health check
const isHealthy = await apiService.checkHealth();
```

---

## 🔐 Authentication Flow

### 1. Login Flow

```
User enters credentials
    ↓
POST /api/v1/auth/login
    ↓
Receive access_token
    ↓
Store token securely
    ↓
Add token to all requests
```

### 2. Token Management

- **Store token**: Use secure storage (SharedPreferences/AsyncStorage)
- **Add to requests**: Include in `Authorization: Bearer {token}` header
- **Handle expiration**: Implement token refresh or re-login
- **Clear on logout**: Remove token from storage

### 3. Error Handling

```dart
// Flutter example
try {
  final response = await apiService.get('/endpoint');
  if (response.success) {
    // Handle success
  } else {
    // Handle error
    if (response.error?.contains('Unauthorized')) {
      // Redirect to login
    }
  }
} catch (e) {
  // Handle network error
}
```

---

## 📊 API Endpoints Reference

See `api-endpoints.json` for complete endpoint documentation.

### Key Endpoints:

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/health` | GET | No | Health check |
| `/api/v1/auth/login` | POST | No | User login |
| `/api/v1/auth/register` | POST | No | User registration |
| `/api/v1/users/me` | GET | Yes | Get current user |
| `/api/v1/products` | GET | No | List products |
| `/api/v1/products/{id}` | GET | No | Get product |
| `/api/v1/products` | POST | Yes | Create product |
| `/api/v1/products/{id}` | PUT | Yes | Update product |
| `/api/v1/products/{id}` | DELETE | Yes | Delete product |

---

## 🧪 Testing

### Test API Connection

```dart
// Flutter
final apiService = ApiService();
final isHealthy = await apiService.checkHealth();
print('API Health: $isHealthy');
```

```javascript
// React Native
const isHealthy = await apiService.checkHealth();
console.log('API Health:', isHealthy);
```

### Test Authentication

```dart
// Flutter
final authService = AuthService();
final response = await authService.login('test@example.com', 'password');
print('Login: ${response.success}');
```

---

## 🔧 Configuration

### Switch Between Environments

**Flutter:**
```dart
// In flutter-api-client.dart
class ApiConfig {
  // Production
  static const String baseUrl = 'https://glass-api-750669515844.us-central1.run.app';
  
  // Local (for testing)
  // static const String baseUrl = 'http://localhost:8000';
}
```

**React Native:**
```javascript
// In react-native-api.js
const API_CONFIG = {
  baseUrl: 'https://glass-api-750669515844.us-central1.run.app',
  // baseUrl: 'http://localhost:8000', // Local
};
```

---

## 🐛 Troubleshooting

### Network Errors

1. **Check internet connection**
2. **Verify API URL is correct**
3. **Check if API is running**: Visit `/health` endpoint
4. **Check CORS settings** (for web apps)

### Authentication Errors

1. **Token expired**: Implement token refresh
2. **Invalid token**: Clear token and re-login
3. **401 Unauthorized**: Check token is being sent correctly

### Common Issues

**Issue**: "Network error"
- **Solution**: Check API URL and internet connection

**Issue**: "Unauthorized"
- **Solution**: Verify token is valid and being sent

**Issue**: "CORS error" (web apps)
- **Solution**: Update CORS settings in FastAPI app

---

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [React Native Fetch](https://reactnative.dev/docs/network)
- [API Documentation](https://glass-api-750669515844.us-central1.run.app/api/v1/docs)

---

## ✅ Integration Checklist

- [ ] API client copied to project
- [ ] Dependencies installed
- [ ] API service initialized
- [ ] Authentication working
- [ ] Products API working
- [ ] Error handling implemented
- [ ] Token storage working
- [ ] Health check passing
- [ ] Tested on device/emulator

---

**Your mobile app is ready to integrate! 🎉**



