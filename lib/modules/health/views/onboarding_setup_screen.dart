import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingSetupScreen extends StatefulWidget {
  const OnboardingSetupScreen({super.key});

  @override
  State<OnboardingSetupScreen> createState() => _OnboardingSetupScreenState();
}

class _OnboardingSetupScreenState extends State<OnboardingSetupScreen> {
  late final PageController _pageController;
  int _currentStep = 0;

  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  static const List<String> availableGoals = [
    'Lose weight',
    'Gain muscle',
    'Manage diabetes',
    'Improve heart health',
    'Boost energy',
    'Eat healthier',
  ];

  static const List<String> availableConditions = [
    'Type 1 Diabetes',
    'Type 2 Diabetes',
    'Hypertension',
    'High Cholesterol',
    'Heart Disease',
    'Celiac Disease',
    'IBS',
    'Kidney Disease',
    'None',
  ];

  static const List<String> availableDietaryPrefs = [
    'No restrictions',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
    'Low-Sodium',
    'Low-Sugar',
  ];

  static const List<Map<String, String>> availableActivityLevels = [
    {
      'title': 'Sedentary',
      'subtitle': 'Little to no exercise',
      'emoji': '🪑',
    },
    {
      'title': 'Light',
      'subtitle': '1-3 days/week',
      'emoji': '🚶',
    },
    {
      'title': 'Moderate',
      'subtitle': '3-5 days/week',
      'emoji': '🏃',
    },
    {
      'title': 'Active',
      'subtitle': '6-7 days/week',
      'emoji': '🏋️',
    },
    {
      'title': 'Very Active',
      'subtitle': 'Athlete / physical job',
      'emoji': '⚡',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final controller = context.read<OnboardingController>();

    _ageController = TextEditingController(text: controller.age?.toString() ?? '30');
    _weightController = TextEditingController(text: controller.weightKg?.toString() ?? '70');
    _heightController = TextEditingController(text: controller.heightCm?.toString() ?? '170');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      // Save step 1 inputs if on step 0
      if (_currentStep == 0) {
        _syncStepOneInputs();
      }

      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _handleCompleteOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipStep() {
    final controller = context.read<OnboardingController>();
    if (_currentStep == 2) {
      controller.clearConditions();
    } else if (_currentStep == 3) {
      controller.clearDiets();
    }
    _nextStep();
  }

  void _syncStepOneInputs() {
    final controller = context.read<OnboardingController>();
    final age = int.tryParse(_ageController.text.trim()) ?? 30;
    final weight = double.tryParse(_weightController.text.trim()) ?? 70.0;
    final height = double.tryParse(_heightController.text.trim()) ?? 170.0;

    controller.setAge(age);
    controller.setWeight(weight);
    controller.setHeight(height);
  }

  Future<void> _handleCompleteOnboarding() async {
    _syncStepOneInputs();
    final controller = context.read<OnboardingController>();

    final success = await controller.submitOnboarding();
    if (success && mounted) {
      context.go('/onboarding-complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();
    final isLoading = controller.isLoading;

    final canSkip = _currentStep == 2 || _currentStep == 3;

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation & Step Indicator ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: _currentStep > 0
                        ? IconButton(
                            icon: const Icon(
                              LucideIcons.chevronLeft,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: _previousStep,
                            padding: EdgeInsets.zero,
                          )
                        : null,
                  ),

                  // 5-Step Animated Indicators
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isActive = index == _currentStep;
                        final isCompleted = index < _currentStep;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 28 : 12,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.brand
                                : (isCompleted
                                    ? AppColors.brand.withValues(alpha: 0.6)
                                    : AppColors.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Skip button or placeholder
                  SizedBox(
                    width: 48,
                    height: 40,
                    child: canSkip
                        ? TextButton(
                            onPressed: _skipStep,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),

            // ── Step Content PageView ─────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1PersonalInfo(controller),
                  _buildStep2HealthGoals(controller),
                  _buildStep3ChronicConditions(controller),
                  _buildStep4DietaryPreferences(controller),
                  _buildStep5ActivityLevel(controller),
                ],
              ),
            ),

            // ── Error Banner if any ──────────────────────────────────────────
            if (controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ),

            // ── Bottom Action Button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: AppButton(
                title: _currentStep == 4 ? 'Finish Setup' : 'Continue',
                isLoading: isLoading,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Personal Information ─────────────────────────────────────────
  Widget _buildStep1PersonalInfo(OnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 1,
            title: 'Personal Information',
            subtitle: 'Help us personalize your experience',
          ),
          const SizedBox(height: 24),

          // Age Input
          const Text(
            'Age',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildInputField(
            controller: _ageController,
            hint: '30',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          // Biological Sex
          const Text(
            'Biological Sex',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Other'].map((sex) {
              final isSelected = controller.gender.toLowerCase() == sex.toLowerCase();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => controller.setGender(sex.toLowerCase()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.brandLight : AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.brand : AppColors.border,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sex,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.brandDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Weight & Height Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight (kg)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _weightController,
                      hint: '70',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Height (cm)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _heightController,
                      hint: '170',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 2: Health Goals ─────────────────────────────────────────────────
  Widget _buildStep2HealthGoals(OnboardingController controller) {
    final selectedGoals = controller.selectedGoals;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 2,
            title: 'Health Goals',
            subtitle: 'Select all that apply',
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: availableGoals.map((goal) {
              final isSelected = selectedGoals.contains(goal);

              return GestureDetector(
                onTap: () => controller.toggleGoal(goal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandLight : AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.brand : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          LucideIcons.checkCircle,
                          size: 15,
                          color: AppColors.brand,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        goal,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.brandDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Chronic Conditions ───────────────────────────────────────────
  Widget _buildStep3ChronicConditions(OnboardingController controller) {
    final selected = controller.selectedConditions;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 3,
            title: 'Chronic Conditions',
            subtitle: 'This helps us tailor nutrition guidance to your needs',
          ),
          const SizedBox(height: 18),

          // Privacy Callout Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.sky,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.lock,
                  size: 17,
                  color: AppColors.teal,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your health data is encrypted and never shared with third parties.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List of Conditions
          ...availableConditions.map((condition) {
            final isSelected = selected.contains(condition);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => controller.toggleCondition(condition),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandLight : AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.brand : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        condition,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.brandDark : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          LucideIcons.checkCircle,
                          size: 18,
                          color: AppColors.brand,
                        )
                      else
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Step 4: Dietary Preferences ──────────────────────────────────────────
  Widget _buildStep4DietaryPreferences(OnboardingController controller) {
    final selected = controller.selectedDietaryPreferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 4,
            title: 'Dietary Preferences',
            subtitle: 'Select your dietary lifestyle',
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: availableDietaryPrefs.map((diet) {
              final isSelected = selected.contains(diet);

              return GestureDetector(
                onTap: () => controller.toggleDiet(diet),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandLight : AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected ? AppColors.brand : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          LucideIcons.checkCircle,
                          size: 15,
                          color: AppColors.brand,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        diet,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.brandDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Step 5: Activity Level ───────────────────────────────────────────────
  Widget _buildStep5ActivityLevel(OnboardingController controller) {
    final currentLevel = controller.activityLevel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            stepNumber: 5,
            title: 'Activity Level',
            subtitle: 'How active are you in a typical week?',
          ),
          const SizedBox(height: 20),

          ...availableActivityLevels.map((level) {
            final title = level['title']!;
            final subtitle = level['subtitle']!;
            final emoji = level['emoji']!;
            final isSelected = currentLevel == title;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => controller.setActivityLevel(title),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandLight : AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.brand : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : AppColors.backgroundPage,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.brandDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.brand : AppColors.border,
                            width: isSelected ? 6 : 1.5,
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Step Header Helper ───────────────────────────────────────────────────
  Widget _buildStepHeader({
    required int stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP $stepNumber OF 5',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.teal,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.mute,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Input Field Helper ───────────────────────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: AppColors.mute,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
