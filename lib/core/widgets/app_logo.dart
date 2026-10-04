import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum NoriLogoVariant {
  /// Symbol with rounded clean white container, crisp border and soft shadow
  contained,

  /// Standalone transparent Nori Green emblem
  standalone,

  /// Standalone for dark backgrounds
  standaloneOnDark,
}

/// Nori Brand Logo.
///
/// Stylized organic leaf-ribbon 'N' with floating leaf mark in Nori Emerald Green.
class AppLogo extends StatelessWidget {
  final double size;
  final NoriLogoVariant variant;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 64,
    this.variant = NoriLogoVariant.contained,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == NoriLogoVariant.contained) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.26),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
          border: Border.all(
            color: AppColors.line.withValues(alpha: 0.8),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.all(size * 0.12),
        child: Image.asset(
          'assets/images/logo_emblem.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/logo_emblem.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Full brand lockup: Symbol + "nori" wordmark in Sora ExtraBold all-lowercase.
class NoriBrandLockup extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color? textColor;
  final NoriLogoVariant logoVariant;
  final double spacing;

  const NoriBrandLockup({
    super.key,
    this.iconSize = 44,
    this.fontSize = 32,
    this.textColor,
    this.logoVariant = NoriLogoVariant.contained,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppLogo(size: iconSize, variant: logoVariant),
        SizedBox(width: spacing),
        Text(
          'nori',
          style: GoogleFonts.sora(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.02 * fontSize,
            color: textColor ?? AppColors.ink,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
