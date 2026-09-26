import 'package:flutter/foundation.dart';
import '../../scanner/models/meal_model.dart';
import '../../scanner/services/meal_api_service.dart';
import '../models/risk_assessment_model.dart';
import '../services/health_api_service.dart';

class HomeController extends ChangeNotifier {
  final HealthApiService healthApiService;
  final MealApiService mealApiService;

  HomeController({
    required this.healthApiService,
    required this.mealApiService,
  });

  RiskAssessmentModel? _riskAssessment;
  List<MealModel> _todayMeals = [];
  bool _isLoading = false;
  String? _errorMessage;

  RiskAssessmentModel? get riskAssessment => _riskAssessment;
  List<MealModel> get todayMeals => _todayMeals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Real NRS Health Score (0-100)
  int get healthScore => _riskAssessment?.healthScore ?? 85;

  String get healthScoreLabel {
    final score = healthScore;
    if (score >= 85) return 'Great';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Attention';
  }

  // Nutrition calculations from today's real logged meals
  int get totalCalories =>
      _todayMeals.fold(0.0, (sum, m) => sum + m.totalCalories).round();

  double get totalProtein =>
      _todayMeals.fold(0.0, (sum, m) => sum + m.totalProtein);

  double get totalCarbs =>
      _todayMeals.fold(0.0, (sum, m) => sum + m.totalCarbs);

  double get totalFat =>
      _todayMeals.fold(0.0, (sum, m) => sum + m.totalFat);

  // Daily target goals (clinical defaults)
  int get calorieGoal => 2200;
  double get proteinGoal => 100.0;
  double get carbsGoal => 250.0;
  double get fatGoal => 70.0;

  int get caloriesPct =>
      ((totalCalories / calorieGoal) * 100).clamp(0, 100).toInt();

  int get proteinPct =>
      ((totalProtein / proteinGoal) * 100).clamp(0, 100).toInt();

  int get carbsPct =>
      ((totalCarbs / carbsGoal) * 100).clamp(0, 100).toInt();

  int get fatPct =>
      ((totalFat / fatGoal) * 100).clamp(0, 100).toInt();

  // Dynamic AI Insight from NRS Risk Flag or nutrition balance
  String get aiInsightText {
    if (_riskAssessment != null && _riskAssessment!.riskFlags.isNotEmpty) {
      final flag = _riskAssessment!.riskFlags.first;
      return flag.recommendation.isNotEmpty ? flag.recommendation : flag.description;
    }

    if (totalProtein < 30 && _todayMeals.isNotEmpty) {
      return "You're running low on protein today. Adding eggs, Greek yogurt, or grilled chicken will support muscle recovery.";
    }

    return "Maintain consistent hydration and balanced macros throughout the day to optimize your daily health score.";
  }

  Future<void> fetchDashboardData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        healthApiService.getRiskAssessment().catchError((_) => null as dynamic),
        mealApiService.getTodayMeals().catchError((_) => <MealModel>[]),
      ]);

      final firstResult = results[0];
      if (firstResult is RiskAssessmentModel) {
        _riskAssessment = firstResult;
      }

      final secondResult = results[1];
      if (secondResult is List<MealModel>) {
        _todayMeals = secondResult;
      }

      _errorMessage = null;
    } catch (e) {
      debugPrint('[HomeController] Error fetching dashboard data: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logQuickMeal({
    required String mealType,
    required String name,
    required double calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) async {
    try {
      final newMeal = await mealApiService.logMealManual(
        mealType: mealType,
        name: name,
        calories: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
      );
      _todayMeals = [newMeal, ..._todayMeals];
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[HomeController] Failed to log quick meal: $e');
      return false;
    }
  }
}
