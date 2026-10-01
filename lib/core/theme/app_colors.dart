import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Palette (NORI Brand Guide V1) ──────────────────────────────────

  /// Terracotta — primary action colour.
  /// Use for buttons, CTAs, primary fills, icons, and large type.
  static const Color brand = Color(0xFFC67139);

  /// Deep Terracotta (accent-700) — for terracotta-coloured *paragraph text*.
  /// The base tone (#C67139) is for fills, icons, and large type only.
  static const Color brandDark = Color(0xFF9E5A2D);

  /// Terracotta at 12 % opacity — subtle highlights, active-state tints.
  static const Color brandLight = Color(0x1FC67139);

  /// Terracotta glow — button shadows, focus rings.
  static const Color brandGlow = Color(0x40C67139);

  // ── Second Voice ─────────────────────────────────────────────────────────

  /// Sage — second voice colour.
  /// Used for progress rings, confirmations, and calm parts of the interface.
  static const Color sage = Color(0xFF7A8A5E);

  /// Sage at 12 % opacity.
  static const Color sageLight = Color(0x1F7A8A5E);

  // ── Legacy aliases (so existing code compiles during migration) ─────────
  static const Color indigo = sage;
  static const Color indigoLight = sageLight;
  static const Color orange = Color(0xFFD4924A); // warm amber variant
  static const Color orangeLight = Color(0x1FD4924A);

  static const Color purple = Color(0xFF9E7A5E); // warm muted brown (was #8B5CF6)
  static const Color purpleLight = Color(0x1F9E7A5E);
  static const Color sky = Color(0xFF7A8A5E); // sage stands in for water / calm

  // ── Functional colours ───────────────────────────────────────────────────
  static const Color danger = Color(0xFFCB4040);
  static const Color dangerLight = Color(0x1FCB4040);
  static const Color rose = danger;
  static const Color roseLight = dangerLight;

  // ── Neutrals & Surfaces ─────────────────────────────────────────────────

  /// Cream — page background / scaffold ground colour.
  static const Color backgroundPage = Color(0xFFF5EAD8);

  /// Sand — card and panel surfaces (warmer than cream).
  static const Color backgroundCard = Color(0xFFFBF5EC);

  /// Elevated surface — same as Sand for cards.
  static const Color surfaceElevated = Color(0xFFFBF5EC);

  /// Border colour — warm neutral.
  static const Color border = Color(0xFFE0D5C4);

  /// Focused border — terracotta.
  static const Color borderFocused = Color(0xFFC67139);

  /// Divider — matches border.
  static const Color divider = Color(0xFFE0D5C4);

  // ── Typography ──────────────────────────────────────────────────────────

  /// Ink — primary reading text, dark tiles.
  static const Color textPrimary = Color(0xFF2A2118);

  /// Secondary text — warm grey.
  static const Color textSecondary = Color(0xFF7A7062);

  /// Muted text — lighter warm grey.
  static const Color textMuted = Color(0xFFA89E92);

  /// White text — for on-primary surfaces.
  static const Color textWhite = Color(0xFFFFFFFF);

  // ── Gradients ───────────────────────────────────────────────────────────
  // Brand guide favours solid fills, but a subtle warm gradient is kept
  // for primary buttons.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brandDark],
  );
}
