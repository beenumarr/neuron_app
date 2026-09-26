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
  int? _age = 26;
  String _gender = 'male';
  double? _weightKg = 72.0;
  double? _heightCm = 175.0;
  final Set<String> _selectedConditions = {};
  final Set<String> _selectedAllergies = {};
  final Set<String> _selectedDietaryPreferences = {};
  String _selectedGoal = 'Improve Energy & Health';

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
  Set<String> get selectedConditions => _selectedConditions;
  Set<String> get selectedAllergies => _selectedAllergies;
  Set<String> get selectedDietaryPreferences => _selectedDietaryPreferences;
  String get selectedGoal => _selectedGoal;

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

  void toggleCondition(String condition) {
    if (_selectedConditions.contains(condition)) {
      _selectedConditions.remove(condition);
    } else {
      _selectedConditions.add(condition);
    }
    notifyListeners();
  }

  void toggleDiet(String diet) {
    if (_selectedDietaryPreferences.contains(diet)) {
      _selectedDietaryPreferences.remove(diet);
    } else {
      _selectedDietaryPreferences.add(diet);
    }
    notifyListeners();
  }

  void setGoal(String goal) {
    _selectedGoal = goal;
    notifyListeners();
  }

  Future<bool> submitOnboarding() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = OnboardingPayload(
        name: _name.isNotEmpty ? _name : 'Alex Johnson',
        age: _age ?? 26,
        gender: _gender,
        weightKg: _weightKg ?? 72.0,
        heightCm: _heightCm ?? 175.0,
        conditions: _selectedConditions.toList(),
        allergies: _selectedAllergies.toList(),
        dietaryPreferences: _selectedDietaryPreferences.toList(),
        goal: _selectedGoal,
      );

      final profile = await healthApiService.completeOnboarding(payload);
      authController.updateHealthProfile(profile);

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
}
