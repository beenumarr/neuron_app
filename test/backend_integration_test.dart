import 'package:flutter_test/flutter_test.dart';
import 'package:neuron_app/core/network/api_client.dart';
import 'package:neuron_app/core/storage/token_storage.dart';
import 'package:neuron_app/modules/auth/models/auth_payloads.dart';
import 'package:neuron_app/modules/auth/services/auth_api_service.dart';
import 'package:neuron_app/modules/health/models/onboarding_payload.dart';
import 'package:neuron_app/modules/health/services/health_api_service.dart';

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class _RealHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();
  SharedPreferences.setMockInitialValues({});

  test('Full E2E Auth, Token Rotation & Onboarding against real running backend', () async {
    final tokenStorage = TokenStorage();
    await tokenStorage.init();
    await tokenStorage.clear();

    final apiClient = ApiClient(tokenStorage: tokenStorage);
    // Explicitly target local backend
    apiClient.updateBaseUrl('http://127.0.0.1:8000');

    final authService = AuthApiService(apiClient: apiClient);
    final healthService = HealthApiService(apiClient: apiClient);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'alex.test$timestamp@neuron.ai';
    const testPassword = 'Password123!';

    // 1. Register
    final user = await authService.register(
      RegisterPayload(email: testEmail, password: testPassword),
    );
    expect(user.email, testEmail);
    expect(user.id.isNotEmpty, isTrue);

    // 2. Login
    final tokens = await authService.login(
      LoginPayload(email: testEmail, password: testPassword, deviceInfo: 'Flutter Test Runner'),
    );
    expect(tokens.accessToken.isNotEmpty, isTrue);
    expect(tokens.refreshToken.isNotEmpty, isTrue);

    // Save tokens in token storage
    await tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    // 3. Authenticated GetMe call with injected JWT Bearer token
    final me = await authService.getMe();
    expect(me.email, testEmail);
    expect(me.id, user.id);

    // 4. Token Rotation (Refresh)
    final rotated = await authService.refresh(tokens.refreshToken);
    expect(rotated.accessToken.isNotEmpty, isTrue);
    expect(rotated.refreshToken.isNotEmpty, isTrue);
    expect(rotated.refreshToken != tokens.refreshToken, isTrue);

    // Save rotated tokens
    await tokenStorage.saveTokens(
      accessToken: rotated.accessToken,
      refreshToken: rotated.refreshToken,
    );

    // 5. Submit Patient Onboarding
    final profile = await healthService.completeOnboarding(
      OnboardingPayload(
        name: 'Alex Johnson',
        age: 29,
        gender: 'male',
        weightKg: 74.5,
        heightCm: 178.0,
        conditions: ['None'],
        allergies: [],
        dietaryPreferences: ['High Protein', 'Mediterranean'],
        goal: 'Improve Energy & Health',
      ),
    );

    expect(profile.onboardingComplete, isTrue);
    expect(profile.weightKg, 74.5);
    expect(profile.heightCm, 178.0);
    expect(profile.bmi, isNotNull);
    expect(profile.bmiCategory, 'Normal weight');

    // 6. Retrieve completed profile
    final verifiedProfile = await healthService.getProfile();
    expect(verifiedProfile.onboardingComplete, isTrue);
    expect(verifiedProfile.name, 'Alex Johnson');

    // 7. Logout
    await authService.logout(rotated.refreshToken);
    await tokenStorage.clear();
    expect(tokenStorage.accessToken, isNull);
  });
}
