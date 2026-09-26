import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';

typedef OnTokenExpired = void Function();

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final OnTokenExpired? onTokenExpired;

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshCompleters = [];

  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    this.onTokenExpired,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStorage.accessToken;
    final isAuthEndpoint = options.path.contains('/api/v1/auth/login') ||
        options.path.contains('/api/v1/auth/register') ||
        options.path.contains('/api/v1/auth/refresh') ||
        options.path.contains('/api/v1/auth/forgot-password') ||
        options.path.contains('/api/v1/auth/reset-password');

    if (token != null && token.isNotEmpty && !isAuthEndpoint) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only attempt token refresh on 401 responses for non-auth endpoints
    final is401 = err.response?.statusCode == 401;
    final isAuthEndpoint = err.requestOptions.path.contains('/api/v1/auth/');

    if (is401 && !isAuthEndpoint && tokenStorage.refreshToken != null) {
      debugPrint('[AuthInterceptor] 401 received for ${err.requestOptions.path}. Attempting token refresh...');

      if (_isRefreshing) {
        // Queue this request until refresh is done
        final completer = Completer<String?>();
        _refreshCompleters.add(completer);
        final newToken = await completer.future;

        if (newToken != null) {
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
          try {
            final response = await dio.fetch(retryOptions);
            return handler.resolve(response);
          } catch (e) {
            if (e is DioException) return handler.next(e);
            return handler.reject(err);
          }
        } else {
          return handler.next(err);
        }
      }

      _isRefreshing = true;

      try {
        final currentRefreshToken = tokenStorage.refreshToken;
        if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
          throw Exception('No refresh token available');
        }

        // Use a separate Dio instance to avoid interceptor recursion
        final refreshDio = Dio(BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout,
        ));

        final response = await refreshDio.post(
          ApiEndpoints.refresh,
          data: {'refresh_token': currentRefreshToken},
        );

        if (response.statusCode == 200 && response.data != null) {
          final resData = response.data;
          final tokenData = resData['data'];
          final newAccessToken = tokenData['access_token'] as String;
          final newRefreshToken = tokenData['refresh_token'] as String;

          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          debugPrint('[AuthInterceptor] Token refreshed successfully.');

          // Resolve all pending completers
          for (final c in _refreshCompleters) {
            c.complete(newAccessToken);
          }
          _refreshCompleters.clear();
          _isRefreshing = false;

          // Retry the original request
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retriedResponse = await dio.fetch(retryOptions);
          return handler.resolve(retriedResponse);
        } else {
          throw Exception('Refresh returned non-200 status');
        }
      } catch (refreshErr) {
        debugPrint('[AuthInterceptor] Refresh token expired or failed: $refreshErr');

        for (final c in _refreshCompleters) {
          c.complete(null);
        }
        _refreshCompleters.clear();
        _isRefreshing = false;

        // Clear session and notify listener to navigate to login
        await tokenStorage.clear();
        onTokenExpired?.call();

        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
