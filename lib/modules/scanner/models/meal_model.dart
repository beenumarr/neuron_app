class MealItemModel {
  final String? id;
  final String name;
  final double calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final String? quantity;

  MealItemModel({
    this.id,
    required this.name,
    required this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.quantity,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      id: json['id']?.toString(),
      name: json['name'] as String? ?? 'Meal Item',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble(),
      carbsG: (json['carbs_g'] as num?)?.toDouble(),
      fatG: (json['fat_g'] as num?)?.toDouble(),
      quantity: json['quantity'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'calories': calories,
        if (proteinG != null) 'protein_g': proteinG,
        if (carbsG != null) 'carbs_g': carbsG,
        if (fatG != null) 'fat_g': fatG,
        if (quantity != null) 'quantity': quantity,
      };
}

class MealModel {
  final String id;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime loggedAt;
  final List<MealItemModel> items;

  MealModel({
    required this.id,
    required this.mealType,
    required this.loggedAt,
    this.items = const [],
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return MealModel(
      id: json['id']?.toString() ?? '',
      mealType: json['meal_type'] as String? ?? 'snack',
      loggedAt: json['logged_at'] != null
          ? DateTime.tryParse(json['logged_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      items: itemsList
          .map((i) => MealItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meal_type': mealType,
        'logged_at': loggedAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };

  double get totalCalories =>
      items.fold(0.0, (sum, item) => sum + item.calories);

  double get totalProtein =>
      items.fold(0.0, (sum, item) => sum + (item.proteinG ?? 0.0));

  double get totalCarbs =>
      items.fold(0.0, (sum, item) => sum + (item.carbsG ?? 0.0));

  double get totalFat =>
      items.fold(0.0, (sum, item) => sum + (item.fatG ?? 0.0));

  String get displayName {
    if (items.isNotEmpty) {
      return items.first.name;
    }
    return '${mealType[0].toUpperCase()}${mealType.substring(1)}';
  }

  String get emoji {
    final lowerName = displayName.toLowerCase();
    if (lowerName.contains('toast') || lowerName.contains('avocado') || lowerName.contains('egg')) {
      return '🥑';
    }
    if (lowerName.contains('salad') || lowerName.contains('chicken') || lowerName.contains('bowl')) {
      return '🥗';
    }
    if (lowerName.contains('shake') || lowerName.contains('smoothie') || lowerName.contains('drink') || lowerName.contains('coffee')) {
      return '🥤';
    }
    if (lowerName.contains('apple') || lowerName.contains('fruit') || lowerName.contains('banana')) {
      return '🍎';
    }
    if (lowerName.contains('rice') || lowerName.contains('curry') || lowerName.contains('soup') || lowerName.contains('dinner')) {
      return '🍲';
    }
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '🍳';
      case 'lunch':
        return '🥗';
      case 'dinner':
        return '🍽️';
      case 'snack':
      default:
        return '🥪';
    }
  }

  String get formattedTime {
    final hour = loggedAt.hour;
    final minute = loggedAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:$minute $period';
  }
}
