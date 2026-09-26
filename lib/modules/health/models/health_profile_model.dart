class HealthProfileModel {
  final String id;
  final String userId;
  final String? name;
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final List<String> conditions;
  final List<String> allergies;
  final List<String> dietaryPreferences;
  final String? goal;
  final bool onboardingComplete;
  final double? bmi;
  final String? bmiCategory;

  HealthProfileModel({
    required this.id,
    required this.userId,
    this.name,
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.conditions = const [],
    this.allergies = const [],
    this.dietaryPreferences = const [],
    this.goal,
    this.onboardingComplete = false,
    this.bmi,
    this.bmiCategory,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    return HealthProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      weightKg: json['weight_kg'] != null ? (json['weight_kg'] as num).toDouble() : null,
      heightCm: json['height_cm'] != null ? (json['height_cm'] as num).toDouble() : null,
      conditions: (json['conditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dietaryPreferences: (json['dietary_preferences'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      goal: json['goal'] as String?,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      bmiCategory: json['bmi_category'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'age': age,
        'gender': gender,
        'weight_kg': weightKg,
        'height_cm': heightCm,
        'conditions': conditions,
        'allergies': allergies,
        'dietary_preferences': dietaryPreferences,
        'goal': goal,
        'onboarding_complete': onboardingComplete,
        'bmi': bmi,
        'bmi_category': bmiCategory,
      };
}
