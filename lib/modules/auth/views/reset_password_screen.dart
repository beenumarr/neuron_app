import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? initialToken;

  const ResetPasswordScreen({super.key, this.initialToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _tokenController;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  int _strength = 0;
  String? _tokenError;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _calculateStrength(String pw) {
    int s = 0;
    if (pw.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(pw)) s++;
    if (RegExp(r'[0-9]').hasMatch(pw)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) s++;
    setState(() => _strength = s);
  }

  bool _validate() {
    setState(() {
      _tokenError = null;
      _passwordError = null;
      _confirmError = null;
    });

    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    bool isValid = true;
    if (token.isEmpty) {
      _tokenError = 'Reset token is required';
      isValid = false;
    }

    if (password.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
      isValid = false;
    } else if (!RegExp(r'[a-zA-Z]').hasMatch(password) || !RegExp(r'[0-9]').hasMatch(password)) {
      _passwordError = 'Password must contain at least one letter and one number';
      isValid = false;
    }

    if (confirm != password) {
      _confirmError = 'Passwords do not match';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleResetPassword() async {
    if (!_validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.resetPassword(
      resetToken: _tokenController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please sign in with your new password.'),
          backgroundColor: AppColors.brand,
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    final strengthLabels = ['Too short', 'Weak', 'Fair', 'Good', 'Strong'];
    final strengthColors = [
      AppColors.border,
      AppColors.danger,
      AppColors.orange,
      const Color(0xFF60A5FA),
      AppColors.brand,
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundCard,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/login');
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPage,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lock Icon container
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.brandLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.lock, size: 36, color: AppColors.brand),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title and Subtitle
              Center(
                child: Text(
                  'Create New Password',
                  style: AppTypography.heading1.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Make it strong and memorable.',
                  style: AppTypography.subtitle.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Error banner
              if (authController.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    authController.errorMessage!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Reset Token field
              AppTextField(
                label: 'Reset Token',
                placeholder: 'Paste the reset token here',
                controller: _tokenController,
                errorText: _tokenError,
              ),
              const SizedBox(height: 16),

              // New Password
              AppTextField(
                label: 'New Password',
                placeholder: 'Create a strong password',
                controller: _passwordController,
                isPassword: true,
                onChanged: _calculateStrength,
                errorText: _passwordError,
              ),

              // Password Strength Indicator bars
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: List.generate(4, (i) {
                    final isFilled = i < _strength;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: isFilled ? strengthColors[_strength] : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  strengthLabels[_strength],
                  style: AppTypography.micro.copyWith(
                    color: strengthColors[_strength],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Confirm Password
              AppTextField(
                label: 'Confirm Password',
                placeholder: 'Repeat your password',
                controller: _confirmController,
                isPassword: true,
                errorText: _confirmError,
                suffix: _confirmController.text.isNotEmpty &&
                        _confirmController.text == _passwordController.text
                    ? const Icon(LucideIcons.checkCircle, size: 20, color: AppColors.brand)
                    : null,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleResetPassword(),
              ),
              const SizedBox(height: 28),

              // CTA Button
              AppButton(
                text: 'Update Password',
                isLoading: authController.isLoading,
                onPressed: _handleResetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
