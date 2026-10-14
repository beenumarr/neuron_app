import "package:flutter/foundation.dart";
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neuron_app/core/network/api_client.dart';
import 'package:neuron_app/core/network/api_exception.dart';
import 'package:neuron_app/core/storage/token_storage.dart';
import 'package:neuron_app/modules/auth/controllers/auth_controller.dart';
import 'package:neuron_app/modules/auth/models/auth_payloads.dart';
import 'package:neuron_app/modules/auth/models/auth_tokens.dart';
import 'package:neuron_app/modules/auth/models/user_model.dart';
import 'package:neuron_app/modules/auth/services/auth_api_service.dart';
import 'package:neuron_app/modules/health/models/health_profile_model.dart';
import 'package:neuron_app/modules/health/services/health_api_service.dart';

class MockAuthApiService extends AuthApiService {
  MockAuthApiService({required super.apiClient});

  UserModel? mockUser;
  AuthTokens? mockTokens;
  bool shouldThrow401OnMe = false;
  bool shouldThrowNetworkErrorOnMe = false;
  bool shouldThrow401OnRefresh = false;
  bool logoutCalled = false;
  int refreshCallCount = 0;

  @override
  Future<UserModel> register(RegisterPayload payload) async {
    mockUser = UserModel(id: 'usr_reg_1', email: payload.email, role: 'patient');
    return mockUser!;
  }

  @override
  Future<AuthTokens> login(LoginPayload payload) async {
    mockTokens = AuthTokens(
      accessToken: 'access_${payload.email}',
      refreshToken: 'refresh_${payload.email}',
      tokenType: 'bearer',
    );
    mockUser = UserModel(id: 'usr_${payload.email}', email: payload.email, role: 'patient');
    return mockTokens!;
  }

  @override
  Future<UserModel> getMe() async {
    if (shouldThrow401OnMe) {
      throw ApiException(message: 'Token expired', statusCode: 401);
    }
    if (shouldThrowNetworkErrorOnMe) {
      throw ApiException(message: 'Connection failed', statusCode: null);
    }
    return mockUser ?? UserModel(id: 'usr_default', email: 'user@nori.ai', role: 'patient');
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    refreshCallCount++;
    if (shouldThrow401OnRefresh) {
      throw ApiException(message: 'Refresh token expired or revoked', statusCode: 401);
    }
    mockTokens = AuthTokens(
      accessToken: 'refreshed_access_$refreshCallCount',
      refreshToken: 'refreshed_refresh_$refreshCallCount',
      tokenType: 'bearer',
    );
    return mockTokens!;
  }

  @override
  Future<void> logout(String refreshToken) async {
    logoutCalled = true;
  }
}

class MockHealthApiService extends HealthApiService {
  MockHealthApiService({required super.apiClient});

  bool mockOnboardingComplete = true;

  @override
  Future<HealthProfileModel> getProfile() async {
    return HealthProfileModel(
      id: 'hp_1',
      userId: 'usr_1',
      name: 'Test Patient',
      age: 30,
      gender: 'female',
      weightKg: 65,
      heightCm: 170,
      conditions: ['Diabetes'],
      allergies: [],
      dietaryPreferences: [],
      goal: 'Manage blood sugar',
      onboardingComplete: mockOnboardingComplete,
      bmi: 22.5,
      bmiCategory: 'Normal weight',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenStorage tokenStorage;
  late ApiClient apiClient;
  late MockAuthApiService authApiService;
  late MockHealthApiService healthApiService;
  late AuthController authController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tokenStorage = TokenStorage();
    await tokenStorage.init();
    await tokenStorage.clear();

    apiClient = ApiClient(tokenStorage: tokenStorage);
    authApiService = MockAuthApiService(apiClient: apiClient);
    healthApiService = MockHealthApiService(apiClient: apiClient);

    authController = AuthController(
      authApiService: authApiService,
      healthApiService: healthApiService,
      tokenStorage: tokenStorage,
    );
  });

  test('Test A: New registration establishes session and persists credentials', () async {
    final success = await authController.register(
      email: 'newuser@nori.ai',
      password: 'SecurePassword123!',
      agreedToTerms: true,
    );

    expect(success, isTrue);
    expect(authController.isAuthenticated, isTrue);
    expect(authController.currentUser?.email, 'newuser@nori.ai');
    expect(tokenStorage.hasToken, isTrue);
    expect(tokenStorage.accessToken, contains('newuser@nori.ai'));
    expect(tokenStorage.refreshToken, contains('newuser@nori.ai'));
    expect(await tokenStorage.getUserEmail(), 'newuser@nori.ai');
  });

  test('Test B: Existing user login stores credentials and establishes authenticated session', () async {
    final success = await authController.login(
      email: 'patient@nori.ai',
      password: 'SecurePassword123!',
    );

    expect(success, isTrue);
    expect(authController.isAuthenticated, isTrue);
    expect(authController.currentUser?.email, 'patient@nori.ai');
    expect(tokenStorage.hasToken, isTrue);
    expect(tokenStorage.accessToken, 'access_patient@nori.ai');
    expect(tokenStorage.refreshToken, 'refresh_patient@nori.ai');
  });

  test('Test C: Application restart restores authenticated session without asking for login', () async {
    // 1. Simulate prior login
    await tokenStorage.saveTokens(
      accessToken: 'access_persisted',
      refreshToken: 'refresh_persisted',
    );
    await tokenStorage.saveUserMeta(id: 'usr_persisted', email: 'persisted@nori.ai');
    authApiService.mockUser = UserModel(id: 'usr_persisted', email: 'persisted@nori.ai', role: 'patient');

    // 2. Re-create new TokenStorage and AuthController to simulate cold restart
    final restartStorage = TokenStorage();
    await restartStorage.init();
    expect(restartStorage.hasToken, isTrue);

    final restartClient = ApiClient(tokenStorage: restartStorage);
    final restartAuthService = MockAuthApiService(apiClient: restartClient);
    restartAuthService.mockUser = authApiService.mockUser;
    final restartHealthService = MockHealthApiService(apiClient: restartClient);

    final restartController = AuthController(
      authApiService: restartAuthService,
      healthApiService: restartHealthService,
      tokenStorage: restartStorage,
    );

    expect(restartController.status, AuthStatus.initial);

    // 3. Initialize startup check
    await restartController.initialize();

    expect(restartController.status, AuthStatus.authenticated);
    expect(restartController.currentUser?.email, 'persisted@nori.ai');
  });

  test('Test D: Expired access token is automatically rotated via refresh token on startup', () async {
    await tokenStorage.saveTokens(
      accessToken: 'expired_access_token',
      refreshToken: 'valid_refresh_token',
    );
    await tokenStorage.saveUserMeta(id: 'usr_refresh', email: 'refresh@nori.ai');

    authApiService.shouldThrow401OnMe = true; // first getMe throws 401
    authApiService.mockUser = UserModel(id: 'usr_refresh', email: 'refresh@nori.ai', role: 'patient');

    // When refresh is called, it will update mockTokens, then getMe should succeed
    authApiService.mockTokens = AuthTokens(
      accessToken: 'new_fresh_access_token',
      refreshToken: 'new_fresh_refresh_token',
      tokenType: 'bearer',
    );

    // After 1st call, allow getMe to succeed
    int meCallCount = 0;
    authApiService = _Dynamic401MockAuthService(
      apiClient: apiClient,
      onFirstMe: () => meCallCount++,
    );

    authController = AuthController(
      authApiService: authApiService,
      healthApiService: healthApiService,
      tokenStorage: tokenStorage,
    );

    await authController.initialize();

    expect(authController.isAuthenticated, isTrue);
    expect(tokenStorage.accessToken, contains('refreshed_access'));
    expect(tokenStorage.refreshToken, contains('refreshed_refresh'));
  });

  test('Test E: Invalid or expired refresh token clears credentials and redirects to login', () async {
    await tokenStorage.saveTokens(
      accessToken: 'expired_access_token',
      refreshToken: 'expired_refresh_token',
    );
    authApiService.shouldThrow401OnMe = true;
    authApiService.shouldThrow401OnRefresh = true; // Refresh also rejected

    await authController.initialize();

    expect(authController.status, AuthStatus.unauthenticated);
    expect(authController.errorMessage, contains('expired'));
    expect(tokenStorage.accessToken, isNull);
    expect(tokenStorage.refreshToken, isNull);
    expect(tokenStorage.hasToken, isFalse);
  });

  test('Test F: Explicit logout revokes server session, clears credentials, and unauthenticates', () async {
    await authController.login(email: 'logout_test@nori.ai', password: 'Password123!');
    expect(authController.isAuthenticated, isTrue);

    await authController.logout();

    expect(authApiService.logoutCalled, isTrue);
    expect(authController.status, AuthStatus.unauthenticated);
    expect(authController.currentUser, isNull);
    expect(tokenStorage.accessToken, isNull);
    expect(tokenStorage.refreshToken, isNull);
    expect(tokenStorage.hasToken, isFalse);
  });

  test('Test G: Incomplete onboarding preserves onboarding route guidance', () async {
    healthApiService.mockOnboardingComplete = false;
    await tokenStorage.setOnboardingCompleted(false);

    await authController.login(email: 'newbie@nori.ai', password: 'Password123!');

    expect(authController.isAuthenticated, isTrue);
    expect(authController.isOnboarded, isFalse);
  });

  test('Test H: Offline startup retains valid credentials and restores session gracefully', () async {
    await tokenStorage.saveTokens(
      accessToken: 'valid_access_token',
      refreshToken: 'valid_refresh_token',
    );
    await tokenStorage.saveUserMeta(id: 'usr_offline', email: 'offline@nori.ai');

    authApiService.shouldThrowNetworkErrorOnMe = true; // Connection failed

    await authController.initialize();

    // Must NOT clear credentials on offline/network errors
    expect(tokenStorage.hasToken, isTrue);
    expect(tokenStorage.accessToken, 'valid_access_token');
    expect(authController.status, AuthStatus.authenticated);
    expect(authController.currentUser?.email, 'offline@nori.ai');
  });

  test('Test I: Account switching resets state and caches new user metadata', () async {
    // 1. User A logs in
    await authController.login(email: 'user_a@nori.ai', password: 'Password123!');
    expect(authController.currentUser?.email, 'user_a@nori.ai');
    expect(await tokenStorage.getUserEmail(), 'user_a@nori.ai');

    // 2. User A logs out
    await authController.logout();
    expect(tokenStorage.hasToken, isFalse);
    expect(authController.currentUser, isNull);

    // 3. User B logs in
    await authController.login(email: 'user_b@nori.ai', password: 'Password123!');
    expect(authController.currentUser?.email, 'user_b@nori.ai');
    expect(await tokenStorage.getUserEmail(), 'user_b@nori.ai');
    expect(tokenStorage.accessToken, 'access_user_b@nori.ai');
  });
}

class _Dynamic401MockAuthService extends MockAuthApiService {
  final VoidCallback onFirstMe;
  int _calls = 0;

  _Dynamic401MockAuthService({
    required super.apiClient,
    required this.onFirstMe,
  });

  @override
  Future<UserModel> getMe() async {
    _calls++;
    if (_calls == 1) {
      onFirstMe();
      throw ApiException(message: 'Token expired', statusCode: 401);
    }
    return UserModel(id: 'usr_refresh', email: 'refresh@nori.ai', role: 'patient');
  }
}
