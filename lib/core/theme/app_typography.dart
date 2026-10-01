import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Nori Brand Guidelines v2 Typography.
///
/// Headlines, titles, and key numbers: Sora (weights 500, 700, 800).
/// Body, subtitles, buttons, chips, and UI text: Inter (weights 400, 500, 600).
class AppTypography {
  // ── Display, Titles & Headings (Sora) ──────────────────────────────────────

  /// Large display headline — Sora 800
  static TextStyle get display => GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: AppColors.ink,
        height: 1.1,
      );

  /// Main page title — Sora 800
  static TextStyle get heading1 => GoogleFonts.sora(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.ink,
        height: 1.15,
      );

  /// Section heading — Sora 700
  static TextStyle get heading2 => GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.ink,
        height: 1.2,
      );

  /// Card or sub-section title — Sora 700
  static TextStyle get title => GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.ink,
      );

  /// Wordmark: Sora ExtraBold, all lowercase, tight tracking (-2%)
  static TextStyle get wordmark => GoogleFonts.sora(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.ink,
        height: 1.0,
      );

  /// Hero numbers / key figures — Sora 800 in Nori Green or Deep Teal
  static TextStyle get numberDisplay => GoogleFonts.sora(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: AppColors.green,
        height: 1.0,
      );

  static TextStyle get numberHero => GoogleFonts.sora(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.teal,
        height: 1.0,
      );

  // ── Body & UI Text (Inter) ─────────────────────────────────────────────────

  /// Subtitle — Inter 500, 15px
  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.mute,
        height: 1.5,
      );

  /// Primary body copy — Inter 400, 16px, 1.6 leading
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.mute,
        height: 1.6,
      );

  /// Emphasized body copy — Inter 600
  static TextStyle get bodyBold => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  /// Action buttons — Inter 600, 15px
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0.1,
      );

  /// Secondary button text — Inter 600, 15px
  static TextStyle get buttonSecondary => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.teal,
        letterSpacing: 0.1,
      );

  /// Caption text — Inter 500, 12px
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.mute,
      );

  /// Form / Section labels — Inter 600, 12px uppercase tracking
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.green,
      );

  /// Chips / Tag pills — Inter 600, 13px
  static TextStyle get chip => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  /// Smallest metadata text — Inter 500, 11px
  static TextStyle get micro => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );
}
