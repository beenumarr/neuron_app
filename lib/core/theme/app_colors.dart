import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color brand = Color(0xFF18B97A);
  static const Color brandDark = Color(0xFF129863);
  static const Color brandLight = Color(0x1F18B97A); // 12% opacity
  static const Color brandGlow = Color(0x4018B97A);

  // Accents
  static const Color indigo = Color(0xFF5E6CFF);
  static const Color indigoLight = Color(0x1F5E6CFF); // 12% opacity
  static const Color orange = Color(0xFFF5A524);
  static const Color orangeLight = Color(0x1FF5A524);
  static const Color danger = Color(0xFFFF5A5F);
  static const Color dangerLight = Color(0x1FFF5A5F);
  static const Color rose = danger;
  static const Color roseLight = dangerLight;
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0x1F8B5CF6);
  static const Color sky = Color(0xFF38BDF8);

  // Neutrals & Surfaces
  static const Color backgroundPage = Color(0xFFF7F9FC);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocused = Color(0xFF18B97A);
  static const Color divider = Color(0xFFE5E7EB);

  // Typography
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brandDark],
  );

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1AD28B), brandDark],
  );
}
