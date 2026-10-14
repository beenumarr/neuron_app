class OnboardingPayload {
  final String? name;
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final List<String> conditions;
  final List<String> allergies;
  final List<String> dietaryPreferences;
  final String? goal;

  OnboardingPayload({
    this.name,
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.conditions = const [],
    this.allergies = const [],
    this.dietaryPreferences = const [],
    this.goal,
  });

  Map<String, dynamic> toJson() => {
        if (name != null && name!.isNotEmpty) 'name': name,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (weightKg != null) 'weight_kg': weightKg,
        if (heightCm != null) 'height_cm': heightCm,
        'conditions': conditions,
        'allergies': allergies,
        'dietary_preferences': dietaryPreferences,
        if (goal != null && goal!.isNotEmpty) 'goal': goal,
      };
}
