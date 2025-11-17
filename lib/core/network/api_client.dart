import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

/// Generic API Client with [interceptors for token management, logging, and error handling]
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // Expose Dio instance for direct access when needed
  Dio get dio => _dio;

  ApiClient({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if this is a public endpoint (skip auth)
          final skipAuth = options.extra['skipAuth'] == true;

          if (!skipAuth) {
            // Inject access token for authenticated endpoints
            final token = await _secureStorage.read(
              key: AppConstants.keyAuthToken,
            );
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          // Log request details
          print('🌐 REQUEST[${options.method}] => ${options.uri}');
          print('📋 Headers: ${options.headers}');
          if (options.data != null) {
            print('📦 Data: ${options.data}');
          }
          print('🔓 Public Endpoint: $skipAuth');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          print(
            '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          print('📥 Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print(
            '❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
          );
          print('❌ Error Response: ${error.response?.data}');
          print('❌ Error Message: ${error.message}');

          // Handle 401 - Token expired
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the request
              final options = error.requestOptions;
              final token = await _secureStorage.read(
                key: AppConstants.keyAuthToken,
              );
              options.headers['Authorization'] = 'Bearer $token';

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: AppConstants.keyRefreshToken,
      );
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await _secureStorage.write(
          key: AppConstants.keyAuthToken,
          value: newAccessToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('🔄 Token refresh failed: $e');
      return false;
    }
  }

  /// Generic GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET request for public endpoints (no authentication required)
  Future<T> getPublic<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Create options that explicitly skip the auth interceptor
      final publicOptions = (options ?? Options()).copyWith(
        extra: {'skipAuth': true},
      );

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: publicOptions,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request for public endpoints (no authentication required)
  Future<T> postPublic<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Create options that explicitly skip the auth interceptor
      final publicOptions = (options ?? Options()).copyWith(
        extra: {'skipAuth': true},
      );

      final response = await _dio.post(
        path,
        data: jsonEncode(data),
        queryParameters: queryParameters,
        options: publicOptions,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PATCH request
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic DELETE request
  Future<T?> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T?;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file (multipart/form-data)
  Future<T> uploadFile<T>(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to domain failures
  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(
          'Connection timeout. Please check your internet.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 400:
            // Parse field-specific errors
            if (data is Map) {
              // Cast to Map<String, dynamic>
              final errorData = Map<String, dynamic>.from(data);
              // Check for field-specific errors first
              final errorMessage = _parseFieldErrors(errorData);
              if (errorMessage != null) {
                return ValidationFailure(errorMessage);
              }
              // Fall back to detail field
              return ValidationFailure(
                errorData['detail'] ?? 'Invalid input. Please check your data.',
              );
            }
            return ValidationFailure('Invalid input. Please check your data.');
          case 401:
            return AuthFailure('Authentication failed. Please login again.');
          case 403:
            return AuthFailure('Access denied.');
          case 404:
            return ServerFailure('Resource not found.');
          case 429:
            return ServerFailure(
              data is Map
                  ? data['detail'] ??
                        'Too many requests. Please try again later.'
                  : 'Too many requests. Please try again later.',
            );
          case 500:
          case 502:
          case 503:
            return ServerFailure('Server error. Please try again later.');
          default:
            return ServerFailure('Something went wrong. Please try again.');
        }

      case DioExceptionType.cancel:
        return NetworkFailure('Request cancelled.');

      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          return NetworkFailure('No internet connection.');
        }
        return NetworkFailure('Network error occurred.');

      default:
        return ServerFailure('Unexpected error occurred.');
    }
  }

  /// Parse field-specific errors from API response
  String? _parseFieldErrors(Map<String, dynamic> data) {
    // Common field names to check
    final fieldNames = [
      'username',
      'email',
      'password',
      're_password',
      'non_field_errors',
    ];

    for (final field in fieldNames) {
      if (data.containsKey(field)) {
        final fieldError = data[field];
        if (fieldError is List && fieldError.isNotEmpty) {
          // Return user-friendly message
          return _getUserFriendlyMessage(field, fieldError.first.toString());
        } else if (fieldError is String) {
          return _getUserFriendlyMessage(field, fieldError);
        }
      }
    }

    // Check for any other field errors
    for (final entry in data.entries) {
      if (entry.value is List && (entry.value as List).isNotEmpty) {
        return _getUserFriendlyMessage(
          entry.key.toString(),
          (entry.value as List).first.toString(),
        );
      } else if (entry.value is String) {
        return _getUserFriendlyMessage(
          entry.key.toString(),
          entry.value as String,
        );
      }
    }

    return null;
  }

  /// Convert technical error messages to user-friendly ones
  String _getUserFriendlyMessage(String field, String message) {
    // Username errors
    if (field == 'username') {
      if (message.toLowerCase().contains('already exists')) {
        return 'This username is already taken. Please try a different name.';
      }
      if (message.toLowerCase().contains('invalid')) {
        return 'Username can only contain letters, numbers, and underscores.';
      }
    }

    // Email errors
    if (field == 'email') {
      if (message.toLowerCase().contains('already exists')) {
        return 'An account with this email already exists. Please login instead.';
      }
      if (message.toLowerCase().contains('invalid')) {
        return 'Please enter a valid email address.';
      }
    }

    // Password errors
    if (field == 'password' || field == 're_password') {
      if (message.toLowerCase().contains('too short')) {
        return 'Password must be at least 8 characters long.';
      }
      if (message.toLowerCase().contains('too common')) {
        return 'This password is too common. Please choose a stronger password.';
      }
      if (message.toLowerCase().contains('numeric')) {
        return 'Password cannot be entirely numeric.';
      }
      if (message.toLowerCase().contains('match')) {
        return 'Passwords do not match.';
      }
    }

    // Return the original message if no specific mapping found
    return message;
  }

  /// Clear all stored tokens (logout)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
  }
}
