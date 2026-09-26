import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  factory ApiException.fromDioError(DioException dioError) {
    int? code = dioError.response?.statusCode;
    String msg = 'An unexpected network error occurred. Please check your connection.';
    String? errCode;
    dynamic errDetails;

    final data = dioError.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
        msg = data['message'].toString();
      }

      if (data['error'] is Map<String, dynamic>) {
        final errMap = data['error'] as Map<String, dynamic>;
        errCode = errMap['code']?.toString();
        errDetails = errMap['details'];
      }

      // FastAPI / Pydantic validation errors (HTTP 422)
      if (data['detail'] != null) {
        if (data['detail'] is List) {
          final list = data['detail'] as List;
          if (list.isNotEmpty && list.first is Map) {
            final first = list.first as Map;
            msg = first['msg']?.toString() ?? msg;
          }
        } else if (data['detail'] is String) {
          msg = data['detail'] as String;
        }
      }
    } else if (dioError.type == DioExceptionType.connectionTimeout ||
        dioError.type == DioExceptionType.sendTimeout ||
        dioError.type == DioExceptionType.receiveTimeout) {
      msg = 'Connection timed out. Please verify the server is running.';
    } else if (dioError.type == DioExceptionType.connectionError) {
      msg = 'Could not connect to server. Please check your network connection.';
    }

    return ApiException(
      message: msg,
      statusCode: code,
      errorCode: errCode,
      details: errDetails,
    );
  }

  @override
  String toString() => message;
}
