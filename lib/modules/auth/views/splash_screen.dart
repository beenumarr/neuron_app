import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/widgets/app_button.dart";
import "../../../core/widgets/app_logo.dart";
import "../controllers/auth_controller.dart";

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isFailed = authController.hasRestorationFailed;

    return Scaffold(
      backgroundColor: AppColors.backgroundCard,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 88),
                const SizedBox(height: 24),
                Text(
                  "NORI",
                  style: GoogleFonts.sora(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Intelligent Nutrition & Health",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.mute,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                if (isFailed) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundPage,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.wifiOff, size: 28, color: AppColors.coral),
                        const SizedBox(height: 10),
                        Text(
                          "Network Connection Unavailable",
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "We could not reach the server to verify your session. You can retry or continue with cached data.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.mute,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: "Retry Connection",
                    icon: LucideIcons.refreshCw,
                    onPressed: () => authController.initialize(),
                  ),
                ] else ...[
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Restoring your secure session...",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.mute,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
