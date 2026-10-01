import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class ScanResultModel {
  final String scanId;
  final String foodName;
  final double calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final String verdict; // 'safe', 'caution', 'avoid'
  final String verdictReason;
  final String imageUrl;

  ScanResultModel({
    required this.scanId,
    required this.foodName,
    required this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    required this.verdict,
    required this.verdictReason,
    required this.imageUrl,
  });

  bool get isSafe => verdict.toLowerCase() == 'safe';
  bool get isCaution => verdict.toLowerCase() == 'caution';
  bool get isAvoid => verdict.toLowerCase() == 'avoid';

  String get verdictTitle {
    if (isSafe) return 'On target';
    if (isCaution) return 'Close to limit';
    if (isAvoid) return 'Over target';
    return 'Nori Assessment';
  }

  Color get verdictColor {
    if (isSafe) return AppColors.statusOnTargetText;
    if (isCaution) return AppColors.statusCloseToLimitText;
    if (isAvoid) return AppColors.statusOverTargetText;
    return AppColors.teal;
  }

  Color get verdictBgColor {
    if (isSafe) return AppColors.statusOnTargetBg;
    if (isCaution) return AppColors.statusCloseToLimitBg;
    if (isAvoid) return AppColors.statusOverTargetBg;
    return AppColors.mint;
  }

  IconData get verdictIcon {
    if (isSafe) return LucideIcons.badgeCheck;
    if (isCaution) return LucideIcons.alertTriangle;
    if (isAvoid) return LucideIcons.alertCircle;
    return LucideIcons.sparkles;
  }

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      scanId: json['scan_id']?.toString() ?? '',
      foodName: json['food_name'] as String? ?? 'Identified Food',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble(),
      carbsG: (json['carbs_g'] as num?)?.toDouble(),
      fatG: (json['fat_g'] as num?)?.toDouble(),
      verdict: json['verdict'] as String? ?? 'safe',
      verdictReason: json['verdict_reason'] as String? ?? 'Food analysis completed.',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'scan_id': scanId,
        'food_name': foodName,
        'calories': calories,
        if (proteinG != null) 'protein_g': proteinG,
        if (carbsG != null) 'carbs_g': carbsG,
        if (fatG != null) 'fat_g': fatG,
        'verdict': verdict,
        'verdict_reason': verdictReason,
        'image_url': imageUrl,
      };
}
