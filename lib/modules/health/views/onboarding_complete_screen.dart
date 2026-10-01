import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_illustrations.dart';
import '../../../core/widgets/nori_brand_widgets.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  static const List<String> features = [
    'Nutrition Tracking',
    'AI Decision Support',
    'Meal Scanner',
    'Clinical Health Score',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated Pulsing Green Checkmark
              const SuccessCheckmarkWidget(size: 104),
              const SizedBox(height: 28),

              // Headline & Description
              Text(
                "You're all set!",
                style: GoogleFonts.sora(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome to nori. Your AI nutrition companion is calibrated to your profile to provide calm, personalized, and clinical dietary guidance.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.mute,
                ),
              ),
              const SizedBox(height: 24),

              // Decorative feature pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      feature,
                      style: GoogleFonts.inter(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(flex: 2),

              // "Where we stop" Clinical Disclaimer
              const NoriDisclaimerCard(),
              const SizedBox(height: 20),

              // Go to Dashboard Button
              AppButton(
                title: 'Go to Dashboard',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
