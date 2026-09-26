import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_ring.dart';
import '../controllers/progress_controller.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressController>().loadProgressData();
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return AppColors.danger;
      case 'MEDIUM':
        return AppColors.orange;
      default:
        return AppColors.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressController = context.watch<ProgressController>();
    final isLoading = progressController.isLoading;
    final isGenerating = progressController.isGeneratingReport;
    final report = progressController.latestReport;
    final dailyTrend = progressController.dailyCaloriesTrend;

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () => progressController.loadProgressData(silent: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CLINICAL INTELLIGENCE',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Progress & Trends',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Refresh Analytics',
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                      onPressed: () => progressController.loadProgressData(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (isLoading)
                  _buildLoadingSkeleton()
                else ...[
                  // 1. Current Health Score & Risk Flags Card (Honest NRS Assessment)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current NRS Health Score',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${progressController.healthScore}',
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                        height: 1.0,
                                      ),
                                    ),
                                    const Text(
                                      ' /100',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            AppRing(
                              value: progressController.healthScore.toDouble(),
                              max: 100,
                              size: 78,
                              strokeWidth: 6,
                              color: progressController.healthScore < 50
                                  ? AppColors.danger
                                  : AppColors.brand,
                              trackColor: AppColors.border,
                              child: Text(
                                progressController.healthStatusLabel,
                                style: TextStyle(
                                  color: progressController.healthScore < 50
                                      ? AppColors.danger
                                      : AppColors.brand,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 14),

                        // Real Clinical Risk Flags
                        const Text(
                          'Clinical Risk Assessment Flags',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (progressController.riskFlags.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.brandLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.brand, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No critical health risk flags detected on your profile.',
                                    style: TextStyle(fontSize: 12, color: AppColors.brand),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...progressController.riskFlags.map((flag) {
                            final sevColor = _getSeverityColor(flag.severity);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sevColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: sevColor.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 18, color: sevColor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              flag.title,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: sevColor,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: sevColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                flag.severity,
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          flag.recommendation.isNotEmpty ? flag.recommendation : flag.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.45,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Real Nutrition Breakdown Card (from Actual Logged Meals)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nutrition Breakdown',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Past 7 Days (${progressController.totalMealsCount} meals)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (progressController.totalMealsCount == 0)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundPage,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'No meals logged in the past 7 days.\nScan or record meals to view actual macro proportions.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                              ),
                            ),
                          )
                        else ...[
                          // Proportional macro bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 10,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: (progressController.proteinPct * 10).round().clamp(1, 1000),
                                    child: Container(color: AppColors.indigo),
                                  ),
                                  Expanded(
                                    flex: (progressController.carbsPct * 10).round().clamp(1, 1000),
                                    child: Container(color: AppColors.purple),
                                  ),
                                  Expanded(
                                    flex: (progressController.fatPct * 10).round().clamp(1, 1000),
                                    child: Container(color: AppColors.orange),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Macro details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMacroLegend(
                                'Protein',
                                '${progressController.totalProtein.round()}g',
                                '${progressController.proteinPct.round()}%',
                                AppColors.indigo,
                              ),
                              _buildMacroLegend(
                                'Carbs',
                                '${progressController.totalCarbs.round()}g',
                                '${progressController.carbsPct.round()}%',
                                AppColors.purple,
                              ),
                              _buildMacroLegend(
                                'Fat',
                                '${progressController.totalFat.round()}g',
                                '${progressController.fatPct.round()}%',
                                AppColors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(color: AppColors.border, height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Calories Tracked',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              Text(
                                '${progressController.totalCalories.round()} kcal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brand,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Real Calorie Intake Trend (Mon..Sun Actual Logs)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Calorie Intake Trend',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Daily Target: 2,200 kcal',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Real Day-by-Day Bars
                        SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: dailyTrend.map((d) {
                              final double cals = d['calories'] as double;
                              final bool hasMeals = d['hasMeals'] as bool;
                              final String day = d['day'] as String;
                              final double heightFactor = (cals / 2500).clamp(0.06, 1.0);

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    hasMeals ? '${cals.round()}' : '-',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: hasMeals ? AppColors.brand : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 22,
                                    height: 80 * heightFactor,
                                    decoration: BoxDecoration(
                                      color: hasMeals
                                          ? AppColors.brand
                                          : AppColors.border.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: hasMeals ? FontWeight.bold : FontWeight.normal,
                                      color: hasMeals ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Real Synthesized Weekly AI Report Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [AppColors.brand, AppColors.indigo],
                                    ),
                                  ),
                                  child: const Icon(Icons.bolt_rounded, size: 18, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Weekly Clinical Report',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      report?.formattedDateRange ?? 'Past 7 Days',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Generate / Refresh button
                            TextButton.icon(
                              onPressed: isGenerating ? null : () => progressController.generateReportNow(),
                              icon: isGenerating
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand),
                                    )
                                  : const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.brand),
                              label: Text(
                                isGenerating ? 'Synthesizing…' : 'Synthesize Now',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brand),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                backgroundColor: AppColors.brandLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 14),

                        if (isGenerating)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Column(
                                children: const [
                                  CircularProgressIndicator(color: AppColors.brand),
                                  SizedBox(height: 12),
                                  Text(
                                    'Synthesizing clinical findings & Nigerian food trends with Gemini…',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (report != null && report.reportText.isNotEmpty)
                          SelectableText(
                            report.reportText,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.textPrimary,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                const Text(
                                  'No clinical report synthesized yet for this week.',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () => progressController.generateReportNow(),
                                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                  label: const Text('Generate Weekly Report with NEURON AI'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brand,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroLegend(String label, String grams, String pct, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Row(
              children: [
                Text(grams, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(width: 3),
                Text('($pct)', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(child: CircularProgressIndicator(color: AppColors.brand)),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ],
    );
  }
}
