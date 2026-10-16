import "package:flutter/foundation.dart";
import "../../../core/network/api_exception.dart";
import "../../../core/storage/token_storage.dart";
import "../../health/models/health_profile_model.dart";
import "../../health/services/health_api_service.dart";
import "../models/auth_payloads.dart";
import "../models/user_model.dart";
import "../services/auth_api_service.dart";

enum AuthStatus {
  initial,
  checkingSession,
  authenticated,
  unauthenticated,
  sessionRestorationFailed,
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
  bool get isCheckingSession => _status == AuthStatus.checkingSession || _status == AuthStatus.initial;
  bool get isInitial => _status == AuthStatus.initial;
  bool get hasRestorationFailed => _status == AuthStatus.sessionRestorationFailed;

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
    _status = AuthStatus.checkingSession;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Check whether persisted authentication credentials exist
    if (!tokenStorage.hasToken) {
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // If access token is null but refresh token is present, rotate immediately
      if ((tokenStorage.accessToken == null || tokenStorage.accessToken!.isEmpty) &&
          tokenStorage.refreshToken != null) {
        debugPrint("[AuthController] Refreshing token pair on startup...");
        final newTokens = await authApiService.refresh(tokenStorage.refreshToken!);
        await tokenStorage.saveTokens(
          accessToken: newTokens.accessToken,
          refreshToken: newTokens.refreshToken,
        );
      }

      UserModel user;
      try {
        user = await authApiService.getMe();
      } on ApiException catch (apiErr) {
        // If 401, access token expired; attempt refresh using refresh token
        if (apiErr.statusCode == 401 && tokenStorage.refreshToken != null) {
          debugPrint("[AuthController] Access token expired (401), refreshing session...");
          try {
            final newTokens = await authApiService.refresh(tokenStorage.refreshToken!);
            await tokenStorage.saveTokens(
              accessToken: newTokens.accessToken,
              refreshToken: newTokens.refreshToken,
            );
            user = await authApiService.getMe();
          } on ApiException catch (refreshErr) {
            if (refreshErr.statusCode == 401 || refreshErr.statusCode == 403) {
              debugPrint("[AuthController] Refresh token revoked or expired: $refreshErr");
              await tokenStorage.clear();
              _currentUser = null;
              _healthProfile = null;
              _errorMessage = "Your session has expired. Please sign in again.";
              _status = AuthStatus.unauthenticated;
              _isLoading = false;
              notifyListeners();
              return;
            }
            if (refreshErr.isNetworkError) {
              await _restoreOfflineSession();
              return;
            }
            rethrow;
          }
        } else if (apiErr.isNetworkError) {
          // Offline startup: retain existing session state without wiping credentials
          await _restoreOfflineSession();
          return;
        } else if (apiErr.statusCode == 401 || apiErr.statusCode == 403) {
          debugPrint("[AuthController] Credentials invalid: $apiErr");
          await tokenStorage.clear();
          _currentUser = null;
          _healthProfile = null;
          _errorMessage = "Please sign in to continue.";
          _status = AuthStatus.unauthenticated;
          _isLoading = false;
          notifyListeners();
          return;
        } else {
          rethrow;
        }
      }

      // Successful server-side session restoration
      _currentUser = user;
      await tokenStorage.saveUserMeta(id: user.id, email: user.email);

      try {
        final profile = await healthApiService.getProfile();
        _healthProfile = profile;
        await tokenStorage.setOnboardingCompleted(profile.onboardingComplete);
      } catch (_) {
        // Health profile may be incomplete; onboarding state is preserved
      }

      _status = AuthStatus.authenticated;
    } catch (e) {
      debugPrint("[AuthController] Error during session restoration: $e");
      if (tokenStorage.refreshToken != null) {
        await _restoreOfflineSession();
        return;
      } else {
        await tokenStorage.clear();
        _currentUser = null;
        _healthProfile = null;
        _status = AuthStatus.unauthenticated;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _restoreOfflineSession() async {
    debugPrint("[AuthController] Restoring offline session from cached credentials...");
    final email = await tokenStorage.getUserEmail();
    final id = await tokenStorage.getUserId();
    if (email != null && id != null) {
      _currentUser = UserModel(id: id, email: email, role: "patient");
    }
    _status = AuthStatus.authenticated;
    _isLoading = false;
    notifyListeners();
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
      final user = await authApiService.register(
        RegisterPayload(
          email: email,
          password: password,
          agreedToTerms: agreedToTerms,
        ),
      );
      _currentUser = user;

      final tokens = await authApiService.login(
        LoginPayload(email: email, password: password, deviceInfo: "Flutter Mobile"),
      );

      await tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await tokenStorage.saveUserMeta(id: user.id, email: user.email);

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
        LoginPayload(email: email, password: password, deviceInfo: "Flutter Mobile"),
      );

      await tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      UserModel user;
      try {
        user = await authApiService.getMe();
      } catch (meErr) {
        debugPrint("[AuthController] Warning: getMe threw after successful login: $meErr");
        user = UserModel(
          id: await tokenStorage.getUserId() ?? "usr_${email.hashCode.abs()}",
          email: email,
          role: "patient",
        );
      }
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

  void handleSessionExpired() async {
    await tokenStorage.clear();
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    _healthProfile = null;
    _errorMessage = "Your session has expired. Please sign in again.";
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final refreshToken = tokenStorage.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await authApiService.logout(refreshToken);
    }

    await tokenStorage.clear();
    _currentUser = null;
    _healthProfile = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void updateHealthProfile(HealthProfileModel profile) {
    _healthProfile = profile;
    tokenStorage.setOnboardingCompleted(profile.onboardingComplete);
    notifyListeners();
  }
}
