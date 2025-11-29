/// API Constants and Configuration
/// Contains base URLs and API endpoints for the mobile app
library;

class ApiConstants {
  // API Base URL - Production
  static const String apiBaseUrl = 'https://glass-api-750669515844.us-central1.run.app';
  
  // API Base URL - Local Development (for testing)
  static const String apiBaseUrlLocal = 'http://localhost:8000';
  
  // API Version Prefix
  static const String apiV1Prefix = '/v1';
  
  // Full API Base URLs
  static String get apiV1BaseUrl => '$apiBaseUrl$apiV1Prefix';
  static String get apiV1BaseUrlLocal => '$apiBaseUrlLocal$apiV1Prefix';
  
  // Use local or production (set to true for local development)
  static const bool useLocal = false;
  
  // Get current base URL based on environment
  static String get currentBaseUrl => useLocal ? apiBaseUrlLocal : apiBaseUrl;
  static String get currentV1BaseUrl => useLocal ? apiV1BaseUrlLocal : apiV1BaseUrl;
}

/// API Endpoint paths (without base URL)
class ApiEndpoints {
  // Authentication endpoints
  static const String userSignup = '/v1/user/signup';
  static const String userSignin = '/v1/user/signin';
  static const String userSignout = '/v1/user/signout';
  static const String userRefreshToken = '/v1/user/refresh-token';
  static String userGet(String userId) => '/v1/user/$userId';
  static String userUpdate(String userId) => '/v1/user/$userId';
  static const String userList = '/v1/users';
  
  // AI Validation endpoints
  static const String aiValidateImage = '/v1/ai/validate-image';
  static const String aiDetectSunglasses = '/v1/ai/detect-sunglasses';
  
  // Health check
  static const String healthCheck = '/health';
  static const String apiDocs = '/docs';
  static const String apiRedoc = '/redoc';
}

/// Full API URLs helper class
class ApiUrls {
  /// Get full URL for an endpoint
  static String getEndpoint(String endpoint) {
    return '${ApiConstants.currentBaseUrl}$endpoint';
  }
  
  /// Get full URL for v1 endpoint
  static String getV1Endpoint(String endpoint) {
    return '${ApiConstants.currentV1BaseUrl}$endpoint';
  }
  
  // Authentication URLs
  static String get userSignup => getEndpoint(ApiEndpoints.userSignup);
  static String get userSignin => getEndpoint(ApiEndpoints.userSignin);
  static String get userSignout => getEndpoint(ApiEndpoints.userSignout);
  static String get userRefreshToken => getEndpoint(ApiEndpoints.userRefreshToken);
  static String userGet(String userId) => getEndpoint(ApiEndpoints.userGet(userId));
  static String userUpdate(String userId) => getEndpoint(ApiEndpoints.userUpdate(userId));
  static String get userList => getEndpoint(ApiEndpoints.userList);
  
  // AI Validation URLs
  static String get aiValidateImage => getEndpoint(ApiEndpoints.aiValidateImage);
  static String get aiDetectSunglasses => getEndpoint(ApiEndpoints.aiDetectSunglasses);
  
  // Health check URL
  static String get healthCheck => getEndpoint(ApiEndpoints.healthCheck);
  static String get apiDocs => getEndpoint(ApiEndpoints.apiDocs);
}



