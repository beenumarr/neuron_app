class RegisterPayload {
  final String email;
  final String password;
  final String role;

  RegisterPayload({
    required this.email,
    required this.password,
    this.role = 'patient',
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': role,
      };
}

class LoginPayload {
  final String email;
  final String password;
  final String? deviceInfo;

  LoginPayload({
    required this.email,
    required this.password,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'password': password,
        if (deviceInfo != null) 'device_info': deviceInfo,
      };
}

class ForgotPasswordPayload {
  final String email;

  ForgotPasswordPayload({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
      };
}

class ResetPasswordPayload {
  final String resetToken;
  final String newPassword;

  ResetPasswordPayload({
    required this.resetToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'reset_token': resetToken,
        'new_password': newPassword,
      };
}

class ChangePasswordPayload {
  final String currentPassword;
  final String newPassword;

  ChangePasswordPayload({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'current_password': currentPassword,
        'new_password': newPassword,
      };
}
