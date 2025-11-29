# Mobile Integration Files

## 📱 Flutter API Client

The `flutter-api-client.dart` file is a template that needs to be copied to your Flutter project.

### Setup Instructions

1. **Copy the file to your Flutter project:**
   ```bash
   cp flutter-api-client.dart /path/to/your/flutter/project/lib/services/api_client.dart
   ```

2. **Add dependencies to `pubspec.yaml`:**
   ```yaml
   dependencies:
     http: ^1.1.0
     shared_preferences: ^2.2.2
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **The linter errors will disappear** once the file is in your Flutter project with dependencies installed.

### Note

The linter errors you see in this directory are **expected and normal**. They occur because:
- This file is not in a Flutter project context
- The required packages (`http`, `shared_preferences`) are not installed here
- Once copied to a Flutter project with dependencies, all errors will resolve

---

## 📱 React Native API Client

The `react-native-api.js` file can be used directly in React Native projects.

### Setup Instructions

1. **Install dependencies:**
   ```bash
   npm install @react-native-async-storage/async-storage
   # or
   yarn add @react-native-async-storage/async-storage
   ```

2. **Copy the file to your project:**
   ```bash
   cp react-native-api.js /path/to/your/react-native/project/src/services/api.js
   ```

3. **Import and use:**
   ```javascript
   import { authService, productService } from './services/api';
   ```

---

## 📚 API Documentation

See `api-endpoints.json` for complete API endpoint documentation.

See `INTEGRATION-GUIDE.md` for detailed integration instructions.



