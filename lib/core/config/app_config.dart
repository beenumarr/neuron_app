class AppConfig {
  static const String appName = 'NORI';
  static const String appTagline = 'Your AI Health & Nutrition Companion';

  // Production deployed backend URL
  static const String baseUrl = 'https://nbend.ch-farm.com.ng';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Deprecated - kept for compatibility if needed
  static void setBaseUrl(String _) {}
}
