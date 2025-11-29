import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'sunglasses_validation_service.dart';

void main() {
  group('SunglassesValidationService', () {
    test('should set and get base URL correctly', () {
      const testUrl = 'https://api.example.com';
      SunglassesValidationService.setBaseUrl(testUrl);
      expect(SunglassesValidationService.baseUrl, testUrl);
    });

    test('should handle trailing slash in base URL', () {
      const testUrlWithSlash = 'https://api.example.com/';
      SunglassesValidationService.setBaseUrl(testUrlWithSlash);
      expect(SunglassesValidationService.baseUrl, 'https://api.example.com');
    });

    test('should validate file size limits', () async {
      // Create a mock file that's too large
      final largeBytes = Uint8List(11 * 1024 * 1024); // 11MB
      
      expect(
        () => SunglassesValidationService.validateSunglassesFromBytes(largeBytes),
        throwsA(isA<SunglassesValidationException>()),
      );
    });

    test('should validate empty image data', () async {
      final emptyBytes = Uint8List(0);
      
      expect(
        () => SunglassesValidationService.validateSunglassesFromBytes(emptyBytes),
        throwsA(isA<SunglassesValidationException>()),
      );
    });

    test('should validate file not found', () async {
      final nonExistentFile = File('non_existent_file.jpg');
      
      expect(
        () => SunglassesValidationService.validateSunglassesFromFile(nonExistentFile),
        throwsA(isA<SunglassesValidationException>()),
      );
    });
  });

  group('SunglassesValidationResult', () {
    test('should create from JSON correctly', () {
      final json = {
        'status': 'accepted',
        'confidence': 0.95,
        'message': 'Sunglasses detected',
        'details': 'Detected: Sunglasses with 95% confidence',
        'analysis': {
          'sunglasses_detected': true,
          'confidence': 0.95,
        },
        'timestamp': '2024-01-01T00:00:00Z',
      };

      final result = SunglassesValidationResult.fromJson(json);
      
      expect(result.isAccepted, true);
      expect(result.confidence, 0.95);
      expect(result.message, 'Sunglasses detected');
      expect(result.details, 'Detected: Sunglasses with 95% confidence');
    });

    test('should return correct success message', () {
      final result = SunglassesValidationResult(
        isAccepted: true,
        confidence: 0.95,
        message: 'Sunglasses detected',
        details: 'Detected: Sunglasses with 95% confidence',
        analysis: {},
        timestamp: '',
      );

      expect(result.successMessage, 'Sunglasses verified! Submitting...');
    });

    test('should return correct error message for low confidence', () {
      final result = SunglassesValidationResult(
        isAccepted: false,
        confidence: 0.3,
        message: 'No sunglasses detected',
        details: 'No sunglasses found',
        analysis: {},
        timestamp: '',
      );

      expect(result.errorMessage, 'No sunglasses found in the image');
    });

    test('should return correct error message for regular glasses', () {
      final result = SunglassesValidationResult(
        isAccepted: false,
        confidence: 0.7,
        message: 'Regular glasses detected',
        details: 'Regular glasses found',
        analysis: {},
        timestamp: '',
      );

      expect(result.errorMessage, 'Regular glasses detected. Please use sunglasses.');
    });
  });

  group('ValidationErrorType', () {
    test('should return correct user messages', () {
      expect(ValidationErrorType.fileNotFound.userMessage, 
             'Image file not found. Please select an image.');
      expect(ValidationErrorType.fileTooLarge.userMessage, 
             'Image file is too large. Please use a smaller image.');
      expect(ValidationErrorType.networkError.userMessage, 
             'Network connection failed. Please check your internet connection.');
      expect(ValidationErrorType.timeout.userMessage, 
             'Request timed out. Please try again.');
      expect(ValidationErrorType.badRequest.userMessage, 
             'Invalid image format. Please use a valid image file.');
      expect(ValidationErrorType.serverError.userMessage, 
             'Server error occurred. Please try again later.');
      expect(ValidationErrorType.invalidResponse.userMessage, 
             'Invalid response from server. Please try again.');
      expect(ValidationErrorType.unknown.userMessage, 
             'An unexpected error occurred. Please try again.');
    });
  });
}

