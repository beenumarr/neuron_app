import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_envelope.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage tokenStorage;
  final OnTokenExpired? onTokenExpired;

  ApiClient({
    required this.tokenStorage,
    this.onTokenExpired,
  }) {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ));

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenStorage: tokenStorage,
        onTokenExpired: onTokenExpired,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          logPrint: (obj) => debugPrint('[DIO] $obj'),
        ),
      );
    }
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl.trim().replaceAll(RegExp(r'/+$'), '');
  }

  Future<ApiEnvelope<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiEnvelope<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiEnvelope<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiEnvelope<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  ApiEnvelope<T> _handleResponse<T>(
    Response response,
    T Function(dynamic data)? parser,
  ) {
    if (response.data is Map<String, dynamic>) {
      final json = response.data as Map<String, dynamic>;
      final envelope = ApiEnvelope<T>.fromJson(json, parser);

      if (!envelope.success) {
        throw ApiException(
          message: envelope.message.isNotEmpty
              ? envelope.message
              : 'Action could not be completed.',
          statusCode: response.statusCode,
          errorCode: envelope.errorCode,
        );
      }

      return envelope;
    }

    return ApiEnvelope<T>(
      success: true,
      data: parser != null ? parser(response.data) : response.data as T?,
    );
  }
}
