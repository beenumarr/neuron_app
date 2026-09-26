import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/scan_result_model.dart';

class LogMealSheet extends StatefulWidget {
  final ScanResultModel scanResult;
  final ValueChanged<String> onConfirm;

  const LogMealSheet({
    super.key,
    required this.scanResult,
    required this.onConfirm,
  });

  static Future<String?> show(BuildContext context, ScanResultModel scanResult) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogMealSheet(
        scanResult: scanResult,
        onConfirm: (type) => Navigator.pop(ctx, type),
      ),
    );
  }

  @override
  State<LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends State<LogMealSheet> {
  String _selectedType = 'lunch';

  static const List<Map<String, String>> _mealTypes = [
    {'type': 'breakfast', 'label': 'Breakfast', 'icon': '🌅'},
    {'type': 'lunch', 'label': 'Lunch', 'icon': '☀️'},
    {'type': 'dinner', 'label': 'Dinner', 'icon': '🌙'},
    {'type': 'snack', 'label': 'Snack', 'icon': '🍎'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log to Meal Diary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose which meal category to record "${widget.scanResult.foodName}" under.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),

            // Meal Type Selector Chips
            Row(
              children: _mealTypes.map((m) {
                final isSelected = _selectedType == m['type'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = m['type']!;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.brandLight : AppColors.backgroundPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.brand : AppColors.border,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(m['icon']!, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            m['label']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? AppColors.brand : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => widget.onConfirm(_selectedType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm & Log Meal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
