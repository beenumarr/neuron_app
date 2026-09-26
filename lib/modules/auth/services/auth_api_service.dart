import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/auth_payloads.dart';
import '../models/auth_tokens.dart';
import '../models/user_model.dart';

class AuthApiService {
  final ApiClient apiClient;

  AuthApiService({required this.apiClient});

  Future<UserModel> register(RegisterPayload payload) async {
    final response = await apiClient.post<UserModel>(
      ApiEndpoints.register,
      data: payload.toJson(),
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<AuthTokens> login(LoginPayload payload) async {
    final response = await apiClient.post<AuthTokens>(
      ApiEndpoints.login,
      data: payload.toJson(),
      parser: (data) => AuthTokens.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await apiClient.post<AuthTokens>(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
      parser: (data) => AuthTokens.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<void> logout(String refreshToken) async {
    try {
      await apiClient.post<void>(
        ApiEndpoints.logout,
        data: {'refresh_token': refreshToken},
      );
    } catch (_) {
      // Ignored: local logout will proceed anyway
    }
  }

  Future<UserModel> getMe() async {
    final response = await apiClient.get<UserModel>(
      ApiEndpoints.me,
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data!;
  }

  Future<String?> forgotPassword(String email) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      data: ForgotPasswordPayload(email: email).toJson(),
      parser: (data) => data as Map<String, dynamic>,
    );
    if (response.data != null && response.data!['reset_token'] != null) {
      return response.data!['reset_token'].toString();
    }
    return null;
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await apiClient.post<void>(
      ApiEndpoints.resetPassword,
      data: ResetPasswordPayload(
        resetToken: resetToken,
        newPassword: newPassword,
      ).toJson(),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.put<void>(
      ApiEndpoints.changePassword,
      data: ChangePasswordPayload(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ).toJson(),
    );
  }
}
