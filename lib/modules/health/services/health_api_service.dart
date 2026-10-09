import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/health_profile_model.dart';
import '../models/onboarding_payload.dart';
import '../models/risk_assessment_model.dart';

class HealthApiService {
  final ApiClient apiClient;

  HealthApiService({required this.apiClient});

  Future<HealthProfileModel> completeOnboarding(OnboardingPayload payload) async {
    final response = await apiClient.post<HealthProfileModel>(
      ApiEndpoints.healthOnboarding,
      data: payload.toJson(),
      parser: (data) => HealthProfileModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<HealthProfileModel> getProfile() async {
    final response = await apiClient.get<HealthProfileModel>(
      ApiEndpoints.healthProfile,
      parser: (data) => HealthProfileModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<HealthProfileModel> updateProfile(Map<String, dynamic> updates) async {
    final response = await apiClient.put<HealthProfileModel>(
      ApiEndpoints.healthProfile,
      data: updates,
      parser: (data) => HealthProfileModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<RiskAssessmentModel> getRiskAssessment() async {
    final response = await apiClient.get<RiskAssessmentModel>(
      ApiEndpoints.healthRiskAssessment,
      parser: (data) => RiskAssessmentModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> getMeasurements({String? measurementType}) async {
    final query = measurementType != null ? '?measurement_type=$measurementType' : '';
    final response = await apiClient.get<List<dynamic>>(
      '${ApiEndpoints.healthMeasurements}$query',
      parser: (data) => data as List<dynamic>,
    );
    return response.data?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
  }

  Future<void> recordMeasurement({
    required String measurementType,
    required double value,
    required String unit,
  }) async {
    await apiClient.post(
      ApiEndpoints.healthMeasurements,
      data: {
        'measurement_type': measurementType,
        'value': value,
        'unit': unit,
      },
    );
  }
}
