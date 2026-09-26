import 'package:flutter/foundation.dart';
import '../../health/models/risk_assessment_model.dart';
import '../../health/services/health_api_service.dart';
import '../../scanner/models/meal_model.dart';
import '../../scanner/services/meal_api_service.dart';
import '../models/weekly_report_model.dart';
import '../services/progress_api_service.dart';

class ProgressController extends ChangeNotifier {
  final ProgressApiService progressApiService;
  final HealthApiService healthApiService;
  final MealApiService mealApiService;

  ProgressController({
    required this.progressApiService,
    required this.healthApiService,
    required this.mealApiService,
  });

  RiskAssessmentModel? _riskAssessment;
  WeeklyReportModel? _latestReport;
  List<MealModel> _pastWeekMeals = [];

  bool _isLoading = false;
  bool _isGeneratingReport = false;
  String? _errorMessage;

  RiskAssessmentModel? get riskAssessment => _riskAssessment;
  WeeklyReportModel? get latestReport => _latestReport;
  List<MealModel> get pastWeekMeals => _pastWeekMeals;

  bool get isLoading => _isLoading;
  bool get isGeneratingReport => _isGeneratingReport;
  String? get errorMessage => _errorMessage;

  // Real NRS Health Score & Flags
  int get healthScore => _riskAssessment?.healthScore ?? 85;
  List<RiskFlagModel> get riskFlags => _riskAssessment?.riskFlags ?? [];

  String get healthStatusLabel {
    final s = healthScore;
    if (s >= 85) return 'Optimal';
    if (s >= 70) return 'Healthy';
    if (s >= 50) return 'Moderate';
    return 'Attention';
  }

  // Real Aggregate Nutrition Metrics from logged meals
  int get totalMealsCount => _pastWeekMeals.length;
  double get totalCalories =>
      _pastWeekMeals.fold(0.0, (sum, m) => sum + m.totalCalories);
  double get totalProtein =>
      _pastWeekMeals.fold(0.0, (sum, m) => sum + m.totalProtein);
  double get totalCarbs =>
      _pastWeekMeals.fold(0.0, (sum, m) => sum + m.totalCarbs);
  double get totalFat =>
      _pastWeekMeals.fold(0.0, (sum, m) => sum + m.totalFat);

  double get macroSum => totalProtein + totalCarbs + totalFat;
  double get proteinPct => macroSum > 0 ? (totalProtein / macroSum) * 100 : 0.0;
  double get carbsPct => macroSum > 0 ? (totalCarbs / macroSum) * 100 : 0.0;
  double get fatPct => macroSum > 0 ? (totalFat / macroSum) * 100 : 0.0;

  // Real 7-Day Calorie Intake Trend (Mon..Sun actual logs, 0 for empty days)
  List<Map<String, dynamic>> get dailyCaloriesTrend {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Build ordered list of the past 7 days
    final List<Map<String, dynamic>> days = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final label = weekdays[date.weekday - 1];

      // Sum calories logged on this exact date
      final cals = _pastWeekMeals
          .where((m) =>
              m.loggedAt.year == date.year &&
              m.loggedAt.month == date.month &&
              m.loggedAt.day == date.day)
          .fold(0.0, (sum, m) => sum + m.totalCalories);

      days.add({
        'day': label,
        'calories': cals,
        'hasMeals': cals > 0,
      });
    }
    return days;
  }

  /// Load all real progress data from backend
  Future<void> loadProgressData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final results = await Future.wait([
        healthApiService.getRiskAssessment().catchError((_) => null as dynamic),
        progressApiService.getLatestWeeklyReport().catchError((_) => null),
        mealApiService
            .getMealsHistory(startDate: sevenDaysAgo)
            .catchError((_) => <MealModel>[]),
      ]);

      if (results[0] is RiskAssessmentModel) {
        _riskAssessment = results[0] as RiskAssessmentModel;
      }

      _latestReport = results[1] as WeeklyReportModel?;

      if (results[2] is List<MealModel>) {
        _pastWeekMeals = results[2] as List<MealModel>;
      }

      _errorMessage = null;
    } catch (e) {
      debugPrint('[ProgressController] loadProgressData error: $e');
      _errorMessage = 'Could not load progress data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Manually trigger weekly report generation
  Future<bool> generateReportNow() async {
    _isGeneratingReport = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newReport = await progressApiService.generateWeeklyReportNow();
      _latestReport = newReport;
      return true;
    } catch (e) {
      debugPrint('[ProgressController] generateReportNow error: $e');
      _errorMessage = 'Failed to generate weekly report. Please try again.';
      return false;
    } finally {
      _isGeneratingReport = false;
      notifyListeners();
    }
  }
}
