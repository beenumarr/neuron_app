import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/scanner_controller.dart';
import 'manual_meal_dialog.dart';

class MealHistoryView extends StatelessWidget {
  const MealHistoryView({super.key});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday = now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    if (isToday) {
      return 'Today, $hour:$minute $period';
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, $hour:$minute $period';
  }

  Color _getMealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return AppColors.orange;
      case 'lunch':
        return AppColors.brand;
      case 'dinner':
        return AppColors.indigo;
      default:
        return AppColors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerController = context.watch<ScannerController>();
    final meals = scannerController.historyMeals;
    final isLoading = scannerController.isLoadingHistory;
    final selectedFilter = scannerController.selectedFilter;
    final currentPage = scannerController.currentPage;
    final totalPages = scannerController.totalPages;

    return Column(
      children: [
        // Filter bar & Manual entry button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Today', 'Last 7 Days', 'This Month'].map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.brand,
                          backgroundColor: AppColors.backgroundCard,
                          side: BorderSide(
                            color: isSelected ? AppColors.brand : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (_) => scannerController.setFilter(filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Add manual meal button
              IconButton(
                tooltip: 'Add Manual Meal',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.brandLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.plus, size: 18, color: AppColors.brand),
                ),
                onPressed: () {
                  ManualMealDialog.show(
                    context,
                    onSave: ({
                      required String mealType,
                      required String name,
                      required double calories,
                      double? proteinG,
                      double? carbsG,
                      double? fatG,
                      String? quantity,
                    }) async {
                      final meal = await scannerController.logManualMeal(
                        mealType: mealType,
                        name: name,
                        calories: calories,
                        proteinG: proteinG,
                        carbsG: carbsG,
                        fatG: fatG,
                        quantity: quantity,
                      );
                      return meal != null;
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),

        // Meals list
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.brand),
                )
              : meals.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: AppColors.brandLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.utensils,
                                size: 28,
                                color: AppColors.brand,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No meals recorded for this period',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Scan your food or use the "+ " button above to log your first dish.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.brand,
                      onRefresh: () => scannerController.loadHistory(refresh: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: meals.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (ctx, index) {
                          final meal = meals[index];
                          final item = meal.items.isNotEmpty ? meal.items.first : null;
                          final mealTypeColor = _getMealTypeColor(meal.mealType);

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard,
                              borderRadius: BorderRadius.circular(18),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Food emoji circle
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: mealTypeColor.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          meal.emoji,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item?.name ?? meal.displayName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatDate(meal.loggedAt),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Meal Type Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: mealTypeColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        meal.mealType.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: mealTypeColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: AppColors.border, height: 1),
                                const SizedBox(height: 10),

                                // Macros summary row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${meal.totalCalories.round()} kcal',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brand,
                                      ),
                                    ),
                                    Text(
                                      'Protein: ${meal.totalProtein.round()}g',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Carbs: ${meal.totalCarbs.round()}g',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Fat: ${meal.totalFat.round()}g',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),

        // Pagination Bar
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.backgroundCard,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: currentPage > 1 ? () => scannerController.goToPage(currentPage - 1) : null,
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text('Previous', style: TextStyle(fontSize: 12)),
                ),
                Text(
                  'Page $currentPage of $totalPages',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: currentPage < totalPages
                      ? () => scannerController.goToPage(currentPage + 1)
                      : null,
                  label: const Text('Next', style: TextStyle(fontSize: 12)),
                  icon: const Icon(LucideIcons.arrowRight, size: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
