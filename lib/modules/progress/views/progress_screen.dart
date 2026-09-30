import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/progress_controller.dart';
import '../models/weekly_report_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final progressController = context.watch<ProgressController>();
    final isLoading = progressController.isLoading;
    final isGenerating = progressController.isGeneratingReport;
    final report = progressController.latestReport;

    final selectedPeriod = progressController.selectedPeriod;

    // Real dynamic metrics
    final totalMeals = progressController.totalMealsCount;
    final carbs = progressController.totalCarbs;
    final protein = progressController.totalProtein;
    final fat = progressController.totalFat;
    final totalCalories = progressController.totalCalories;

    final healthScore = progressController.healthScore;
    final healthScoreSeries = progressController.healthScoreChartSeries;
    final calorieSeries = progressController.calorieChartSeries;
    final riskFlags = progressController.riskFlags;

    final streak = progressController.streakDays;
    final avgScore = progressController.averageHealthScore;
    final goalsMet = progressController.goalsMetPercentage;

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
                // 1. Top Header: "Progress" + Segmented Pill ["Week", "Month", "3M"]
                _buildHeader(progressController, selectedPeriod),
                const SizedBox(height: 16),

                if (isLoading)
                  _buildLoadingSkeleton()
                else ...[
                  // 2. Card 1: Dynamic Health Score Line Chart Card
                  _buildHealthScoreCard(
                    score: healthScore,
                    series: healthScoreSeries,
                    deltaString: progressController.healthScoreDeltaString,
                    statusLabel: progressController.healthStatusLabel,
                    isImproving: progressController.isImproving,
                  ),
                  const SizedBox(height: 14),

                  // 3. Row of 3 Metric Cards: Streak, Avg Score, Goals Met
                  _buildThreeMetricsRow(
                    streak: streak,
                    avgScore: avgScore,
                    goalsMet: goalsMet,
                  ),
                  const SizedBox(height: 14),

                  // 4. Card 2: Nutrition Breakdown (Donut Chart + Macros)
                  _buildNutritionBreakdownCard(
                    carbs: carbs,
                    protein: protein,
                    fat: fat,
                    totalCalories: totalCalories,
                    totalMeals: totalMeals,
                  ),
                  const SizedBox(height: 14),

                  // 5. Card 3: Calorie Intake Area Chart
                  _buildCalorieIntakeCard(calorieSeries),
                  const SizedBox(height: 16),

                  // 6. Clinical Weekly AI Report Card
                  _buildWeeklyAiReportSection(
                    progressController: progressController,
                    report: report,
                    isGenerating: isGenerating,
                    riskFlags: riskFlags,
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header with segmented selector ─────────────────────────────────────────
  Widget _buildHeader(ProgressController controller, String selectedPeriod) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['Week', 'Month', '3M'].map((period) {
              final isSelected = selectedPeriod == period;
              return GestureDetector(
                onTap: () => controller.setPeriod(period),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brand : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Card 1: Health Score Line Chart ───────────────────────────────────────
  Widget _buildHealthScoreCard({
    required int score,
    required ChartSeries series,
    required String deltaString,
    required String statusLabel,
    required bool isImproving,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Score + Pill badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Score',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        deltaString,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isImproving ? AppColors.brand : AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isImproving ? AppColors.brandLight : AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImproving
                          ? Icons.trending_up_rounded
                          : Icons.trending_flat_rounded,
                      size: 13,
                      color: isImproving ? AppColors.brand : AppColors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: isImproving ? AppColors.brand : AppColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Monotone Curved Line Chart
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _HealthScoreLineChartPainter(
                scores: series.values,
                days: series.labels,
                lineColor: AppColors.brand,
                textColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Row of 3 Metric Cards: Streak, Avg Score, Goals Met ───────────────────
  Widget _buildThreeMetricsRow({
    required int streak,
    required String avgScore,
    required int goalsMet,
  }) {
    final streakText = '$streak ${streak == 1 ? "day" : "days"}';
    final goalsMetText = '$goalsMet%';

    return Row(
      children: [
        Expanded(
          child: _buildSingleMetricCard(
            icon: Icons.star_border_rounded,
            iconColor: AppColors.orange,
            value: streakText,
            label: 'Streak',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSingleMetricCard(
            icon: Icons.show_chart_rounded,
            iconColor: AppColors.indigo,
            value: avgScore,
            label: 'Avg Score',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSingleMetricCard(
            icon: Icons.track_changes_rounded,
            iconColor: AppColors.brand,
            value: goalsMetText,
            label: 'Goals Met',
          ),
        ),
      ],
    );
  }

  Widget _buildSingleMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 2: Nutrition Breakdown Donut Chart ───────────────────────────────
  Widget _buildNutritionBreakdownCard({
    required double carbs,
    required double protein,
    required double fat,
    required double totalCalories,
    required int totalMeals,
  }) {
    final hasMeals = totalMeals > 0 && (carbs > 0 || protein > 0 || fat > 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
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
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasMeals)
                Text(
                  '$totalMeals ${totalMeals == 1 ? "meal" : "meals"} logged',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Custom Donut Ring
              SizedBox(
                width: 116,
                height: 116,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    carbs: hasMeals ? carbs : 0,
                    protein: hasMeals ? protein : 0,
                    fat: hasMeals ? fat : 0,
                    carbsColor: AppColors.orange,
                    proteinColor: AppColors.indigo,
                    fatColor: AppColors.danger,
                  ),
                  child: !hasMeals
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.restaurant_outlined,
                                size: 20,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'No meals',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 18),

              // Macro Details List
              Expanded(
                child: Column(
                  children: [
                    _buildMacroRow('Carbs', '${carbs.toInt()}g', AppColors.orange),
                    const SizedBox(height: 8),
                    _buildMacroRow('Protein', '${protein.toInt()}g', AppColors.indigo),
                    const SizedBox(height: 8),
                    _buildMacroRow('Fat', '${fat.toInt()}g', AppColors.danger),
                    const SizedBox(height: 10),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${totalCalories.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} kcal',
                          style: const TextStyle(
                            color: AppColors.brand,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!hasMeals) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Log your meals in the Scan tab to see real clinical macro distribution.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroRow(String name, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Card 3: Calorie Intake Area Chart ─────────────────────────────────────
  Widget _buildCalorieIntakeCard(ChartSeries series) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Calorie Intake + Goal
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calorie Intake',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Goal: 2,200 kcal',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Area Chart with Dynamic Green Wave Gradient
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              painter: _CalorieAreaChartPainter(
                calories: series.values,
                days: series.labels,
                brandColor: AppColors.brand,
                textColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card 4: Weekly AI Clinical Report ─────────────────────────────────────
  Widget _buildWeeklyAiReportSection({
    required ProgressController progressController,
    required WeeklyReportModel? report,
    required bool isGenerating,
    required List riskFlags,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
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
                    decoration: BoxDecoration(
                      color: AppColors.brandLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly AI Clinical Report',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Synthesized by NORI Dietitian',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (report != null && !isGenerating)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Re-generate Report',
                  onPressed: () => progressController.generateReportNow(),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (isGenerating)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(AppColors.brand),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Synthesizing weekly clinical report...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (report == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No report synthesized yet for this week. Tap below to analyze your logged meals against clinical guidelines.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => progressController.generateReportNow(),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('Synthesize Weekly Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                report.formattedDateRange,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              report.reportText,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Skeleton Loader ───────────────────────────────────────────────────────
  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        4,
        (i) => Container(
          width: double.infinity,
          height: i == 0 ? 180 : 120,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS: Dynamic Monotone Cubic Splines & Donut Chart
// ─────────────────────────────────────────────────────────────────────────────

class _HealthScoreLineChartPainter extends CustomPainter {
  final List<double> scores;
  final List<String> days;
  final Color lineColor;
  final Color textColor;

  _HealthScoreLineChartPainter({
    required this.scores,
    required this.days,
    required this.lineColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 32.0;
    const bottomPadding = 20.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding;

    if (scores.isEmpty) return;

    final minScore = scores.reduce(math.min);
    final maxScore = scores.reduce(math.max);

    // Dynamic clean domain around scores or standard 60-100
    final minY = math.max(40.0, math.min(60.0, minScore - 10));
    final maxY = math.min(100.0, math.max(100.0, maxScore + 5));

    // Draw Y-axis labels: 100, 90, 80, 70, 60
    final yLabels = [100, 90, 80, 70, 60];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final label in yLabels) {
      if (label < minY || label > maxY) continue;
      final normY = (maxY - label) / (maxY - minY);
      final y = normY * chartHeight;

      textPainter.text = TextSpan(
        text: '$label',
        style: TextStyle(
          color: textColor.withValues(alpha: 0.8),
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Calculate (x, y) coordinates for data points
    final points = <Offset>[];
    final count = scores.length;
    final stepX = count > 1 ? chartWidth / (count - 1) : chartWidth;

    for (int i = 0; i < count; i++) {
      final x = leftPadding + (i * stepX);
      final clampedScore = scores[i].clamp(minY, maxY);
      final y = ((maxY - clampedScore) / (maxY - minY)) * chartHeight;
      points.add(Offset(x, y));
    }

    // Draw X-axis day labels
    for (int i = 0; i < days.length && i < points.length; i++) {
      textPainter.text = TextSpan(
        text: days[i],
        style: TextStyle(
          color: textColor.withValues(alpha: 0.8),
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, size.height - bottomPadding + 6),
      );
    }

    if (points.length < 2) {
      if (points.isNotEmpty) {
        canvas.drawCircle(points.first, 4.0, Paint()..color = lineColor);
      }
      return;
    }

    // Build smooth cubic bezier monotone path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 5.5;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 5.5;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 5.5;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 5.5;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Draw line stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(path, strokePaint);

    // Draw solid green dots at each point
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HealthScoreLineChartPainter oldDelegate) => true;
}

class _DonutChartPainter extends CustomPainter {
  final double carbs;
  final double protein;
  final double fat;
  final Color carbsColor;
  final Color proteinColor;
  final Color fatColor;

  _DonutChartPainter({
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.carbsColor,
    required this.proteinColor,
    required this.fatColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = carbs + protein + fat;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 20.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (total <= 0) {
      // Draw subtle placeholder ring when no meals are logged
      final emptyPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, emptyPaint);
      return;
    }

    final slices = [
      {'val': carbs, 'color': carbsColor},
      {'val': protein, 'color': proteinColor},
      {'val': fat, 'color': fatColor},
    ].where((s) => (s['val'] as double) > 0).toList();

    if (slices.isEmpty) return;

    const gap = 0.08; // gap in radians between arcs
    final effectiveGap = slices.length > 1 ? gap : 0.0;
    final availableAngle = (2 * math.pi) - (slices.length * effectiveGap);

    double startAngle = -math.pi / 2; // Start from top

    for (final slice in slices) {
      final val = slice['val'] as double;
      final color = slice['color'] as Color;
      final sweepAngle = (val / total) * availableAngle;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      canvas.drawArc(rect, startAngle + (effectiveGap / 2), sweepAngle, false, paint);
      startAngle += sweepAngle + effectiveGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

class _CalorieAreaChartPainter extends CustomPainter {
  final List<double> calories;
  final List<String> days;
  final Color brandColor;
  final Color textColor;

  _CalorieAreaChartPainter({
    required this.calories,
    required this.days,
    required this.brandColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomPadding = 20.0;
    final chartHeight = size.height - bottomPadding;
    final chartWidth = size.width;

    if (calories.isEmpty) return;

    final maxCal = calories.reduce(math.max);
    final minCal = calories.reduce(math.min);

    final points = <Offset>[];
    final stepX = calories.length > 1 ? chartWidth / (calories.length - 1) : chartWidth;

    if (maxCal <= 0) {
      // Draw flat baseline when all logged calories are zero
      final flatY = chartHeight - 10;
      for (int i = 0; i < calories.length; i++) {
        points.add(Offset(i * stepX, flatY));
      }
    } else {
      // Calculate dynamic normalized height
      final effectiveMin = minCal * 0.85;
      final effectiveMax = math.max(maxCal * 1.08, 2200.0);
      final range = effectiveMax - effectiveMin;

      for (int i = 0; i < calories.length; i++) {
        final x = i * stepX;
        final norm = range > 0 ? (calories[i] - effectiveMin) / range : 0.0;
        final y = chartHeight - (norm * (chartHeight * 0.75) + 12);
        points.add(Offset(x, y));
      }
    }

    // Build smooth cubic bezier curve
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 5.5;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 5.5;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 5.5;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 5.5;

      linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Closed Area Path for Gradient
    final areaPath = Path.from(linePath);
    areaPath.lineTo(chartWidth, chartHeight);
    areaPath.lineTo(0, chartHeight);
    areaPath.close();

    // Paint Area Gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        brandColor.withValues(alpha: maxCal > 0 ? 0.22 : 0.06),
        brandColor.withValues(alpha: 0.0),
      ],
    );

    final areaPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(areaPath, areaPaint);

    // Paint Stroke Line
    final strokePaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(linePath, strokePaint);

    // Draw X-axis day labels below chart
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < days.length && i < points.length; i++) {
      textPainter.text = TextSpan(
        text: days[i],
        style: TextStyle(
          color: textColor.withValues(alpha: 0.75),
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, size.height - bottomPadding + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CalorieAreaChartPainter oldDelegate) => true;
}
