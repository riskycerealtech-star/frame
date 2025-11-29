// Flutter API Client for Frame Backend API
// Production URL: https://glass-api-750669515844.us-central1.run.app
//
// IMPORTANT: This file must be placed in a Flutter project with the following dependencies:
// Add to pubspec.yaml:
//   dependencies:
//     http: ^1.1.0
//     shared_preferences: ^2.2.2
//
// Then run: flutter pub get
//
// The linter errors here are expected - they will resolve once the file is in a Flutter project.

// ignore_for_file: uri_does_not_exist, undefined_identifier

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Production API URL
  static const String baseUrl = 'https://glass-api-750669515844.us-central1.run.app';
  
  // Local development (uncomment for local testing)
  // static const String baseUrl = 'http://localhost:8000';
  
  static const String apiVersion = '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  // Endpoints
  static String get health => '$baseUrl/health';
  static String get auth => '$apiBaseUrl/auth';
  static String get products => '$apiBaseUrl/products';
  static String get users => '$apiBaseUrl/users';
  static String get orders => '$apiBaseUrl/orders';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  static const String _tokenKey = 'auth_token';

  // Initialize token from storage
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
    } catch (e) {
      // If storage fails, token remains null
      _token = null;
    }
  }

  // Set authentication token
  void setToken(String token) {
    if (token.isEmpty) {
      throw ArgumentError('Token cannot be empty');
    }
    _token = token;
    _saveToken(token); // Fire and forget - async operation
  }

  // Clear authentication token
  Future<void> clearToken() async {
    _token = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      // Ignore errors when clearing token
    }
  }
  
  // Check if token exists
  bool get hasToken => _token != null && _token!.isNotEmpty;

  // Save token to storage
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      // Log error but don't fail - token is still set in memory
      print('Warning: Failed to save token to storage: $e');
    }
  }

  // Get headers with authentication
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // GET request
  Future<ApiResponse> get(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );
      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error('Request timeout. Please check your connection.');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // POST request
  Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );
      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error('Request timeout. Please check your connection.');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // PUT request
  Future<ApiResponse> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );
      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error('Request timeout. Please check your connection.');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // DELETE request
  Future<ApiResponse> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}$endpoint');
      final response = await http.delete(
        uri,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );
      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error('Request timeout. Please check your connection.');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      try {
        if (response.body.isEmpty) {
          return ApiResponse.success({'message': 'Success'});
        }
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(data);
      } catch (e) {
        // If JSON decode fails, return the raw body as message
        return ApiResponse.success({'message': response.body});
      }
    } else if (statusCode == 401) {
      // Unauthorized - clear token (async, but don't wait)
      clearToken().catchError((e) {
        // Ignore errors when clearing token
      });
      return ApiResponse.error('Unauthorized. Please login again.');
    } else {
      try {
        if (response.body.isEmpty) {
          return ApiResponse.error('Request failed with status $statusCode');
        }
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.error(error['detail'] ?? error['message'] ?? 'Request failed');
      } catch (e) {
        return ApiResponse.error('Request failed with status $statusCode');
      }
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.health),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Health check timeout', const Duration(seconds: 10));
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// API Response wrapper
class ApiResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;

  ApiResponse.success(this.data)
      : success = true,
        error = null;

  ApiResponse.error(this.error)
      : success = false,
        data = null;
}

// Authentication Service
class AuthService {
  final ApiService _api = ApiService();

  // Login
  Future<ApiResponse> login(String email, String password) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.success && response.data != null) {
      final token = response.data!['access_token'];
      if (token != null) {
        _api.setToken(token);
      }
    }

    return response;
  }

  // Register
  Future<ApiResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _api.post('/auth/register', {
      'email': email,
      'password': password,
      'full_name': fullName,
    });

    if (response.success && response.data != null) {
      final token = response.data!['access_token'];
      if (token != null) {
        _api.setToken(token);
      }
    }

    return response;
  }

  // Logout
  Future<void> logout() async {
    await _api.clearToken();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    await _api.initialize();
    return _api.hasToken;
  }

  // Get current user
  Future<ApiResponse> getCurrentUser() async {
    return await _api.get('/users/me');
  }
}

// Product Service
class ProductService {
  final ApiService _api = ApiService();

  // Get all products
  Future<ApiResponse> getProducts({int? limit, int? offset}) async {
    String endpoint = '/products';
    if (limit != null || offset != null) {
      final params = <String>[];
      if (limit != null) params.add('limit=$limit');
      if (offset != null) params.add('offset=$offset');
      endpoint += '?${params.join('&')}';
    }
    return await _api.get(endpoint);
  }

  // Get product by ID
  Future<ApiResponse> getProduct(int id) async {
    return await _api.get('/products/$id');
  }

  // Create product
  Future<ApiResponse> createProduct(Map<String, dynamic> productData) async {
    return await _api.post('/products', productData);
  }

  // Update product
  Future<ApiResponse> updateProduct(int id, Map<String, dynamic> productData) async {
    return await _api.put('/products/$id', productData);
  }

  // Delete product
  Future<ApiResponse> deleteProduct(int id) async {
    return await _api.delete('/products/$id');
  }
}

