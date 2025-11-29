import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

/// AI-based sunglasses validation service
/// Integrates with backend API for real-time sunglasses detection
class SunglassesValidationService {
  static String _baseUrl = 'http://localhost:8000'; // Change to your backend URL
  static const String _validateEndpoint = '/validate-sunglasses';
  static const String _validateBase64Endpoint = '/validate-sunglasses-base64';
  
  // Timeout settings
  static const Duration _timeout = Duration(seconds: 30); // Increased for AI processing
  static const Duration _connectionTimeout = Duration(seconds: 10);

  /// Updates the base URL for the API
  /// Useful for switching between development and production environments
  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Gets the current base URL
  static String get baseUrl => _baseUrl;

  /// Validates if an image contains sunglasses using file upload
  /// 
  /// [imageFile] - The image file to validate
  /// Returns [SunglassesValidationResult] with detection results
  static Future<SunglassesValidationResult> validateSunglassesFromFile(
    File imageFile,
  ) async {
    try {
      // Validate file exists and is readable
      if (!await imageFile.exists()) {
        throw SunglassesValidationException(
          'Image file does not exist',
          type: ValidationErrorType.fileNotFound,
        );
      }

      // Check file size (max 50MB)
      final fileSize = await imageFile.length();
      const maxSize = 50 * 1024 * 1024; // 50MB
      if (fileSize > maxSize) {
        throw SunglassesValidationException(
          'Image file is too large. Maximum size is 50MB',
          type: ValidationErrorType.fileTooLarge,
        );
      }

      // Check if file is empty
      if (fileSize == 0) {
        throw SunglassesValidationException(
          'Image file is empty',
          type: ValidationErrorType.badRequest,
        );
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_validateEndpoint'),
      );

      // Add image file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: 'sunglasses_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': 'Flutter-Sunglasses-App/1.0',
      });

      // Send request with timeout
      print('🌐 SENDING REQUEST - URL: ${request.url}');
      print('🌐 REQUEST HEADERS - ${request.headers}');
      print('🌐 FILES COUNT - ${request.files.length}');
      
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      print('🌐 RESPONSE STATUS - ${response.statusCode}');
      print('🌐 RESPONSE BODY - ${response.body}');

      return _handleResponse(response);

    } on TimeoutException {
      throw SunglassesValidationException(
        'AI processing is taking longer than expected. Please try again.',
        type: ValidationErrorType.timeout,
      );
    } on SocketException {
      throw SunglassesValidationException(
        'Network connection failed. Please check your internet connection.',
        type: ValidationErrorType.networkError,
      );
    } catch (e) {
      if (e is SunglassesValidationException) {
        rethrow;
      }
      throw SunglassesValidationException(
        'Unexpected error during validation: ${e.toString()}',
        type: ValidationErrorType.unknown,
      );
    }
  }

  /// Validates if an image contains sunglasses using base64 encoding
  /// 
  /// [imageBytes] - The image bytes to validate
  /// Returns [SunglassesValidationResult] with detection results
  static Future<SunglassesValidationResult> validateSunglassesFromBytes(
    Uint8List imageBytes,
  ) async {
    try {
      // Check if bytes are empty
      if (imageBytes.isEmpty) {
        throw SunglassesValidationException(
          'Image data is empty',
          type: ValidationErrorType.badRequest,
        );
      }

      // Check file size (max 50MB)
      const maxSize = 50 * 1024 * 1024; // 50MB
      if (imageBytes.length > maxSize) {
        throw SunglassesValidationException(
          'Image file is too large. Maximum size is 50MB',
          type: ValidationErrorType.fileTooLarge,
        );
      }

      // Encode image to base64
      final base64Image = base64Encode(imageBytes);

      // Prepare request body
      final requestBody = jsonEncode({
        'image': base64Image,
      });

      // Send request
      final response = await http
          .post(
            Uri.parse('$_baseUrl$_validateBase64Endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'Flutter-Sunglasses-App/1.0',
            },
            body: requestBody,
          )
          .timeout(_timeout);

      return _handleResponse(response);

    } on TimeoutException {
      throw SunglassesValidationException(
        'AI processing is taking longer than expected. Please try again.',
        type: ValidationErrorType.timeout,
      );
    } on SocketException {
      throw SunglassesValidationException(
        'Network connection failed. Please check your internet connection.',
        type: ValidationErrorType.networkError,
      );
    } catch (e) {
      if (e is SunglassesValidationException) {
        rethrow;
      }
      throw SunglassesValidationException(
        'Unexpected error during validation: ${e.toString()}',
        type: ValidationErrorType.unknown,
      );
    }
  }

  /// Handles API response and converts to validation result
  static SunglassesValidationResult _handleResponse(http.Response response) {
    // Check HTTP status code
    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return SunglassesValidationResult.fromJson(jsonResponse);
      } catch (e) {
        throw SunglassesValidationException(
          'Invalid response format from server',
          type: ValidationErrorType.invalidResponse,
        );
      }
    } else if (response.statusCode == 422) {
      // 422 Unprocessable Entity - Validation failed (no sunglasses or low confidence)
      try {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return SunglassesValidationResult.fromJson(jsonResponse);
      } catch (e) {
        throw SunglassesValidationException(
          'Invalid response format from server',
          type: ValidationErrorType.invalidResponse,
        );
      }
    } else if (response.statusCode == 400) {
      try {
        final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final message = errorResponse['detail'] ?? 'Bad request';
        throw SunglassesValidationException(
          message,
          type: ValidationErrorType.badRequest,
        );
      } catch (e) {
        if (e is SunglassesValidationException) {
          rethrow;
        }
        throw SunglassesValidationException(
          'Bad request: ${response.body}',
          type: ValidationErrorType.badRequest,
        );
      }
    } else if (response.statusCode == 413) {
      throw SunglassesValidationException(
        'Image file is too large',
        type: ValidationErrorType.fileTooLarge,
      );
    } else if (response.statusCode == 500) {
      throw SunglassesValidationException(
        'Server error occurred. Please try again later.',
        type: ValidationErrorType.serverError,
      );
    } else {
      throw SunglassesValidationException(
        'Unexpected server response: ${response.statusCode}',
        type: ValidationErrorType.serverError,
      );
    }
  }

  /// Checks if the backend API is available
  static Future<bool> isApiAvailable() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'Flutter-Sunglasses-App/1.0',
            },
          )
          .timeout(_connectionTimeout);

      return response.statusCode == 200;
    } on TimeoutException {
      debugPrint('API health check timed out');
      return false;
    } on SocketException {
      debugPrint('API health check network error');
      return false;
    } catch (e) {
      debugPrint('API health check failed: $e');
      return false;
    }
  }

  /// Gets API status information
  static Future<Map<String, dynamic>?> getApiStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'Flutter-Sunglasses-App/1.0',
            },
          )
          .timeout(_connectionTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } on TimeoutException {
      debugPrint('API status check timed out');
      return null;
    } on SocketException {
      debugPrint('API status check network error');
      return null;
    } catch (e) {
      debugPrint('API status check failed: $e');
      return null;
    }
  }
}

/// Result of sunglasses validation
class SunglassesValidationResult {
  final bool isAccepted;
  final double confidence;
  final String message;
  final String details;
  final Map<String, dynamic> analysis;
  final String timestamp;

  const SunglassesValidationResult({
    required this.isAccepted,
    required this.confidence,
    required this.message,
    required this.details,
    required this.analysis,
    required this.timestamp,
  });

  factory SunglassesValidationResult.fromJson(Map<String, dynamic> json) {
    return SunglassesValidationResult(
      isAccepted: json['status'] == 'accepted',
      confidence: (json['confidence'] as num).toDouble(),
      message: json['message'] as String,
      details: json['details'] as String,
      analysis: json['analysis'] as Map<String, dynamic>,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  /// Returns user-friendly success message
  String get successMessage {
    if (isAccepted) {
      return 'Sunglasses verified! Submitting...';
    } else {
      return 'Please upload an image with sunglasses (dark lenses required)';
    }
  }

  /// Returns user-friendly error message
  String get errorMessage {
    if (confidence < 0.5) {
      return 'No sunglasses found in the image';
    } else if (confidence < 0.8) {
      return 'Regular glasses detected. Please use sunglasses.';
    } else {
      return 'Image quality too low. Please try a clearer image.';
    }
  }

  @override
  String toString() {
    return 'SunglassesValidationResult(isAccepted: $isAccepted, confidence: $confidence, message: $message)';
  }
}

/// Exception thrown during sunglasses validation
class SunglassesValidationException implements Exception {
  final String message;
  final ValidationErrorType type;

  const SunglassesValidationException(this.message, {required this.type});

  @override
  String toString() => 'SunglassesValidationException: $message';
}

/// Types of validation errors
enum ValidationErrorType {
  fileNotFound,
  fileTooLarge,
  networkError,
  timeout,
  badRequest,
  serverError,
  invalidResponse,
  unknown,
}

/// Extension for user-friendly error messages
extension ValidationErrorTypeExtension on ValidationErrorType {
  String get userMessage {
    switch (this) {
      case ValidationErrorType.fileNotFound:
        return 'Image file not found. Please select an image.';
      case ValidationErrorType.fileTooLarge:
        return 'Image file is too large. Please use a smaller image.';
      case ValidationErrorType.networkError:
        return 'Network connection failed. Please check your internet connection.';
      case ValidationErrorType.timeout:
        return 'AI processing is taking longer than expected. Please try again.';
      case ValidationErrorType.badRequest:
        return 'Invalid image format. Please use a valid image file.';
      case ValidationErrorType.serverError:
        return 'Server error occurred. Please try again later.';
      case ValidationErrorType.invalidResponse:
        return 'Invalid response from server. Please try again.';
      case ValidationErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
