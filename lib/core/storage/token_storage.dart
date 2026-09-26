import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // In-memory cache for ultra-fast synchronous checks
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  bool _isOnboarded = false;

  static const String _keyAccessToken = 'neuron_access_token';
  static const String _keyRefreshToken = 'neuron_refresh_token';
  static const String _keyUserEmail = 'neuron_user_email';
  static const String _keyUserId = 'neuron_user_id';
  static const String _keyOnboarded = 'neuron_onboarding_completed';
  static const String _keyCustomBaseUrl = 'neuron_custom_base_url';

  Future<void> init() async {
    try {
      _cachedAccessToken = await _secureStorage.read(key: _keyAccessToken);
      _cachedRefreshToken = await _secureStorage.read(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('[TokenStorage] Secure storage read error, falling back to SharedPreferences: $e');
      final prefs = await SharedPreferences.getInstance();
      _cachedAccessToken = prefs.getString(_keyAccessToken);
      _cachedRefreshToken = prefs.getString(_keyRefreshToken);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboarded = prefs.getBool(_keyOnboarded) ?? false;
    } catch (_) {}
  }

  String? get accessToken => _cachedAccessToken;
  String? get refreshToken => _cachedRefreshToken;
  bool get hasToken => _cachedAccessToken != null && _cachedAccessToken!.isNotEmpty;
  bool get isOnboarded => _isOnboarded;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;

    try {
      await _secureStorage.write(key: _keyAccessToken, value: accessToken);
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    } catch (e) {
      debugPrint('[TokenStorage] Secure write failed, using SharedPreferences fallback: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
    } catch (_) {}
  }

  Future<void> saveUserMeta({
    required String id,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, id);
    await prefs.setString(_keyUserEmail, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    _isOnboarded = completed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, completed);
  }

  Future<String?> getCustomBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomBaseUrl);
  }

  Future<void> saveCustomBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomBaseUrl, url);
  }

  Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _isOnboarded = false;

    try {
      await _secureStorage.delete(key: _keyAccessToken);
      await _secureStorage.delete(key: _keyRefreshToken);
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyOnboarded);
    } catch (_) {}
  }
}
