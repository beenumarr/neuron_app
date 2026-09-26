import 'package:flutter/foundation.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/onboarding_payload.dart';
import '../services/health_api_service.dart';

class OnboardingController extends ChangeNotifier {
  final HealthApiService healthApiService;
  final AuthController authController;

  bool _isLoading = false;
  String? _errorMessage;

  // Onboarding Biometric Form State
  String _name = '';
  int? _age = 30;
  String _gender = 'male';
  double? _weightKg = 70.0;
  double? _heightCm = 170.0;

  final Set<String> _selectedGoals = {'Eat healthier'};
  final Set<String> _selectedConditions = {};
  final Set<String> _selectedAllergies = {};
  final Set<String> _selectedDietaryPreferences = {'No restrictions'};
  String _activityLevel = 'Moderate';

  OnboardingController({
    required this.healthApiService,
    required this.authController,
  });

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get name => _name;
  int? get age => _age;
  String get gender => _gender;
  double? get weightKg => _weightKg;
  double? get heightCm => _heightCm;

  Set<String> get selectedGoals => _selectedGoals;
  Set<String> get selectedConditions => _selectedConditions;
  Set<String> get selectedAllergies => _selectedAllergies;
  Set<String> get selectedDietaryPreferences => _selectedDietaryPreferences;
  String get activityLevel => _activityLevel;

  double? get calculatedBmi {
    if (_weightKg != null && _heightCm != null && _heightCm! > 0) {
      final hM = _heightCm! / 100.0;
      return double.parse((_weightKg! / (hM * hM)).toStringAsFixed(1));
    }
    return null;
  }

  String get bmiCategory {
    final bmi = calculatedBmi;
    if (bmi == null) return 'Normal weight';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obesity';
  }

  void setName(String val) {
    _name = val;
    notifyListeners();
  }

  void setAge(int? val) {
    _age = val;
    notifyListeners();
  }

  void setGender(String val) {
    _gender = val;
    notifyListeners();
  }

  void setWeight(double? val) {
    _weightKg = val;
    notifyListeners();
  }

  void setHeight(double? val) {
    _heightCm = val;
    notifyListeners();
  }

  void toggleGoal(String goal) {
    if (_selectedGoals.contains(goal)) {
      if (_selectedGoals.length > 1) {
        _selectedGoals.remove(goal);
      }
    } else {
      _selectedGoals.add(goal);
    }
    notifyListeners();
  }

  void toggleCondition(String condition) {
    if (condition == 'None') {
      _selectedConditions.clear();
      _selectedConditions.add('None');
    } else {
      _selectedConditions.remove('None');
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    }
    notifyListeners();
  }

  void clearConditions() {
    _selectedConditions.clear();
    _selectedConditions.add('None');
    notifyListeners();
  }

  void toggleDiet(String diet) {
    if (diet == 'No restrictions') {
      _selectedDietaryPreferences.clear();
      _selectedDietaryPreferences.add('No restrictions');
    } else {
      _selectedDietaryPreferences.remove('No restrictions');
      if (_selectedDietaryPreferences.contains(diet)) {
        _selectedDietaryPreferences.remove(diet);
      } else {
        _selectedDietaryPreferences.add(diet);
      }
    }
    notifyListeners();
  }

  void clearDiets() {
    _selectedDietaryPreferences.clear();
    _selectedDietaryPreferences.add('No restrictions');
    notifyListeners();
  }

  void setActivityLevel(String level) {
    _activityLevel = level;
    notifyListeners();
  }

  Future<bool> submitOnboarding() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userName = _name.isNotEmpty
          ? _name
          : (authController.currentUser?.email.split('@').first ?? 'User');

      final activeConditions = _selectedConditions
          .where((c) => c != 'None')
          .toList();

      final activeDiets = _selectedDietaryPreferences
          .where((d) => d != 'No restrictions')
          .toList();

      final activeGoal = _selectedGoals.isNotEmpty
          ? _selectedGoals.join(', ')
          : 'Healthy Living';

      final payload = OnboardingPayload(
        name: userName,
        age: _age ?? 30,
        gender: _gender.toLowerCase(),
        weightKg: _weightKg ?? 70.0,
        heightCm: _heightCm ?? 170.0,
        conditions: activeConditions,
        allergies: _selectedAllergies.toList(),
        dietaryPreferences: activeDiets,
        goal: activeGoal,
      );

      final profile = await healthApiService.completeOnboarding(payload);
      authController.updateHealthProfile(profile);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[OnboardingController] submitOnboarding error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
