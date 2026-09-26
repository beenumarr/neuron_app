import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/health_profile_model.dart';
import '../models/onboarding_payload.dart';

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
}
