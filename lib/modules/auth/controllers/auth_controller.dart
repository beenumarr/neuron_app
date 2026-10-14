import 'package:flutter/foundation.dart';
import '../../../core/storage/token_storage.dart';
import '../../health/models/health_profile_model.dart';
import '../../health/services/health_api_service.dart';
import '../models/auth_payloads.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticated,
}

class AuthController extends ChangeNotifier {
  final AuthApiService authApiService;
  final HealthApiService healthApiService;
  final TokenStorage tokenStorage;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  HealthProfileModel? _healthProfile;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController({
    required this.authApiService,
    required this.healthApiService,
    required this.tokenStorage,
  });

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isInitial => _status == AuthStatus.initial;
  UserModel? get currentUser => _currentUser;
  HealthProfileModel? get healthProfile => _healthProfile;
  bool get isOnboarded => _healthProfile?.onboardingComplete ?? tokenStorage.isOnboarded;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (tokenStorage.hasToken) {
        // Token exists, verify by fetching current profile
        final user = await authApiService.getMe();
        _currentUser = user;

        try {
          final profile = await healthApiService.getProfile();
          _healthProfile = profile;
          await tokenStorage.setOnboardingCompleted(profile.onboardingComplete);
        } catch (_) {
          // If health profile does not exist yet, onboarding is not completed
        }

        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('[AuthController] Session invalid or expired: $e');
      await tokenStorage.clear();
      _currentUser = null;
      _healthProfile = null;
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    bool agreedToTerms = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Register the account
      final user = await authApiService.register(
        RegisterPayload(
          email: email,
          password: password,
          agreedToTerms: agreedToTerms,
        ),
      );
      _currentUser = user;

      // 2. Automatically log in to obtain JWT access and refresh tokens
      final tokens = await authApiService.login(
        LoginPayload(email: email, password: password, deviceInfo: 'Flutter Mobile'),
      );

      await tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await tokenStorage.saveUserMeta(id: user.id, email: user.email);

      // Check or create profile state
      try {
        _healthProfile = await healthApiService.getProfile();
      } catch (_) {
        _healthProfile = null;
      }

      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tokens = await authApiService.login(
        LoginPayload(email: email, password: password, deviceInfo: 'Flutter Mobile'),
      );

      await tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      final user = await authApiService.getMe();
      _currentUser = user;
      await tokenStorage.saveUserMeta(id: user.id, email: user.email);

      try {
        final profile = await healthApiService.getProfile();
        _healthProfile = profile;
        await tokenStorage.setOnboardingCompleted(profile.onboardingComplete);
      } catch (_) {
        _healthProfile = null;
      }

      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await authApiService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return token;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authApiService.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void handleSessionExpired() {
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    _healthProfile = null;
    _errorMessage = 'Your session has expired. Please sign in again.';
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final refreshToken = tokenStorage.refreshToken;
    if (refreshToken != null) {
      await authApiService.logout(refreshToken);
    }

    await tokenStorage.clear();
    _currentUser = null;
    _healthProfile = null;
    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();
  }

  void updateHealthProfile(HealthProfileModel profile) {
    _healthProfile = profile;
    tokenStorage.setOnboardingCompleted(profile.onboardingComplete);
    notifyListeners();
  }
}
