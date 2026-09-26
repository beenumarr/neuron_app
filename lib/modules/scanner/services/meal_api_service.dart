import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/meal_model.dart';

class MealApiService {
  final ApiClient apiClient;

  MealApiService({required this.apiClient});

  Future<List<MealModel>> getTodayMeals() async {
    final response = await apiClient.get<List<MealModel>>(
      ApiEndpoints.scannerMealsToday,
      parser: (data) {
        if (data is List) {
          return data
              .map((item) => MealModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <MealModel>[];
      },
    );
    return response.data ?? [];
  }

  Future<List<MealModel>> getMealsHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['start_date'] =
          '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      queryParams['end_date'] =
          '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    }

    final response = await apiClient.get<List<MealModel>>(
      ApiEndpoints.scannerMealsHistory,
      queryParameters: queryParams,
      parser: (data) {
        if (data is Map && data['items'] is List) {
          return (data['items'] as List)
              .map((item) => MealModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((item) => MealModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <MealModel>[];
      },
    );
    return response.data ?? [];
  }

  Future<MealModel> logMealManual({
    required String mealType,
    required String name,
    required double calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    String? quantity,
  }) async {
    final itemMap = <String, dynamic>{
      'name': name,
      'calories': calories,
    };
    if (proteinG != null) itemMap['protein_g'] = proteinG;
    if (carbsG != null) itemMap['carbs_g'] = carbsG;
    if (fatG != null) itemMap['fat_g'] = fatG;
    if (quantity != null) itemMap['quantity'] = quantity;

    final payload = {
      'meal_type': mealType.toLowerCase(),
      'items': [itemMap],
    };

    final response = await apiClient.post<MealModel>(
      ApiEndpoints.scannerLogMeal,
      data: payload,
      parser: (data) => MealModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }
}
