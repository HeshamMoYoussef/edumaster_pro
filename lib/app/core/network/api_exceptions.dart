/// Base class for API exceptions
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

/// Network connection exception
class NetworkException extends ApiException {
  const NetworkException({required super.message});
}

/// Request timeout exception
class TimeoutException extends ApiException {
  const TimeoutException({required super.message});
}

/// Bad request (400)
class BadRequestException extends ApiException {
  const BadRequestException({required super.message}) : super(statusCode: 400);
}

/// Unauthorized (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException({required super.message}) : super(statusCode: 401);
}

/// Forbidden (403)
class ForbiddenException extends ApiException {
  const ForbiddenException({required super.message}) : super(statusCode: 403);
}

/// Not found (404)
class NotFoundException extends ApiException {
  const NotFoundException({required super.message}) : super(statusCode: 404);
}

/// Conflict (409)
class ConflictException extends ApiException {
  const ConflictException({required super.message}) : super(statusCode: 409);
}

/// Validation error (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    required super.message,
    this.errors,
  }) : super(statusCode: 422);

  /// Get error message for a specific field
  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    if (fieldErrors == null) return null;
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return fieldErrors.toString();
  }

  /// Get all field errors as a formatted string
  String get formattedErrors {
    if (errors == null) return message;
    final buffer = StringBuffer();
    errors!.forEach((field, value) {
      if (value is List) {
        buffer.writeln('$field: ${value.join(', ')}');
      } else {
        buffer.writeln('$field: $value');
      }
    });
    return buffer.toString().trim();
  }
}

/// Too many requests (429)
class TooManyRequestsException extends ApiException {
  const TooManyRequestsException({required super.message}) : super(statusCode: 429);
}

/// Server error (5xx)
class ServerException extends ApiException {
  const ServerException({required super.message}) : super(statusCode: 500);
}

/// Request was cancelled
class RequestCancelledException extends ApiException {
  const RequestCancelledException({required super.message});
}

/// Unknown/generic exception
class UnknownException extends ApiException {
  const UnknownException({
    required super.message,
    super.statusCode,
  });
}

/// Extension to check exception types
extension ApiExceptionExtension on ApiException {
  /// Check if exception is due to authentication
  bool get isAuthError => this is UnauthorizedException;

  /// Check if exception is due to network
  bool get isNetworkError => this is NetworkException;

  /// Check if exception is due to timeout
  bool get isTimeoutError => this is TimeoutException;

  /// Check if exception is due to server
  bool get isServerError => this is ServerException;

  /// Check if exception is due to validation
  bool get isValidationError => this is ValidationException;

  /// Check if exception is recoverable (can retry)
  bool get isRecoverable =>
      this is NetworkException ||
      this is TimeoutException ||
      this is ServerException ||
      this is TooManyRequestsException;
}
