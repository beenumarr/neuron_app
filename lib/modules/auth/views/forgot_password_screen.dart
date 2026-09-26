import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_illustrations.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    setState(() => _emailError = null);
    final authController = context.read<AuthController>();
    final resetToken = await authController.forgotPassword(email);

    if (mounted) {
      if (resetToken != null) {
        // Show success dialog with reset token and option to enter new password
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.mark_email_read_outlined, color: AppColors.brand, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Reset Link Generated',
                  style: AppTypography.heading2,
                ),
                const SizedBox(height: 8),
                Text(
                  'A password reset session has been issued for $email.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'Set New Password',
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.push('/reset-password?token=$resetToken');
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

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
                    Icons.arrow_back,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Shield Illustration
              const Center(
                child: ShieldIllustrationWidget(size: 150),
              ),
              const SizedBox(height: 24),

              // Title and Description
              Center(
                child: Text(
                  'Forgot Password?',
                  style: AppTypography.heading1.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Enter your email and we'll send you a password reset link.",
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),

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

              // Email input
              AppTextField(
                label: 'Email Address',
                placeholder: 'alex@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                suffix: const Icon(Icons.mail_outline, size: 20, color: AppColors.textMuted),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSendReset(),
              ),
              const SizedBox(height: 24),

              // Send Reset Link CTA
              AppButton(
                text: 'Send Reset Link',
                isLoading: authController.isLoading,
                onPressed: _handleSendReset,
              ),
              const SizedBox(height: 20),

              // Back to Sign In
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.arrow_back, size: 14, color: AppColors.textSecondary),
                  label: Text(
                    'Back to Sign In',
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
