import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
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


  void _showPolicyModal(BuildContext context, {required String title, required String body}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  body,
                  style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTerms(BuildContext context) {
    _showPolicyModal(
      context,
      title: "Terms of Service",
      body: "Welcome to NORI.\n\n"
          "1. ACCEPTANCE OF TERMS\n"
          "By creating an account, you agree to these Terms of Service. NORI provides AI-assisted nutrition and wellness guidance.\n\n"
          "2. MEDICAL DISCLAIMER\n"
          "NORI is NOT a medical device and does not provide formal medical diagnosis or treatment. Always consult licensed healthcare providers for clinical emergencies or medical conditions.\n\n"
          "3. USER RESPONSIBILITIES\n"
          "You agree to provide accurate information and keep your credentials secure.\n\n"
          "4. PRIVACY & DATA USE\n"
          "Your health information is handled securely according to our Privacy Policy.",
    );
  }

  void _showPrivacy(BuildContext context) {
    _showPolicyModal(
      context,
      title: "Privacy Policy",
      body: "NORI Privacy Policy\n\n"
          "1. INFORMATION WE COLLECT\n"
          "We collect registration details, biometric measurements (weight, height, age), chronic conditions, dietary preferences, and meal logs to personalize your nutritional recommendations.\n\n"
          "2. HOW WE USE YOUR DATA\n"
          "Your data is used solely to generate tailored nutritional plans, track dietary progress, and personalize AI assistance.\n\n"
          "3. DATA SECURITY & OWNERSHIP\n"
          "Your health data belongs to you. We employ industry-standard encryption and never sell your personal health records to third parties.",
    );
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
              // Top Bar (Back button)
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
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
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
                          const Icon(LucideIcons.alertCircle, color: AppColors.danger, size: 20),
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
                          ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
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
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () => _showTerms(context),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () => _showPrivacy(context),
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
