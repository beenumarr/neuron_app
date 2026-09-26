import 'meal_model.dart';

class PaginatedMealsModel {
  final List<MealModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  PaginatedMealsModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;

  factory PaginatedMealsModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List<dynamic>? ?? [];
    return PaginatedMealsModel(
      items: list.map((i) => MealModel.fromJson(i as Map<String, dynamic>)).toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );
  }

  factory PaginatedMealsModel.empty() {
    return PaginatedMealsModel(
      items: [],
      total: 0,
      page: 1,
      pageSize: 20,
      totalPages: 1,
    );
  }
}
