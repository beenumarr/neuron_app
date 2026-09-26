import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/server_config_dialog.dart';
import '../../../core/widgets/social_auth_button.dart';
import '../../health/controllers/onboarding_controller.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _agreeTerms = true;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    bool isValid = true;
    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!email.contains('@') || !email.contains('.')) {
      _emailError = 'Please enter a valid email address';
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

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Privacy Policy to continue')),
      );
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleRegister() async {
    if (!_validate()) return;

    final authController = context.read<AuthController>();
    final onboardingController = context.read<OnboardingController>();

    if (_nameController.text.trim().isNotEmpty) {
      onboardingController.setName(_nameController.text.trim());
    }

    final success = await authController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // User registered & logged in with valid JWT session -> proceed to biometric onboarding setup
      context.go('/onboarding-setup');
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
              // Top Bar (Back button + Server Settings)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/welcome');
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
                  GestureDetector(
                    onTap: () => ServerConfigDialog.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.dns_outlined, size: 14, color: AppColors.brandDark),
                          const SizedBox(width: 4),
                          Text(
                            'Server',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'Create Your Account',
                style: AppTypography.heading1.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Let's begin your personalized health journey.",
                style: AppTypography.subtitle.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authController.errorMessage!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (authController.errorMessage!.toLowerCase().contains('server') ||
                          authController.errorMessage!.toLowerCase().contains('timed out') ||
                          authController.errorMessage!.toLowerCase().contains('connection')) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => ServerConfigDialog.show(context),
                          child: Text(
                            'Change backend server URL (${AppConfig.baseUrl}) ->',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.brandDark,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Form fields
              AppTextField(
                label: 'Full Name',
                placeholder: 'Alex Johnson',
                controller: _nameController,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Email Address',
                placeholder: 'alex@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Password',
                placeholder: 'At least 8 characters (letters + numbers)',
                controller: _passwordController,
                isPassword: true,
                errorText: _passwordError,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Confirm Password',
                placeholder: 'Repeat your password',
                controller: _confirmController,
                isPassword: true,
                errorText: _confirmError,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: 18),

              // Terms Agreement Checkbox
              GestureDetector(
                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _agreeTerms ? AppColors.brand : AppColors.backgroundPage,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _agreeTerms ? AppColors.brand : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: _agreeTerms
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms and Privacy Policy',
                              style: TextStyle(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Create Account CTA Button
              AppButton(
                text: 'Create Account',
                isLoading: authController.isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 20),

              // Social Auth Buttons
              Row(
                children: [
                  SocialAuthButton.google(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Google Sign-In ready')),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  SocialAuthButton.apple(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Apple Sign-In ready')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Footer: Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Sign In',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
