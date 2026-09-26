import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/meal_model.dart';
import '../models/paginated_meals_model.dart';
import '../models/scan_result_model.dart';

class MealApiService {
  final ApiClient apiClient;

  MealApiService({required this.apiClient});

  /// Upload meal image to backend, perform AI identification, and get deterministic clinical verdict
  Future<ScanResultModel> analyseFoodImage({
    required Uint8List bytes,
    String filename = 'food_scan.jpg',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
        ),
      });

      final response = await apiClient.post<ScanResultModel>(
        ApiEndpoints.scannerAnalyse,
        data: formData,
        parser: (data) => ScanResultModel.fromJson(data as Map<String, dynamic>),
      );
      return response.data!;
    } catch (e) {
      debugPrint('[MealApiService] analyseFoodImage error: $e');
      rethrow;
    }
  }

  /// Log an analyzed food scan directly into patient's meal diary
  Future<MealModel> logMealFromScan({
    required String scanId,
    required String mealType,
    DateTime? loggedAt,
  }) async {
    try {
      final payload = <String, dynamic>{
        'meal_type': mealType.toLowerCase(),
        if (loggedAt != null) 'logged_at': loggedAt.toIso8601String(),
      };

      final response = await apiClient.post<MealModel>(
        ApiEndpoints.scannerLogMealFromScan(scanId),
        data: payload,
        parser: (data) => MealModel.fromJson(data as Map<String, dynamic>),
      );
      return response.data!;
    } catch (e) {
      debugPrint('[MealApiService] logMealFromScan error: $e');
      rethrow;
    }
  }

  /// Retrieve meals logged for today
  Future<List<MealModel>> getTodayMeals() async {
    try {
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
    } catch (e) {
      debugPrint('[MealApiService] getTodayMeals error: $e');
      return [];
    }
  }

  /// Retrieve paginated meal diary history with optional date filtering
  Future<PaginatedMealsModel> getMealsHistoryPaginated({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (startDate != null) {
        queryParams['start_date'] =
            '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      }
      if (endDate != null) {
        queryParams['end_date'] =
            '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      }

      final response = await apiClient.get<PaginatedMealsModel>(
        ApiEndpoints.scannerMealsHistory,
        queryParameters: queryParams,
        parser: (data) {
          if (data is Map<String, dynamic>) {
            return PaginatedMealsModel.fromJson(data);
          }
          return PaginatedMealsModel.empty();
        },
      );
      return response.data ?? PaginatedMealsModel.empty();
    } catch (e) {
      debugPrint('[MealApiService] getMealsHistoryPaginated error: $e');
      return PaginatedMealsModel.empty();
    }
  }

  /// Backward-compatible flat list fetcher
  Future<List<MealModel>> getMealsHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final paginated = await getMealsHistoryPaginated(
      startDate: startDate,
      endDate: endDate,
      page: 1,
      pageSize: 50,
    );
    return paginated.items;
  }

  /// Manually log a meal with itemized nutritional records
  Future<MealModel> logMealManual({
    required String mealType,
    required String name,
    required double calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    String? quantity,
    DateTime? loggedAt,
  }) async {
    try {
      final itemMap = <String, dynamic>{
        'name': name,
        'calories': calories,
      };
      if (proteinG != null) itemMap['protein_g'] = proteinG;
      if (carbsG != null) itemMap['carbs_g'] = carbsG;
      if (fatG != null) itemMap['fat_g'] = fatG;
      if (quantity != null) itemMap['quantity'] = quantity;

      final payload = <String, dynamic>{
        'meal_type': mealType.toLowerCase(),
        'items': [itemMap],
        if (loggedAt != null) 'logged_at': loggedAt.toIso8601String(),
      };

      final response = await apiClient.post<MealModel>(
        ApiEndpoints.scannerLogMeal,
        data: payload,
        parser: (data) => MealModel.fromJson(data as Map<String, dynamic>),
      );
      return response.data!;
    } catch (e) {
      debugPrint('[MealApiService] logMealManual error: $e');
      rethrow;
    }
  }
}
