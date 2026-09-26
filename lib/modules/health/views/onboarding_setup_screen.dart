import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingSetupScreen extends StatefulWidget {
  const OnboardingSetupScreen({super.key});

  @override
  State<OnboardingSetupScreen> createState() => _OnboardingSetupScreenState();
}

class _OnboardingSetupScreenState extends State<OnboardingSetupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  static const List<String> availableConditions = [
    'None',
    'Diabetes',
    'Hypertension',
    'High Cholesterol',
    'Celiac',
    'Thyroid Issue',
    'Heart Condition',
  ];

  static const List<String> availableDietaryPrefs = [
    'High Protein',
    'Low Carb',
    'Mediterranean',
    'Vegetarian',
    'Gluten Free',
    'Keto',
  ];

  static const List<String> availableGoals = [
    'Improve Energy & Health',
    'Weight Loss',
    'Build Muscle',
    'Better Sleep & Recovery',
    'Clinical Nutrition Management',
  ];

  @override
  void initState() {
    super.initState();
    final controller = context.read<OnboardingController>();
    _nameController = TextEditingController(text: controller.name.isNotEmpty ? controller.name : 'Alex Johnson');
    _ageController = TextEditingController(text: controller.age?.toString() ?? '26');
    _weightController = TextEditingController(text: controller.weightKg?.toString() ?? '72.0');
    _heightController = TextEditingController(text: controller.heightCm?.toString() ?? '175.0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteOnboarding() async {
    final controller = context.read<OnboardingController>();

    controller.setName(_nameController.text.trim());
    controller.setAge(int.tryParse(_ageController.text.trim()) ?? 26);
    controller.setWeight(double.tryParse(_weightController.text.trim()) ?? 72.0);
    controller.setHeight(double.tryParse(_heightController.text.trim()) ?? 175.0);

    final success = await controller.submitOnboarding();
    if (success && mounted) {
      context.go('/onboarding-complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Personalize Your Profile',
                style: AppTypography.heading1.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Help NEURON tailor recommendations specifically for your body and goals.',
                style: AppTypography.subtitle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Error banner if any
              if (controller.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    controller.errorMessage!,
                    style: AppTypography.caption.copyWith(color: AppColors.danger),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Biometrics Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vitals & Biometrics', style: AppTypography.title),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Full Name',
                      placeholder: 'Alex Johnson',
                      controller: _nameController,
                      onChanged: controller.setName,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Age',
                            placeholder: '26',
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            onChanged: (v) => controller.setAge(int.tryParse(v)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gender', style: AppTypography.label.copyWith(fontSize: 12)),
                              const SizedBox(height: 6),
                              Container(
                                height: 52,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundPage,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border, width: 1.5),
                                ),
                                child: Row(
                                  children: ['male', 'female'].map((g) {
                                    final isSelected = controller.gender == g;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () => controller.setGender(g),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.brand : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            g == 'male' ? 'Male' : 'Female',
                                            style: AppTypography.caption.copyWith(
                                              color: isSelected ? Colors.white : AppColors.textSecondary,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Height (cm)',
                            placeholder: '175',
                            controller: _heightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (v) => controller.setHeight(double.tryParse(v)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppTextField(
                            label: 'Weight (kg)',
                            placeholder: '72.0',
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (v) => controller.setWeight(double.tryParse(v)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Live BMI Preview Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.brandLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed_rounded, color: AppColors.brand, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Estimated BMI: ${controller.calculatedBmi ?? 23.5}',
                            style: AppTypography.bodyBold.copyWith(
                              color: AppColors.brandDark,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            controller.bmiCategory,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.brandDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Conditions Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health Conditions', style: AppTypography.title),
                    const SizedBox(height: 6),
                    Text(
                      'Select any existing medical or dietary conditions:',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableConditions.map((cond) {
                        final isSelected = controller.selectedConditions.contains(cond);
                        return FilterChip(
                          label: Text(cond),
                          selected: isSelected,
                          onSelected: (_) => controller.toggleCondition(cond),
                          selectedColor: AppColors.brandLight,
                          backgroundColor: AppColors.backgroundPage,
                          checkmarkColor: AppColors.brand,
                          labelStyle: AppTypography.caption.copyWith(
                            color: isSelected ? AppColors.brandDark : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                            side: BorderSide(
                              color: isSelected ? AppColors.brand : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dietary Preferences Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dietary Focus', style: AppTypography.title),
                    const SizedBox(height: 6),
                    Text(
                      'Select your preferred nutrition focus or diets:',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableDietaryPrefs.map((diet) {
                        final isSelected = controller.selectedDietaryPreferences.contains(diet);
                        return FilterChip(
                          label: Text(diet),
                          selected: isSelected,
                          onSelected: (_) => controller.toggleDiet(diet),
                          selectedColor: AppColors.indigoLight,
                          backgroundColor: AppColors.backgroundPage,
                          checkmarkColor: AppColors.indigo,
                          labelStyle: AppTypography.caption.copyWith(
                            color: isSelected ? AppColors.indigo : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                            side: BorderSide(
                              color: isSelected ? AppColors.indigo : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Goals Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Primary Goal', style: AppTypography.title),
                    const SizedBox(height: 12),
                    Column(
                      children: availableGoals.map((goal) {
                        final isSelected = controller.selectedGoal == goal;
                        return GestureDetector(
                          onTap: () => controller.setGoal(goal),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brandLight : AppColors.backgroundPage,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.brand : AppColors.border,
                                width: isSelected ? 1.8 : 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                  color: isSelected ? AppColors.brand : AppColors.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    goal,
                                    style: AppTypography.bodyBold.copyWith(
                                      color: isSelected ? AppColors.brandDark : AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
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
              ),
              const SizedBox(height: 24),

              // Complete Onboarding CTA Button
              AppButton(
                text: 'Complete Setup & Enter App',
                isLoading: controller.isLoading,
                onPressed: _handleCompleteOnboarding,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
