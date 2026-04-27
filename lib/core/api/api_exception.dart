import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.kind = ApiExceptionKind.unknown,
    this.code = ApiErrorCode.unknown,
  });

  final String message;
  final int? statusCode;
  final ApiExceptionKind kind;
  final ApiErrorCode code;

  factory ApiException.fromDioException(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final message = _resolveMessage(exception.type, response?.data, statusCode);

    return ApiException(
      message: message,
      statusCode: statusCode,
      kind: _resolveKind(exception.type, statusCode),
      code: _resolveCode(response?.data),
    );
  }

  static ApiException fromError(Object error) {
    if (error is ApiException) {
      return error;
    }
    if (error is DioException) {
      return ApiException.fromDioException(error);
    }
    return const ApiException(message: 'An unexpected error occurred.');
  }

  static String _resolveMessage(
    DioExceptionType type,
    Object? data,
    int? statusCode,
  ) {
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return 'The request timed out.';
    }

    if (type == DioExceptionType.connectionError) {
      return 'Unable to reach the server.';
    }

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }
    }

    return switch (statusCode) {
      400 => 'The request is invalid.',
      401 => 'Authentication is required.',
      403 => 'You are not allowed to perform this action.',
      404 => 'The requested resource was not found.',
      408 => 'The request timed out.',
      500 => 'The server encountered an error.',
      _ => 'An unexpected error occurred.',
    };
  }

  static ApiErrorCode _resolveCode(Object? data) {
    if (data is Map<String, dynamic>) {
      return ApiErrorCode.fromApi(data['code'] as String?);
    }
    return ApiErrorCode.unknown;
  }

  static ApiExceptionKind _resolveKind(DioExceptionType type, int? statusCode) {
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return ApiExceptionKind.timeout;
    }

    if (type == DioExceptionType.connectionError) {
      return ApiExceptionKind.network;
    }

    return switch (statusCode) {
      400 => ApiExceptionKind.badRequest,
      401 => ApiExceptionKind.unauthorized,
      403 => ApiExceptionKind.forbidden,
      404 => ApiExceptionKind.notFound,
      _ => ApiExceptionKind.unknown,
    };
  }
}

enum ApiErrorCode {
  validationError,
  invalidCaptcha,
  invalidCredentials,
  accountPending,
  accountRejected,
  accountArchived,
  invalidResidenceCode,
  emailAlreadyUsed,
  unauthorized,
  forbidden,
  notFound,
  unknown;

  factory ApiErrorCode.fromApi(String? value) {
    return switch (value) {
      'VALIDATION_ERROR' => ApiErrorCode.validationError,
      'INVALID_CAPTCHA' => ApiErrorCode.invalidCaptcha,
      'INVALID_CREDENTIALS' => ApiErrorCode.invalidCredentials,
      'ACCOUNT_PENDING' => ApiErrorCode.accountPending,
      'ACCOUNT_REJECTED' => ApiErrorCode.accountRejected,
      'ACCOUNT_ARCHIVED' => ApiErrorCode.accountArchived,
      'INVALID_RESIDENCE_CODE' => ApiErrorCode.invalidResidenceCode,
      'EMAIL_ALREADY_USED' => ApiErrorCode.emailAlreadyUsed,
      'UNAUTHORIZED' => ApiErrorCode.unauthorized,
      'FORBIDDEN' => ApiErrorCode.forbidden,
      'NOT_FOUND' => ApiErrorCode.notFound,
      _ => ApiErrorCode.unknown,
    };
  }
}

enum ApiExceptionKind {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  timeout,
  network,
  unknown,
}
