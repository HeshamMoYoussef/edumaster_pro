import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../routes/app_routes.dart';
import '../constants/api_constants.dart';
import '../utils/storage_service.dart';

/// Interceptor for adding auth token to requests
class AuthInterceptor extends Interceptor {
  final StorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.authToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request with new token
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Refresh failed, logout user
        await _logout();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = _storage.refreshToken;
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': ''}, // Remove old token
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storage.setAuthToken(data['access_token'] as String);
        if (data['refresh_token'] != null) {
          await _storage.setRefreshToken(data['refresh_token'] as String);
        }
        return true;
      }
    } catch (e) {
      developer.log('Token refresh failed: $e');
    }
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer ${_storage.authToken}',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _logout() async {
    await _storage.logout();
    Get.offAllNamed(Routes.login);
  }
}

/// Interceptor for logging requests and responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '┌────────────────────────────────────────────────────────────────────────────────',
    );
    developer.log('│ 🚀 REQUEST: ${options.method} ${options.uri}');
    developer.log('│ Headers: ${options.headers}');
    if (options.data != null) {
      developer.log('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      developer.log('│ Query: ${options.queryParameters}');
    }
    developer.log(
      '└────────────────────────────────────────────────────────────────────────────────',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '┌────────────────────────────────────────────────────────────────────────────────',
    );
    developer.log(
      '│ ✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    developer.log('│ Data: ${_truncate(response.data.toString())}');
    developer.log(
      '└────────────────────────────────────────────────────────────────────────────────',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '┌────────────────────────────────────────────────────────────────────────────────',
    );
    developer.log(
      '│ ❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}',
    );
    developer.log('│ Message: ${err.message}');
    if (err.response?.data != null) {
      developer.log('│ Response: ${err.response?.data}');
    }
    developer.log(
      '└────────────────────────────────────────────────────────────────────────────────',
    );
    handler.next(err);
  }

  String _truncate(String text, {int maxLength = 500}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

/// Interceptor for handling errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Add any global error handling here
    handler.next(err);
  }
}

/// Interceptor for retrying failed requests
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor(
    this._dio, {
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    // Only retry on certain errors
    if (_shouldRetry(err) && retryCount < maxRetries) {
      developer.log('Retrying request (${retryCount + 1}/$maxRetries)...');

      await Future.delayed(retryDelay * (retryCount + 1));

      try {
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        handler.next(e);
        return;
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors, timeouts, and 5xx errors
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
