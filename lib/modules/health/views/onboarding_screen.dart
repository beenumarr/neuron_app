import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_illustrations.dart';
import '../../auth/controllers/auth_controller.dart';

class OnboardingStepItem {
  final String headline;
  final String description;

  const OnboardingStepItem({
    required this.headline,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const List<OnboardingStepItem> steps = [
    OnboardingStepItem(
      headline: 'Understand Your Health',
      description: 'Receive AI-powered insights based on your nutrition, habits, and health profile.',
    ),
    OnboardingStepItem(
      headline: 'Scan Any Meal',
      description: 'Instantly identify foods, calories, nutrients, and whether they are suitable for your health conditions.',
    ),
    OnboardingStepItem(
      headline: 'Chat With NORI',
      description: 'Ask questions about nutrition, medical conditions, healthy eating, or meal planning anytime.',
    ),
    OnboardingStepItem(
      headline: 'Track Your Progress',
      description: 'Monitor your goals, streaks, nutrition, health score, and daily improvements in one place.',
    ),
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentStep < OnboardingScreen.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboardingIntro();
    }
  }

  void _finishOnboardingIntro() {
    final authController = context.read<AuthController>();
    if (authController.isAuthenticated) {
      context.go('/onboarding-setup');
    } else {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCard,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _finishOnboardingIntro,
                    child: Text(
                      'Skip',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View with Illustrations & Texts
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingScreen.steps.length,
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                itemBuilder: (context, index) {
                  final stepData = OnboardingScreen.steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Illustration
                        Expanded(
                          flex: 6,
                          child: Center(
                            child: OnboardingIllustrationWidget(
                              step: index,
                              width: 290,
                              height: 240,
                            ),
                          ),
                        ),

                        // Text block
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  stepData.headline,
                                  key: ValueKey('headline_$index'),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.heading2.copyWith(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  stepData.description,
                                  key: ValueKey('desc_$index'),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body.copyWith(
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Pagination Dots & Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Pagination dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(OnboardingScreen.steps.length, (i) {
                      final isActive = i == _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.brand : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Next / Continue Button
                  AppButton(
                    text: _currentStep == OnboardingScreen.steps.length - 1
                        ? 'Continue'
                        : 'Next',
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
