import 'package:flutter/foundation.dart';
import '../../scanner/models/meal_model.dart';
import '../../scanner/services/meal_api_service.dart';
import '../models/health_profile_model.dart';
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

  // Danger / Risk Level from Health Score
  String get dangerLevelLabel {
    final score = healthScore;
    if (score >= 85) return 'Optimal';
    if (score >= 70) return 'Healthy';
    if (score >= 50) return 'Moderate';
    return 'Attention';
  }

  // Short, personalized AI Insight based on user profile and daily progress
  String getShortAiInsight([HealthProfileModel? profile]) {
    // 1. Today's nutrition progress insights
    if (_todayMeals.isNotEmpty) {
      if (totalCalories >= calorieGoal) {
        return "Calorie target reached for today. Focus on hydration!";
      }
      if (totalProtein < 35 && totalCalories > 600) {
        return "Add some lean protein to your next meal to hit your daily target.";
      }
      if (_todayMeals.length >= 2) {
        return "Great logging consistency today! Keep meals balanced.";
      }
    }

    // 2. Health profile conditions insight
    if (profile != null && profile.conditions.isNotEmpty) {
      final conds = profile.conditions.map((c) => c.toLowerCase()).toList();
      if (conds.any((c) => c.contains('diabet') || c.contains('sugar'))) {
        return "Focus on low-GI whole foods and steady hydration today.";
      }
      if (conds.any((c) => c.contains('hypertens') || c.contains('pressure') || c.contains('heart'))) {
        return "Keep meals low in sodium and stay active with light walking today.";
      }
      if (conds.any((c) => c.contains('cholesterol'))) {
        return "Choose heart-healthy unsaturated fats and fiber-rich greens today.";
      }
    }

    // 3. Clinical Risk Flag recommendation (condensed to 1 concise sentence)
    if (_riskAssessment != null && _riskAssessment!.riskFlags.isNotEmpty) {
      final flag = _riskAssessment!.riskFlags.first;
      final raw = flag.recommendation.isNotEmpty ? flag.recommendation : flag.description;
      if (raw.isNotEmpty) {
        final parts = raw.split(RegExp(r'\.|\n'));
        final firstSentence = parts.firstWhere((p) => p.trim().isNotEmpty, orElse: () => raw).trim();
        if (firstSentence.length > 85) {
          final commaIdx = firstSentence.indexOf(',');
          if (commaIdx > 25 && commaIdx < 70) {
            return "${firstSentence.substring(0, commaIdx)}. Stay consistent!";
          }
          return "${firstSentence.substring(0, 80).trim()}...";
        }
        return "$firstSentence.";
      }
    }

    // 4. Goal-based default
    if (profile?.goal != null && profile!.goal!.isNotEmpty) {
      final goal = profile.goal!.toLowerCase();
      if (goal.contains('weight') || goal.contains('loss')) {
        return "Prioritize nutrient-dense foods and stay active to support your deficit.";
      }
      if (goal.contains('muscle') || goal.contains('gain')) {
        return "Pair your training with adequate protein and hydration today.";
      }
    }

    return "Maintain consistent hydration and balanced macros to optimize your health.";
  }

  String get aiInsightText => getShortAiInsight();

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
