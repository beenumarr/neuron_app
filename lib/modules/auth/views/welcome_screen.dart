import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_illustrations.dart';
import '../../../core/widgets/app_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            NoriBrandLockup(iconSize: 34, fontSize: 24, spacing: 8),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Floating Illustration Area
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: const WelcomeIllustrationWidget(
                                width: 300,
                                height: 230,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Copy & Action Buttons
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Clinical trust.\nHuman warmth.',
                              textAlign: TextAlign.center,
                              style: AppTypography.heading1.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Nori is an AI dietitian that reads your health context, understands the food in front of you, and answers in plain language.',
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Brand Trait Chips (From v2 Guidelines)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: const [
                                _WelcomeTraitChip(label: 'Trusted'),
                                _WelcomeTraitChip(label: 'Intelligent'),
                                _WelcomeTraitChip(label: 'Warm'),
                                _WelcomeTraitChip(label: 'Never scolding'),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Get Started Button (Pill .p1)
                            AppButton(
                              text: 'Get Started',
                              onPressed: () => context.go('/onboarding'),
                            ),
                            const SizedBox(height: 12),

                            // Already have an account Button (Pill .p3 / outline)
                            AppButton(
                              text: 'I already have an account',
                              variant: AppButtonVariant.outline,
                              onPressed: () => context.go('/login'),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeTraitChip extends StatelessWidget {
  final String label;
  const _WelcomeTraitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.teal,
        ),
      ),
    );
  }
}
