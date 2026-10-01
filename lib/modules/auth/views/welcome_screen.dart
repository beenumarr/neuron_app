import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_illustrations.dart';
import '../../../core/widgets/server_config_dialog.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCard,
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
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
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
                                  const Icon(LucideIcons.server, size: 14, color: AppColors.brandDark),
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
                        ),
                        const SizedBox(height: 8),
                        // Floating Illustration Area - gracefully expands or contracts
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: const WelcomeIllustrationWidget(
                                width: 300,
                                height: 240,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Copy & Action Buttons
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Meet Your Personal\nAI Health Assistant',
                              textAlign: TextAlign.center,
                              style: AppTypography.heading1.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Track nutrition, scan meals, monitor your health, and receive intelligent recommendations tailored specifically for you.',
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Get Started Button
                            AppButton(
                              text: 'Get Started',
                              onPressed: () => context.go('/onboarding'),
                            ),
                            const SizedBox(height: 12),

                            // Already have an account Button
                            TextButton(
                              onPressed: () => context.go('/login'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text(
                                'I already have an account',
                                style: AppTypography.bodyBold.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
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
