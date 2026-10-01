import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
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
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
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
          // Captured Image Thumbnail / Cloudinary Preview
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
                    child: const Icon(LucideIcons.utensils, size: 48, color: AppColors.brand),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Food Name & Clinical Verdict Badge Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Identified Food',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.foodName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Estimated 1 standard serving',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Deterministic Clinical Verdict Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: result.verdictBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: result.verdictColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      result.verdictIcon,
                      size: 16,
                      color: result.verdictColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      result.verdictTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                  AppColors.brand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard(
                  'Protein',
                  '${result.proteinG?.round() ?? 0}g',
                  AppColors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard(
                  'Fat',
                  '${result.fatG?.round() ?? 0}g',
                  AppColors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroCard(
                  'Carbs',
                  '${result.carbsG?.round() ?? 0}g',
                  AppColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // NORI Recommendation Box (Exact Rules Engine Verdict Reason)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.verdictBgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: result.verdictColor.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.shieldCheck,
                      size: 16,
                      color: result.verdictColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'NORI Clinical Assessment',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: result.verdictColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result.verdictReason,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onLogMeal,
                    icon: const Icon(LucideIcons.checkCircle, size: 18),
                    label: const Text(
                      'Log Meal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onAskAi,
                    icon: const Icon(LucideIcons.messageCircle, size: 18),
                    label: const Text(
                      'Ask AI',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                      backgroundColor: AppColors.backgroundCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scan another button
          Center(
            child: TextButton.icon(
              onPressed: onScanAnother,
              icon: const Icon(LucideIcons.refreshCw, size: 16, color: AppColors.textSecondary),
              label: const Text(
                'Scan another food',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
