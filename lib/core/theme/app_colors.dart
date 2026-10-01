import 'package:flutter/material.dart';

/// Nori Brand Guidelines v2 Palette.
///
/// Deep teal carries trust and clinical credibility.
/// Nori green is the living, growing colour of nutrition and agriculture.
/// Amber is reserved for AI moments and gentle attention, never alarm.
/// Mint provides soft fills, panels, and active states.
/// Clean white is the primary ground.
/// Ink is the primary text color and dark mode ground.
class AppColors {
  // ── Core Brand Palette (v2) ────────────────────────────────────────────────

  /// Deep Teal — #0B4F4A. Primary, headers, buttons.
  static const Color teal = Color(0xFF0B4F4A);

  /// Nori Green — #16A37F. Progress, success, accents.
  static const Color green = Color(0xFF16A37F);

  /// Mint — #DDF4EA. Panels, soft fills, active state backgrounds.
  static const Color mint = Color(0xFFDDF4EA);

  /// Signal Amber — #F2A93B. AI node, highlights, gentle attention.
  static const Color amber = Color(0xFFF2A93B);

  /// Coral — #E5604D. Over target, errors only.
  static const Color coral = Color(0xFFE5604D);

  /// Sky — #E6F1FA. Info, clinical notes, hydration.
  static const Color sky = Color(0xFFE6F1FA);

  /// Clean White — #F5FAF8. Ground / scaffold background.
  static const Color cleanWhite = Color(0xFFF5FAF8);

  /// Ink — #0A2E2C. Reading text, dark mode ground.
  static const Color ink = Color(0xFF0A2E2C);

  /// Mute — #4F6B68. Secondary text and subtitles.
  static const Color mute = Color(0xFF4F6B68);

  /// Line / Border — #D6E6E1. Thin 1px borders instead of heavy shadows.
  static const Color line = Color(0xFFD6E6E1);

  // ── Status Chip Palette (v2) ───────────────────────────────────────────────

  /// On target chip background (#DDF4EA) and text (#0B4F4A)
  static const Color statusOnTargetBg = Color(0xFFDDF4EA);
  static const Color statusOnTargetText = Color(0xFF0B4F4A);

  /// Close to limit chip background (#FDF0D5) and text (#6B4300)
  static const Color statusCloseToLimitBg = Color(0xFFFDF0D5);
  static const Color statusCloseToLimitText = Color(0xFF6B4300);

  /// Over target chip background (#FBE3DF) and text (#8A2A1C)
  static const Color statusOverTargetBg = Color(0xFFFBE3DF);
  static const Color statusOverTargetText = Color(0xFF8A2A1C);

  // ── Dark Mode Tokens (v2) ──────────────────────────────────────────────────

  static const Color darkBg = Color(0xFF071C1B);
  static const Color darkCard = Color(0xFF0D2B29);
  static const Color darkInk = Color(0xFFE8F5F1);
  static const Color darkMute = Color(0xFF9DBDB7);
  static const Color darkLine = Color(0xFF1C4440);
  static const Color darkMint = Color(0xFF123B35);
  static const Color darkSky = Color(0xFF14303F);

  // ── Aliases & Semantic Roles ───────────────────────────────────────────────

  /// Primary brand color = Deep Teal
  static const Color brand = teal;

  /// Dark variant = Ink
  static const Color brandDark = ink;

  /// Soft tint = Mint
  static const Color brandLight = mint;

  /// Brand glow / subtle focus tint
  static const Color brandGlow = Color(0x260B4F4A);

  /// Second voice = Nori Green
  static const Color sage = green;
  static const Color sageLight = mint;

  /// Legacy aliases
  static const Color indigo = teal;
  static const Color indigoLight = mint;
  static const Color orange = amber;
  static const Color orangeLight = Color(0x2EF2A93B);
  static const Color purple = mute;
  static const Color purpleLight = Color(0x1F4F6B68);

  /// Functional colors
  static const Color danger = coral;
  static const Color dangerLight = Color(0xFFFBE3DF);
  static const Color rose = coral;
  static const Color roseLight = Color(0xFFFBE3DF);

  // ── Neutrals & Surfaces ────────────────────────────────────────────────────

  /// Ground colour for pages: Clean White (#F5FAF8)
  static const Color backgroundPage = cleanWhite;
  static const Color scaffoldBackground = cleanWhite;

  /// Card surface: White (#FFFFFF)
  static const Color backgroundCard = Color(0xFFFFFFFF);

  /// Elevated surface
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Line / Border
  static const Color border = line;
  static const Color borderFocused = teal;
  static const Color divider = line;

  /// Status chip shorthands
  static const Color statusOnBg = statusOnTargetBg;
  static const Color statusOnText = statusOnTargetText;
  static const Color statusCloseBg = statusCloseToLimitBg;
  static const Color statusCloseText = statusCloseToLimitText;
  static const Color statusOverBg = statusOverTargetBg;
  static const Color statusOverText = statusOverTargetText;

  // ── Typography ─────────────────────────────────────────────────────────────

  /// Ink — #0A2E2C
  static const Color textPrimary = ink;

  /// Mute — #4F6B68
  static const Color textSecondary = mute;

  /// Muted / disabled text
  static const Color textMuted = Color(0xFF7A9692);

  /// White text
  static const Color textWhite = Color(0xFFFFFFFF);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, Color(0xFF073834)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, Color(0xFF0A3C38)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, Color(0xFF0F7A5E)],
  );

  static const LinearGradient mintSkyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint, sky],
  );
}
