import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_illustrations.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  static const List<String> features = [
    'Nutrition Tracking',
    'AI Insights',
    'Meal Scanner',
    'Health Score',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCard,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Pulsing Green Checkmark
              const SuccessCheckmarkWidget(size: 112),
              const SizedBox(height: 32),

              // Headline & Description
              Text(
                "You're All Set!",
                style: AppTypography.heading1.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome to NORI. Your AI health companion is ready to help you achieve a healthier lifestyle.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 28),

              // Decorative feature pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.brandLight,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      feature,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(flex: 3),

              // Go to Dashboard Button
              AppButton(
                text: 'Go to Dashboard',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
