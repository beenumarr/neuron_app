import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ManualMealDialog extends StatefulWidget {
  final Future<bool> Function({
    required String mealType,
    required String name,
    required double calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    String? quantity,
  }) onSave;

  const ManualMealDialog({super.key, required this.onSave});

  static void show(
    BuildContext context, {
    required Future<bool> Function({
      required String mealType,
      required String name,
      required double calories,
      double? proteinG,
      double? carbsG,
      double? fatG,
      String? quantity,
    }) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ManualMealDialog(onSave: onSave),
    );
  }

  @override
  State<ManualMealDialog> createState() => _ManualMealDialogState();
}

class _ManualMealDialogState extends State<ManualMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _calController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _quantityController = TextEditingController();

  String _mealType = 'breakfast';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await widget.onSave(
      mealType: _mealType,
      name: _nameController.text.trim(),
      calories: double.tryParse(_calController.text.trim()) ?? 0.0,
      proteinG: double.tryParse(_proteinController.text.trim()),
      carbsG: double.tryParse(_carbsController.text.trim()),
      fatG: double.tryParse(_fatController.text.trim()),
      quantity: _quantityController.text.trim().isNotEmpty
          ? _quantityController.text.trim()
          : null,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal logged successfully!'),
            backgroundColor: AppColors.brand,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to log meal. Please check inputs.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  'Manual Meal Entry',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Record custom meals, traditional dishes, or snacks directly.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // Meal Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _mealType,
                  decoration: InputDecoration(
                    labelText: 'Meal Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('🌅 Breakfast')),
                    DropdownMenuItem(value: 'lunch', child: Text('☀️ Lunch')),
                    DropdownMenuItem(value: 'dinner', child: Text('🌙 Dinner')),
                    DropdownMenuItem(value: 'snack', child: Text('🍎 Snack')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _mealType = val);
                  },
                ),
                const SizedBox(height: 12),

                // Food Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Food Name (e.g., Moi Moi, Grilled Fish)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Please enter food name' : null,
                ),
                const SizedBox(height: 12),

                // Quantity / Serving description
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Serving (e.g., 1 wrap, 1 bowl, 200g)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Calories & Protein
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _calController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Calories (kcal) *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Protein (g)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Carbs & Fat
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _carbsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Carbs (g)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _fatController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Fat (g)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Save Meal to Diary',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
