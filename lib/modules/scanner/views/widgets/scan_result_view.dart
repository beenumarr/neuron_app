import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../models/scan_result_model.dart';

class ScanResultView extends StatelessWidget {
  final ScanResultModel result;
  final Uint8List? imageBytes;
  final VoidCallback onLogMeal;
  final VoidCallback onAskAi;
  final VoidCallback onScanAnother;

  const ScanResultView({
    super.key,
    required this.result,
    this.imageBytes,
    required this.onLogMeal,
    required this.onAskAi,
    required this.onScanAnother,
  });

  Widget _buildMacroCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.mute,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Captured Image Thumbnail / Preview
          if (imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (result.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child: Image.network(
                  result.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.backgroundCard,
                    child: const Icon(LucideIcons.utensils, size: 48, color: AppColors.teal),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Food Name & Status Badge Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identified Food',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.mute,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.foodName,
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estimated 1 standard serving',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Nori Brand Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: result.verdictBgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result.verdictIcon,
                      size: 15,
                      color: result.verdictColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      result.verdictTitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: result.verdictColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 4 Nutritional Macro Cards
          Row(
            children: [
              Expanded(
                child: _buildMacroCard(
                  'Calories',
                  '${result.calories.round()}',
                  AppColors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard(
                  'Protein',
                  '${result.proteinG?.round() ?? 0}g',
                  AppColors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard(
                  'Carbs',
                  '${result.carbsG?.round() ?? 0}g',
                  AppColors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard(
                  'Fat',
                  '${result.fatG?.round() ?? 0}g',
                  AppColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons (Pill actions)
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Log Meal',
                  icon: const Icon(LucideIcons.check, size: 18, color: Colors.white),
                  onPressed: onLogMeal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: 'Ask Nori',
                  variant: AppButtonVariant.outline,
                  icon: const Icon(LucideIcons.messageCircle, size: 18, color: AppColors.teal),
                  onPressed: onAskAi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scan another button
          Center(
            child: TextButton.icon(
              onPressed: onScanAnother,
              icon: const Icon(LucideIcons.refreshCw, size: 15, color: AppColors.mute),
              label: Text(
                'Scan another food',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mute,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
