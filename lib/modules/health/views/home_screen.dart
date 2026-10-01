import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_ring.dart';
import '../../../core/widgets/nori_brand_widgets.dart';
import '../../../core/widgets/server_config_dialog.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../scanner/models/meal_model.dart';
import '../controllers/home_controller.dart';
import '../models/health_profile_model.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<AuthController>().healthProfile;
      context.read<HomeController>().fetchDashboardData(profile: profile);
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 22) return 'Good evening';
    return 'Hello';
  }

  String _getFirstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'Alex';
    final first = trimmed.split(RegExp(r'\s+')).first;
    if (first.isEmpty) return 'Alex';
    return first[0].toUpperCase() + (first.length > 1 ? first.substring(1) : '');
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  void _showQuickLogDialog() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    String selectedMealType = 'breakfast';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 24 + bottomInset,
            ),
            decoration: const BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Log a Meal',
                    style: AppTypography.heading2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 14),

                  // Meal type selector
                  Row(
                    children: ['breakfast', 'lunch', 'dinner', 'snack'].map((type) {
                      final isSelected = selectedMealType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedMealType = type),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brand : AppColors.backgroundPage,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                type[0].toUpperCase() + type.substring(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Meal Name',
                      hintText: 'e.g. Oatmeal & Blueberries',
                      filled: true,
                      fillColor: AppColors.backgroundPage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: caloriesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Calories',
                            suffixText: 'kcal',
                            filled: true,
                            fillColor: AppColors.backgroundPage,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Protein',
                            suffixText: 'g',
                            filled: true,
                            fillColor: AppColors.backgroundPage,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: carbsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Carbs',
                            suffixText: 'g',
                            filled: true,
                            fillColor: AppColors.backgroundPage,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: fatController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Fat',
                            suffixText: 'g',
                            filled: true,
                            fillColor: AppColors.backgroundPage,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final calories = double.tryParse(caloriesController.text.trim()) ?? 0.0;
                        if (name.isEmpty || calories <= 0) return;

                        final protein = double.tryParse(proteinController.text.trim());
                        final carbs = double.tryParse(carbsController.text.trim());
                        final fat = double.tryParse(fatController.text.trim());

                        Navigator.of(ctx).pop();

                        final success = await context.read<HomeController>().logQuickMeal(
                          mealType: selectedMealType,
                          name: name,
                          calories: calories,
                          proteinG: protein,
                          carbsG: carbs,
                          fatG: fat,
                        );

                        if (mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Meal logged successfully!'),
                              backgroundColor: AppColors.brand,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Meal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final homeController = context.watch<HomeController>();
    final user = authController.currentUser;
    final profile = authController.healthProfile;

    final rawName = (profile?.name != null && profile!.name!.trim().isNotEmpty)
        ? profile.name!.trim()
        : (user?.email.split('@').first ?? 'Alex');
    final firstName = _getFirstName(rawName);
    final initialLetter = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A';

    // Calculate BMI
    double? bmi = profile?.bmi;
    if (bmi == null && profile?.weightKg != null && profile?.heightCm != null && profile!.heightCm! > 0) {
      final hM = profile.heightCm! / 100.0;
      bmi = profile.weightKg! / (hM * hM);
    }
    final displayBmi = bmi != null ? bmi.toStringAsFixed(1) : '22.5';
    final bmiCategory = profile?.bmiCategory ?? (bmi != null ? _getBmiCategory(bmi) : 'Normal');

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: () => homeController.fetchDashboardData(profile: profile, silent: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Expanded to avoid any overflow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFormattedDate(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_getGreeting()}, $firstName 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Server configuration quick access button
                        GestureDetector(
                          onTap: () => ServerConfigDialog.show(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.server,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Avatar Initial Circle
                        GestureDetector(
                          onTap: () => widget.onNavigateTab?.call(4), // Navigate to Profile
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.teal, AppColors.green],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initialLetter,
                                style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hero Card: Real BMI & Health Score / Gauge (Deep Teal)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: AppColors.heroGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Body Mass Index (BMI)',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      displayBmi,
                                      style: GoogleFonts.sora(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.mint,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          bmiCategory,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: AppColors.teal,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.badgeCheck,
                                      size: 13,
                                      color: AppColors.mint,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Target: 18.5 – 24.9',
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withValues(alpha: 0.88),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Health Score / Danger Level Ring Gauge
                          AppRing(
                            value: homeController.healthScore.toDouble(),
                            max: 100,
                            size: 94,
                            strokeWidth: 7,
                            color: homeController.healthScore < 50
                                ? AppColors.amber
                                : AppColors.mint,
                            trackColor: Colors.white.withValues(alpha: 0.2),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${homeController.healthScore}',
                                  style: GoogleFonts.sora(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  homeController.dangerLevelLabel,
                                  style: GoogleFonts.inter(
                                    color: homeController.healthScore < 50
                                        ? AppColors.amber
                                        : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Text(
                                  'Health Score',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Vitals row inside the card
                      Container(
                        padding: const EdgeInsets.only(top: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildHeroVitalsItem(
                              icon: LucideIcons.flame,
                              label: 'Calories',
                              value: '${homeController.totalCalories}',
                            ),
                            _buildHeroVitalsItem(
                              icon: LucideIcons.footprints,
                              label: 'Steps',
                              value: '7,234',
                            ),
                            _buildHeroVitalsItem(
                              icon: LucideIcons.moon,
                              label: 'Sleep',
                              value: '7h 20m',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Nori AI Answer Card (v2 Brand Guidelines Specification)
                NoriAiAnswerCard(
                  title: 'Nori measured against your profile',
                  content: homeController.getShortAiInsight(profile),
                ),
                const SizedBox(height: 14),

                // Today's Nutrition Card (Real macros from today's meals)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Nutrition",
                            style: GoogleFonts.sora(
                              color: AppColors.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${homeController.calorieGoal} kcal goal',
                            style: GoogleFonts.inter(
                              color: AppColors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MacroRing(
                            label: 'Calories',
                            value: homeController.totalCalories,
                            color: AppColors.teal,
                            pct: homeController.caloriesPct,
                          ),
                          MacroRing(
                            label: 'Protein',
                            value: homeController.totalProtein.round(),
                            unit: 'g',
                            color: AppColors.green,
                            pct: homeController.proteinPct,
                          ),
                          MacroRing(
                            label: 'Carbs',
                            value: homeController.totalCarbs.round(),
                            unit: 'g',
                            color: AppColors.amber,
                            pct: homeController.carbsPct,
                          ),
                          MacroRing(
                            label: 'Fat',
                            value: homeController.totalFat.round(),
                            unit: 'g',
                            color: AppColors.coral,
                            pct: homeController.fatPct,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Habits & Recovery (Interactive Water + AI Steps & Sleep)
                _buildHabitsAndRecoverySection(context, homeController, profile),
                const SizedBox(height: 18),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: GoogleFonts.sora(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickActionItem(
                      label: 'Log Meal',
                      icon: LucideIcons.utensils,
                      color: AppColors.teal,
                      onTap: _showQuickLogDialog,
                    ),
                    _buildQuickActionItem(
                      label: 'Scan Food',
                      icon: LucideIcons.scan,
                      color: AppColors.green,
                      onTap: () => widget.onNavigateTab?.call(1),
                    ),
                    _buildQuickActionItem(
                      label: 'Ask Nori',
                      icon: LucideIcons.messageCircle,
                      color: AppColors.amber,
                      onTap: () => widget.onNavigateTab?.call(2),
                    ),
                    _buildQuickActionItem(
                      label: 'Weight',
                      icon: LucideIcons.target,
                      color: AppColors.teal,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Current Recorded Weight: ${profile?.weightKg ?? 72} kg',
                            ),
                            backgroundColor: AppColors.teal,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Meals List (Real backend data)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Meals',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showQuickLogDialog,
                      child: const Text(
                        '+ Add Meal',
                        style: TextStyle(
                          color: AppColors.brand,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (homeController.todayMeals.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.brandLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.utensils,
                            color: AppColors.brand,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No meals logged yet today',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Track nutrition by scanning or logging your meals',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _showQuickLogDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.brand),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Log First Meal',
                            style: TextStyle(
                              color: AppColors.brand,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: homeController.todayMeals.map((meal) {
                      return _buildMealItemCard(meal);
                    }).toList(),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroVitalsItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItemCard(MealModel meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(12),
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
                  meal.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  meal.formattedTime,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.mute,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${meal.totalCalories.round()} kcal',
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }

  // ── Habits & Recovery Section (Water, Steps, Sleep) ───────────────────────
  Widget _buildHabitsAndRecoverySection(
    BuildContext context,
    HomeController homeController,
    HealthProfileModel? profile,
  ) {
    final waterCups = homeController.waterCups;
    final targetCups = homeController.waterTargetCups;
    final displayCupsCount = math.max(8, targetCups);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Habits & Recovery',
              style: GoogleFonts.sora(
                color: AppColors.ink,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'AI-Calibrated',
                    style: GoogleFonts.inter(
                      color: AppColors.teal,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 1. Interactive Water Intake Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.sky,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.droplets, size: 16, color: AppColors.teal),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Water Intake',
                        style: GoogleFonts.sora(
                          color: AppColors.ink,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${homeController.waterIntakeLiters.toStringAsFixed(2)}L / ${homeController.waterTargetLiters}L',
                        style: GoogleFonts.sora(
                          color: AppColors.teal,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($waterCups/$targetCups)',
                        style: GoogleFonts.inter(
                          color: AppColors.mute,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // AI Reason Capsule
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cleanWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(LucideIcons.sparkles, size: 11, color: AppColors.amber),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        homeController.waterAiReason,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: AppColors.ink,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 8,
                  width: double.infinity,
                  color: AppColors.sky,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: homeController.waterProgressPct,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.teal, AppColors.green],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Interactive Cups Row
              Row(
                children: List.generate(displayCupsCount, (i) {
                  final isFilled = i < waterCups;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (i + 1 == waterCups) {
                          homeController.removeWaterCup();
                        } else {
                          homeController.setWaterCups(i + 1);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 32,
                        decoration: BoxDecoration(
                          color: isFilled ? AppColors.sky : AppColors.cleanWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFilled ? AppColors.teal : AppColors.line,
                            width: isFilled ? 1.4 : 1.0,
                          ),
                        ),
                        child: Icon(
                          LucideIcons.droplets,
                          size: 13,
                          color: isFilled ? AppColors.teal : AppColors.mute.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // Quick Log Action Buttons
              Row(
                children: [
                  // Minus Button
                  GestureDetector(
                    onTap: () => homeController.removeWaterCup(),
                    child: Container(
                      width: 38,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.cleanWhite,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(LucideIcons.minus, size: 16, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // + 250ml Cup Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => homeController.addWaterCup(),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.line),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.plus, size: 14, color: AppColors.teal),
                            const SizedBox(width: 4),
                            Text(
                              '+ 250ml (Cup)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // + 500ml Bottle Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        homeController.addWaterCup();
                        homeController.addWaterCup();
                      },
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '+ 500ml (Bottle)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Steps & Sleep Cards (Side-by-side)
        Row(
          children: [
            // STEPS CARD
            Expanded(
              child: GestureDetector(
                onTap: () => _showLogStepsDialog(context, homeController),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.03),
                        blurRadius: 8,
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
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.footprints, size: 15, color: AppColors.teal),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cleanWhite,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Text(
                              '${(homeController.stepsProgressPct * 100).toInt()}%',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Steps',
                        style: GoogleFonts.inter(
                          color: AppColors.mute,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        homeController.stepsCount.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (m) => '${m[1]},',
                            ),
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Goal: ${homeController.stepsGoal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: AppColors.mute,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 6,
                          width: double.infinity,
                          color: AppColors.cleanWhite,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: homeController.stepsProgressPct,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.teal, AppColors.green],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quick Add buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => homeController.addSteps(500),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.cleanWhite,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.line),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+500',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => homeController.addSteps(1000),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.mint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+1k',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // SLEEP CARD
            Expanded(
              child: GestureDetector(
                onTap: () => _showLogSleepDialog(context, homeController),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.03),
                        blurRadius: 8,
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
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.sky,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.moon, size: 15, color: AppColors.teal),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cleanWhite,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Text(
                              homeController.sleepHours >= homeController.sleepGoalHours ? 'Restored' : 'Tracked',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: homeController.sleepHours >= homeController.sleepGoalHours ? AppColors.green : AppColors.mute,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sleep & Rest',
                        style: GoogleFonts.inter(
                          color: AppColors.mute,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${homeController.sleepHours.toStringAsFixed(1)} hrs',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Goal: ${homeController.sleepGoalHours.toStringAsFixed(1)} hrs',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: AppColors.mute,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 6,
                          width: double.infinity,
                          color: AppColors.cleanWhite,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: homeController.sleepProgressPct,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF4A7C94), AppColors.teal],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quick Add buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => homeController.addSleepMinutes(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.cleanWhite,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.line),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+30m',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => homeController.addSleepMinutes(60),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.mint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+1h',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogStepsDialog(BuildContext context, HomeController homeController) {
    final controller = TextEditingController(text: '${homeController.stepsCount}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(8)),
              child: const Icon(LucideIcons.footprints, size: 18, color: AppColors.teal),
            ),
            const SizedBox(width: 10),
            Text(
              'Log Steps',
              style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cleanWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2.0),
                    child: Icon(LucideIcons.sparkles, size: 12, color: AppColors.amber),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      homeController.stepsAiReason,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.ink, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Today\'s Step Count', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mute, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'e.g. 8500',
                filled: true,
                fillColor: AppColors.cleanWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.mute, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(controller.text.trim());
              if (steps != null) {
                homeController.setSteps(steps);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showLogSleepDialog(BuildContext context, HomeController homeController) {
    final controller = TextEditingController(text: '${homeController.sleepHours}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(8)),
              child: const Icon(LucideIcons.moon, size: 18, color: AppColors.teal),
            ),
            const SizedBox(width: 10),
            Text(
              'Log Sleep',
              style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cleanWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2.0),
                    child: Icon(LucideIcons.sparkles, size: 12, color: AppColors.amber),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      homeController.sleepAiReason,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.ink, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Sleep Duration (Hours)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.mute, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'e.g. 7.5',
                filled: true,
                fillColor: AppColors.cleanWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.mute, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              final hours = double.tryParse(controller.text.trim());
              if (hours != null) {
                homeController.setSleepHours(hours);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
