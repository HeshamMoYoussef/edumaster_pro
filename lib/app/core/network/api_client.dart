import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../../config/env_config.dart';
import '../utils/storage_service.dart';
import 'api_exceptions.dart';
import 'api_interceptors.dart';

/// API Client using Dio for HTTP requests
class ApiClient extends GetxService {
  late final dio.Dio _dio;
  final StorageService _storage = Get.find<StorageService>();

  dio.Dio get client => _dio;

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: Duration(milliseconds: EnvConfig.connectionTimeout),
        receiveTimeout: Duration(milliseconds: EnvConfig.requestTimeout),
        sendTimeout: Duration(milliseconds: EnvConfig.requestTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': _storage.locale,
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(_storage, _dio),
      if (EnvConfig.enableLogging) LoggingInterceptor(),
      ErrorInterceptor(),
      RetryInterceptor(_dio, maxRetries: EnvConfig.maxRetryAttempts),
    ]);
  }

  /// Update the locale header
  void updateLocale(String locale) {
    _dio.options.headers['Accept-Language'] = locale;
  }

  /// Make a GET request
  Future<dio.Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a POST request
  Future<dio.Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a PUT request
  Future<dio.Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a PATCH request
  Future<dio.Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a DELETE request
  Future<dio.Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file
  Future<dio.Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    dio.CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = dio.FormData.fromMap({
        fieldName: await dio.MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file
  Future<dio.Response> downloadFile(
    String url,
    String savePath, {
    dio.CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  ApiException _handleError(dio.DioException error) {
    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'error_timeout'.tr,
        );

      case dio.DioExceptionType.connectionError:
        return NetworkException(
          message: 'error_network'.tr,
        );

      case dio.DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case dio.DioExceptionType.cancel:
        return RequestCancelledException(
          message: 'request_cancelled'.tr,
        );

      default:
        return UnknownException(
          message: error.message ?? 'error_general'.tr,
        );
    }
  }

  /// Handle HTTP response errors
  ApiException _handleResponseError(dio.Response? response) {
    if (response == null) {
      return UnknownException(message: 'error_empty_response'.tr);
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    String message = 'error_general'.tr;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          message;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message: message);
      case 401:
        return UnauthorizedException(message: 'session_expired'.tr);
      case 403:
        return ForbiddenException(message: 'error_forbidden'.tr);
      case 404:
        return NotFoundException(message: 'error_not_found'.tr);
      case 409:
        return ConflictException(message: message);
      case 422:
        return ValidationException(
          message: message,
          errors: data is Map ? data['errors'] as Map<String, dynamic>? : null,
        );
      case 429:
        return TooManyRequestsException(message: 'error_too_many_requests'.tr);
      case 500:
      case 502:
      case 503:
        return ServerException(message: 'error_server'.tr);
      default:
        return UnknownException(message: message, statusCode: statusCode);
    }
  }
}
