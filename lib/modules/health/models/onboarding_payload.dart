class OnboardingPayload {
  final String? name;
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final List<String> conditions;
  final String? diabetesType;
  final String? activityLevel;
  final String? state;
  final String? city;
  final String? lga;
  final String? area;
  final String? region;
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
    this.diabetesType,
    this.activityLevel,
    this.state,
    this.city,
    this.lga,
    this.area,
    this.region,
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
        if (diabetesType != null && diabetesType!.isNotEmpty)
          'diabetes_type': diabetesType,
        if (activityLevel != null && activityLevel!.isNotEmpty)
          'activity_level': activityLevel,
        if (state != null && state!.isNotEmpty) 'state': state,
        if (city != null && city!.isNotEmpty) 'city': city,
        if (lga != null && lga!.isNotEmpty) 'lga': lga,
        if (area != null && area!.isNotEmpty) 'area': area,
        if (region != null && region!.isNotEmpty) 'region': region,
        'allergies': allergies,
        'dietary_preferences': dietaryPreferences,
        if (goal != null && goal!.isNotEmpty) 'goal': goal,
      };
}
