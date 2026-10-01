import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ── Habit Tracking: Water, Steps, Sleep (AI-Calibrated) ───────────────────
  int _waterCups = 0;
  double _waterTargetLiters = 2.5;
  String _waterAiReason = 'Calibrated by nori for standard metabolic and kidney baseline.';

  int _stepsCount = 0;
  int _stepsGoal = 8000;
  String _stepsAiReason = 'Calibrated by nori for daily cardiovascular and glucose baseline.';

  double _sleepHours = 0.0;
  double _sleepGoalHours = 8.0;
  String _sleepAiReason = 'Calibrated by nori for standard cellular recovery and immune maintenance.';

  // Water Getters
  int get waterCups => _waterCups;
  double get waterIntakeLiters => double.parse((_waterCups * 0.25).toStringAsFixed(2));
  double get waterTargetLiters => _waterTargetLiters;
  int get waterTargetCups => (_waterTargetLiters / 0.25).round();
  double get waterProgressPct =>
      _waterTargetLiters > 0 ? (waterIntakeLiters / _waterTargetLiters).clamp(0.0, 1.0) : 0.0;
  String get waterAiReason => _waterAiReason;

  // Steps Getters
  int get stepsCount => _stepsCount;
  int get stepsGoal => _stepsGoal;
  double get stepsProgressPct =>
      _stepsGoal > 0 ? (stepsCount / _stepsGoal).clamp(0.0, 1.0) : 0.0;
  String get stepsAiReason => _stepsAiReason;

  // Sleep Getters
  double get sleepHours => _sleepHours;
  double get sleepGoalHours => _sleepGoalHours;
  double get sleepProgressPct =>
      _sleepGoalHours > 0 ? (sleepHours / _sleepGoalHours).clamp(0.0, 1.0) : 0.0;
  String get sleepAiReason => _sleepAiReason;

  // Calibrate AI Targets from Profile
  void calibrateAiTargets(HealthProfileModel? profile) {
    if (profile == null) return;

    // 1. Water Calibration (Clinical benchmark: ~35ml/kg)
    if (profile.weightKg != null && profile.weightKg! > 0) {
      double base = (profile.weightKg! * 35) / 1000.0;
      final goal = profile.goal?.toLowerCase() ?? '';
      if (goal.contains('weight') || goal.contains('muscle') || goal.contains('energy') || goal.contains('active')) {
        base += 0.3;
      }
      _waterTargetLiters = double.parse(base.clamp(1.8, 3.8).toStringAsFixed(1));
      _waterAiReason = 'Calibrated by nori for your ${profile.weightKg!.round()}kg frame: 35ml/kg cellular hydration standard.';
    } else {
      _waterTargetLiters = 2.5;
      _waterAiReason = 'Calibrated by nori for balanced metabolic and kidney hydration.';
    }

    // 2. Steps Calibration (Conditions + Goals)
    final conditions = profile.conditions.map((c) => c.toLowerCase()).toList();
    final goal = profile.goal?.toLowerCase() ?? '';

    if (conditions.any((c) => c.contains('diabet') || c.contains('sugar') || c.contains('hypertens') || c.contains('pressure'))) {
      _stepsGoal = 8500;
      _stepsAiReason = 'Calibrated by nori to improve insulin sensitivity and lower arterial tension.';
    } else if (goal.contains('weight') || goal.contains('fat') || goal.contains('loss')) {
      _stepsGoal = 10000;
      _stepsAiReason = 'Calibrated by nori for sustained daily NEAT energy expenditure and fat oxidation.';
    } else if (goal.contains('muscle') || goal.contains('gain') || goal.contains('strength')) {
      _stepsGoal = 7500;
      _stepsAiReason = 'Calibrated by nori for conditioning without compromising muscle glycogen recovery.';
    } else if (goal.contains('heart') || conditions.any((c) => c.contains('cholesterol'))) {
      _stepsGoal = 9000;
      _stepsAiReason = 'Calibrated by nori for endothelial flexibility and lipid management.';
    } else {
      _stepsGoal = 8000;
      _stepsAiReason = 'Calibrated by nori for baseline metabolic vitality and steady circulation.';
    }

    // 3. Sleep Calibration (Recovery & Glycemic Control)
    if (conditions.any((c) => c.contains('hypertens') || c.contains('diabet') || c.contains('heart'))) {
      _sleepGoalHours = 8.0;
      _sleepAiReason = 'Calibrated by nori: 8.0 hrs restorative sleep reduces sympathetic tone & morning BP surges.';
    } else if (goal.contains('muscle') || goal.contains('strength')) {
      _sleepGoalHours = 8.5;
      _sleepAiReason = 'Calibrated by nori: 8.5 hrs maximizes growth hormone secretion during deep slow-wave sleep.';
    } else if (goal.contains('weight') || goal.contains('fat')) {
      _sleepGoalHours = 8.0;
      _sleepAiReason = 'Calibrated by nori: 8.0 hrs balances leptin and ghrelin to curb late-day appetite surges.';
    } else if (profile.age != null && profile.age! >= 60) {
      _sleepGoalHours = 7.5;
      _sleepAiReason = 'Calibrated by nori for restorative circadian rhythms and cognitive retention.';
    } else {
      _sleepGoalHours = 8.0;
      _sleepAiReason = 'Calibrated by nori for cellular DNA repair, neuro-clearing, and immune support.';
    }
  }

  String get _todayKey {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> loadHabits([HealthProfileModel? profile]) async {
    calibrateAiTargets(profile);
    try {
      final prefs = await SharedPreferences.getInstance();
      _waterCups = prefs.getInt('habits_water_$_todayKey') ?? 0;
      _stepsCount = prefs.getInt('habits_steps_$_todayKey') ?? 0;
      _sleepHours = prefs.getDouble('habits_sleep_$_todayKey') ?? 0.0;
      notifyListeners();
    } catch (e) {
      debugPrint('[HomeController] Error loading habits: $e');
    }
  }

  Future<void> addWaterCup() async {
    _waterCups = (_waterCups + 1).clamp(0, 24);
    notifyListeners();
    _saveHabit('habits_water_$_todayKey', _waterCups);
  }

  Future<void> removeWaterCup() async {
    if (_waterCups > 0) {
      _waterCups -= 1;
      notifyListeners();
      _saveHabit('habits_water_$_todayKey', _waterCups);
    }
  }

  Future<void> setWaterCups(int cups) async {
    _waterCups = cups.clamp(0, 24);
    notifyListeners();
    _saveHabit('habits_water_$_todayKey', _waterCups);
  }

  Future<void> addSteps(int delta) async {
    _stepsCount = (_stepsCount + delta).clamp(0, 60000);
    notifyListeners();
    _saveHabit('habits_steps_$_todayKey', _stepsCount);
  }

  Future<void> setSteps(int steps) async {
    _stepsCount = steps.clamp(0, 60000);
    notifyListeners();
    _saveHabit('habits_steps_$_todayKey', _stepsCount);
  }

  Future<void> addSleepMinutes(int minutes) async {
    _sleepHours = double.parse((_sleepHours + (minutes / 60.0)).clamp(0.0, 16.0).toStringAsFixed(1));
    notifyListeners();
    _saveHabitDouble('habits_sleep_$_todayKey', _sleepHours);
  }

  Future<void> setSleepHours(double hours) async {
    _sleepHours = double.parse(hours.clamp(0.0, 16.0).toStringAsFixed(1));
    notifyListeners();
    _saveHabitDouble('habits_sleep_$_todayKey', _sleepHours);
  }

  Future<void> _saveHabit(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (e) {
      debugPrint('[HomeController] Error saving habit $key: $e');
    }
  }

  Future<void> _saveHabitDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    } catch (e) {
      debugPrint('[HomeController] Error saving habit $key: $e');
    }
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

  Future<void> fetchDashboardData({HealthProfileModel? profile, bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    await loadHabits(profile);

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
