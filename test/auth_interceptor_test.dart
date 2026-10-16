import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neuron_app/core/network/auth_interceptor.dart';
import 'package:neuron_app/core/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late TokenStorage tokenStorage;
  late Dio dio;
  late AuthInterceptor interceptor;

  setUp(() async {
    tokenStorage = TokenStorage();
    await tokenStorage.init();
    await tokenStorage.clear();

    dio = Dio(BaseOptions(baseUrl: 'https://test.api.nori.ai'));
    interceptor = AuthInterceptor(dio: dio, tokenStorage: tokenStorage);
  });

  test('AuthInterceptor attaches valid Bearer token header without literal dollar sign', () async {
    await tokenStorage.saveTokens(
      accessToken: 'sample_jwt_access_token_123',
      refreshToken: 'sample_refresh_token_456',
    );

    final options = RequestOptions(path: '/api/v1/auth/me');
    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(options.headers['Authorization'], 'Bearer sample_jwt_access_token_123');
    expect(options.headers['Authorization'], isNot(contains(r'$')));
  });

  test('AuthInterceptor omits Authorization header on public endpoints', () async {
    await tokenStorage.saveTokens(
      accessToken: 'sample_jwt_access_token_123',
      refreshToken: 'sample_refresh_token_456',
    );

    final loginOptions = RequestOptions(path: '/api/v1/auth/login');
    interceptor.onRequest(loginOptions, RequestInterceptorHandler());
    expect(loginOptions.headers.containsKey('Authorization'), isFalse);

    final registerOptions = RequestOptions(path: '/api/v1/auth/register');
    interceptor.onRequest(registerOptions, RequestInterceptorHandler());
    expect(registerOptions.headers.containsKey('Authorization'), isFalse);

    final refreshOptions = RequestOptions(path: '/api/v1/auth/refresh');
    interceptor.onRequest(refreshOptions, RequestInterceptorHandler());
    expect(refreshOptions.headers.containsKey('Authorization'), isFalse);
  });

  test('AuthInterceptor handles empty or missing token gracefully', () async {
    await tokenStorage.clear();

    final options = RequestOptions(path: '/api/v1/health/profile');
    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(options.headers.containsKey('Authorization'), isFalse);
  });
}
