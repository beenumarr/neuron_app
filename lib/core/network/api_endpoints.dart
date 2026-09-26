class ApiEndpoints {
  // Auth
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String me = '/api/v1/auth/me';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String changePassword = '/api/v1/auth/change-password';

  // Health
  static const String healthOnboarding = '/api/v1/health/onboarding';
  static const String healthProfile = '/api/v1/health/profile';
  static const String healthRiskAssessment = '/api/v1/health/risk-assessment';
  static const String healthMeasurements = '/api/v1/health/measurements';

  // Chat
  static const String chatConversations = '/api/v1/chat/conversations';
  static const String chatSessions = '/api/v1/chat/conversations';

  // Scanner
  static const String scannerAnalyse = '/api/v1/scanner/analyse';
  static const String scannerAnalyze = '/api/v1/scanner/analyse';
  static const String scannerMealsToday = '/api/v1/scanner/meals/today';
  static const String scannerMealsHistory = '/api/v1/scanner/meals/history';
  static const String scannerLogMeal = '/api/v1/scanner/meals';
  static String scannerLogMealFromScan(String scanId) => '/api/v1/scanner/$scanId/log-meal';

  // Progress
  static const String progressWeeklyReport = '/api/v1/progress/weekly-report';
  static const String progressWeekly = '/api/v1/progress/weekly-report';
  static const String progressWeeklyGenerateNow = '/api/v1/progress/weekly-report/generate-now';
}
