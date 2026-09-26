class ApiEnvelope<T> {
  final bool success;
  final T? data;
  final String message;
  final Map<String, dynamic>? error;
  final Map<String, dynamic>? meta;

  ApiEnvelope({
    required this.success,
    this.data,
    this.message = '',
    this.error,
    this.meta,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData)? fromData,
  ) {
    final rawData = json['data'];
    T? parsedData;
    if (rawData != null && fromData != null) {
      parsedData = fromData(rawData);
    } else if (rawData != null && rawData is T) {
      parsedData = rawData;
    }

    return ApiEnvelope<T>(
      success: json['success'] as bool? ?? false,
      data: parsedData,
      message: (json['message'] as String?) ?? '',
      error: json['error'] is Map<String, dynamic> ? json['error'] as Map<String, dynamic> : null,
      meta: json['meta'] is Map<String, dynamic> ? json['meta'] as Map<String, dynamic> : null,
    );
  }

  String? get errorCode {
    if (error != null && error!['code'] != null) {
      return error!['code'].toString();
    }
    return null;
  }
}
