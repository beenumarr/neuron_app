import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/weekly_report_model.dart';

class ProgressApiService {
  final ApiClient apiClient;

  ProgressApiService({required this.apiClient});

  /// Retrieve the latest synthesized weekly clinical report
  Future<WeeklyReportModel?> getLatestWeeklyReport() async {
    try {
      final response = await apiClient.get<WeeklyReportModel>(
        ApiEndpoints.progressWeeklyReport,
        parser: (data) => WeeklyReportModel.fromJson(data as Map<String, dynamic>),
      );
      return response.data;
    } catch (e) {
      debugPrint('[ProgressApiService] getLatestWeeklyReport: $e');
      // If 404 not found, return null (meaning user has not generated a report yet)
      return null;
    }
  }

  /// Manually trigger immediate synthesis of a weekly progress report
  Future<WeeklyReportModel> generateWeeklyReportNow() async {
    try {
      final response = await apiClient.post<WeeklyReportModel>(
        ApiEndpoints.progressWeeklyGenerateNow,
        data: {},
        parser: (data) => WeeklyReportModel.fromJson(data as Map<String, dynamic>),
      );
      return response.data!;
    } catch (e) {
      debugPrint('[ProgressApiService] generateWeeklyReportNow error: $e');
      rethrow;
    }
  }
}
