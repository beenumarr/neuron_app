import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// NORI Brand Guide typography.
///
/// Caprasimo — carries the name, page titles, and the one big number on a
/// screen.  Figtree — does everything else, including all figures.
/// "A nutrition panel should read like a note, not a receipt."
class AppTypography {
  // ── Display & Headings (Caprasimo) ──────────────────────────────────────

  static TextStyle get display => GoogleFonts.caprasimo(
        fontSize: 32,
        fontWeight: FontWeight.w400, // Caprasimo ships in Regular only
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  static TextStyle get heading1 => GoogleFonts.caprasimo(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
        height: 1.15,
      );

  static TextStyle get heading2 => GoogleFonts.caprasimo(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get title => GoogleFonts.caprasimo(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  // ── Body & UI text (Figtree) ────────────────────────────────────────────

  static TextStyle get subtitle => GoogleFonts.figtree(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get body => GoogleFonts.figtree(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      );

  static TextStyle get bodyBold => GoogleFonts.figtree(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get button => GoogleFonts.figtree(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        letterSpacing: 0.1,
      );

  static TextStyle get caption => GoogleFonts.figtree(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => GoogleFonts.figtree(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      );

  static TextStyle get micro => GoogleFonts.figtree(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );
}
