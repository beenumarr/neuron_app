import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'NEURON';
  static const String appTagline = 'Your AI Health & Nutrition Companion';

  // Remote production server URL for when the backend is hosted online
  static const String defaultProductionUrl = 'https://nbend.ch-farm.com.ng';

  // Allows injecting URL via compile-time argument: --dart-define=API_BASE_URL=https://...
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Allows overriding the base URL at runtime or test time
  static String? _customBaseUrl;

  static void setBaseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static String get baseUrl {
    // 1. User or runtime override
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }

    // 2. Compile-time environment variable (--dart-define=API_BASE_URL=...)
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    // 3. In release mode, default to the remote production backend
    if (kReleaseMode) {
      return defaultProductionUrl;
    }

    // 4. Web debug
    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    // 5. Android: Physical device connected via ADB reverse (tcp:8000 -> tcp:8000)
    // connects via 127.0.0.1:8000. 10.0.2.2 is only for emulators.
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://127.0.0.1:8000';
    }

    // Linux, macOS, iOS simulator
    return 'http://127.0.0.1:8000';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
