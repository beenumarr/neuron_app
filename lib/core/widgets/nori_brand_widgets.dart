import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum NoriChipStatus { onTarget, closeToLimit, overTarget }

/// Status chip component matching Nori v2 guidelines:
/// - On target: background #DDF4EA, text #0B4F4A
/// - Close to limit: background #FDF0D5, text #6B4300
/// - Over target: background #FBE3DF, text #8A2A1C
class NoriStatusChip extends StatelessWidget {
  final String label;
  final NoriChipStatus status;
  final IconData? icon;

  const NoriStatusChip({
    super.key,
    required this.label,
    required this.status,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case NoriChipStatus.onTarget:
        bg = AppColors.statusOnTargetBg;
        fg = AppColors.statusOnTargetText;
        break;
      case NoriChipStatus.closeToLimit:
        bg = AppColors.statusCloseToLimitBg;
        fg = AppColors.statusCloseToLimitText;
        break;
      case NoriChipStatus.overTarget:
        bg = AppColors.statusOverTargetBg;
        fg = AppColors.statusOverTargetText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nori AI Answer Card matching the Brand Guidelines v2 specification:
///
/// Mint background, 16px radius, Amber AI node indicator, Deep Teal title, Ink text.
class NoriAiAnswerCard extends StatelessWidget {
  final String title;
  final String content;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const NoriAiAnswerCard({
    super.key,
    this.title = 'Nori measured against your profile',
    required this.content,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.12), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Single Amber AI Node
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.inter(
              color: AppColors.ink,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Where we stop" Disclaimer Card.
///
/// "Nori is a decision-support and education tool, not a medical replacement or diagnostic system.
/// Shown on first run, in the health profile, and on every exported report."
class NoriDisclaimerCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const NoriDisclaimerCard({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nori is a decision-support and education tool, not a medical replacement or diagnostic system.',
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nori never diagnoses, prescribes or treats, and refers people to a clinician when a question crosses that line.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.ink,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
