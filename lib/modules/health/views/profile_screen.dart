import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/data/nigeria_locations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/health_profile_model.dart';
import '../services/health_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _weightHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadWeightHistory();
  }

  Future<void> _loadWeightHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final healthApi = context.read<HealthApiService>();
      final list = await healthApi.getMeasurements(measurementType: 'weight');
      if (mounted) {
        setState(() {
          _weightHistory = list;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      debugPrint('[ProfileScreen] loadWeightHistory error: $e');
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return 'Recently';
    try {
      final dt = DateTime.parse(dateVal.toString()).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateVal.toString();
    }
  }

  void _showLogWeightDialog(BuildContext context, HealthProfileModel? profile) {
    final weightController = TextEditingController(
      text: profile?.weightKg != null ? profile!.weightKg!.toStringAsFixed(1) : '',
    );
    bool isSaving = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.line),
          ),
          title: Text(
            'Log Weight Measurement',
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record your current weight. Previous entries are preserved in your dated history.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.mute),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'e.g. 72.5',
                  errorText: errorText,
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: AppColors.mute, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                ? null
                : () async {
                    final val = double.tryParse(weightController.text.trim());
                    if (val == null || val < 20.0 || val > 400.0) {
                      setDialogState(() => errorText = 'Enter valid weight (20 - 400 kg)');
                      return;
                    }

                    setDialogState(() => isSaving = true);
                    try {
                      final healthApi = context.read<HealthApiService>();
                      final authCtrl = context.read<AuthController>();

                      // 1. Record measurement in time-series table
                      await healthApi.recordMeasurement(
                        measurementType: 'weight',
                        value: val,
                        unit: 'kg',
                      );

                      // 2. Update health profile
                      final updated = await healthApi.updateProfile({'weight_kg': val});
                      authCtrl.updateHealthProfile(updated);

                      if (ctx.mounted) Navigator.of(ctx).pop();
                      _loadWeightHistory();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Weight recorded: $val kg'),
                            backgroundColor: AppColors.teal,
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(() {
                        isSaving = false;
                        errorText = 'Failed to save weight. Try again.';
                      });
                    }
                  },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Measurement', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, HealthProfileModel? profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileSheet(
        profile: profile,
        onProfileUpdated: () {
          _loadWeightHistory();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final profile = authController.healthProfile;

    final displayName = (profile?.name != null && profile!.name!.trim().isNotEmpty)
        ? profile.name!.trim()
        : (user?.email.split('@').first ?? 'Alex Johnson');
    final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    final conditions = profile?.conditions ?? [];
    final allergies = profile?.allergies ?? [];
    final diets = profile?.dietaryPreferences ?? [];
    final goal = (profile?.goal != null && profile!.goal!.trim().isNotEmpty)
        ? profile.goal!.trim()
        : 'Improve Energy & Health';

    // Location display
    final locParts = [
      if (profile?.area != null && profile!.area!.isNotEmpty) profile.area!,
      if (profile?.lga != null && profile!.lga!.isNotEmpty) profile.lga!,
      if (profile?.city != null && profile!.city!.isNotEmpty) profile.city!,
      if (profile?.state != null && profile!.state!.isNotEmpty) profile.state!,
      if (profile?.region != null && profile!.region!.isNotEmpty) profile.region!,
    ];
    final locationText = locParts.isNotEmpty ? locParts.join(', ') : 'Location not specified';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Profile Hero Card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: AppColors.heroGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar circle
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.mint.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initialLetter,
                          style: GoogleFonts.sora(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: GoogleFonts.sora(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user?.email ?? 'patient@nori.ai',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Patient role badge & Edit Profile button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.mint),
                              const SizedBox(width: 6),
                              Text(
                                'Patient · Verified',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showEditProfileSheet(context, profile),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.amber,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.edit3, size: 13, color: AppColors.ink),
                                const SizedBox(width: 4),
                                Text(
                                  'Edit Profile',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 4-Grid Biometrics (Weight, Height, BMI, Age) ───────────────
              Row(
                children: [
                  _buildBiometricTile(
                    label: 'Weight',
                    value: profile?.weightKg != null
                        ? '${profile!.weightKg!.toStringAsFixed(1)} kg'
                        : '--',
                  ),
                  const SizedBox(width: 8),
                  _buildBiometricTile(
                    label: 'Height',
                    value: profile?.heightCm != null
                        ? '${profile!.heightCm!.round()} cm'
                        : '--',
                  ),
                  const SizedBox(width: 8),
                  _buildBiometricTile(
                    label: 'BMI',
                    value: profile?.bmi != null
                        ? profile!.bmi!.toStringAsFixed(1)
                        : (profile?.weightKg != null && profile?.heightCm != null
                            ? (profile!.weightKg! / ((profile.heightCm! / 100) * (profile.heightCm! / 100))).toStringAsFixed(1)
                            : '--'),
                  ),
                  const SizedBox(width: 8),
                  _buildBiometricTile(
                    label: 'Age',
                    value: profile?.age != null ? '${profile!.age}' : '--',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Secondary Attributes (Biological Sex & Activity Level) ─────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.user, size: 16, color: AppColors.teal),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Biological Sex',
                                  style: TextStyle(fontSize: 10, color: AppColors.mute),
                                ),
                                Text(
                                  profile?.gender != null
                                      ? (profile!.gender![0].toUpperCase() + profile.gender!.substring(1))
                                      : 'Not specified',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.activity, size: 16, color: AppColors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Activity Level',
                                  style: TextStyle(fontSize: 10, color: AppColors.mute),
                                ),
                                Text(
                                  profile?.activityLevel ?? 'Moderately Active',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Location Tile (Requirement 7) ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.mapPin, color: AppColors.teal, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Geographical Location',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locationText,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.mute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.edit2, size: 16, color: AppColors.teal),
                      onPressed: () => _showEditProfileSheet(context, profile),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Health Conditions, Goals & Allergies Card ──────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                        Text(
                          'Clinical Profile & Conditions',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showEditProfileSheet(context, profile),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.brand,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Goal Section
                    Text(
                      'Health Goal',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mute,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        goal,
                        style: GoogleFonts.inter(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 14),

                    // Conditions Section (Requirement 3: Diabetes with type)
                    Text(
                      'Chronic Health Conditions',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mute,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (conditions.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cleanWhite,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Text(
                          'No known conditions',
                          style: GoogleFonts.inter(
                            color: AppColors.mute,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: conditions.map((c) {
                          final isDiabetes = c.toLowerCase().contains('diabet');
                          final label = (isDiabetes && profile?.diabetesType != null)
                              ? 'Diabetes (${profile!.diabetesType})'
                              : c;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDiabetes ? AppColors.brandLight : AppColors.mint,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isDiabetes ? AppColors.brand : AppColors.teal.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                color: isDiabetes ? AppColors.brandDark : AppColors.teal,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 14),

                    // Dietary Preferences
                    Text(
                      'Dietary Preferences',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mute,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (diets.isEmpty ? ['No restrictions'] : diets).map((d) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.cleanWhite,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Text(
                            d,
                            style: GoogleFonts.inter(
                              color: AppColors.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 14),

                    // Allergies Section
                    Text(
                      'Allergies & Sensitivities',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mute,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (allergies.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cleanWhite,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Text(
                          'No food allergies reported',
                          style: GoogleFonts.inter(
                            color: AppColors.mute,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allergies.map((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.alertTriangle, size: 12, color: AppColors.coral),
                                const SizedBox(width: 5),
                                Text(
                                  a,
                                  style: GoogleFonts.inter(
                                    color: AppColors.coral,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Weight History Card (Requirement 6) ────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weight Tracking History',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _weightHistory.isNotEmpty
                                    ? 'Last entry: ${_formatDate(_weightHistory.first['recorded_at'])}'
                                    : 'No measurements logged yet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.mute,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _showLogWeightDialog(context, profile),
                          icon: const Icon(LucideIcons.plus, size: 14, color: AppColors.teal),
                          label: Text(
                            'Log Weight',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.teal,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_isLoadingHistory)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
                        ),
                      )
                    else if (_weightHistory.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cleanWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.line),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'No historical weight entries yet. Tap "+ Log Weight" to start tracking changes over time.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.mute),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _weightHistory.length > 5 ? 5 : _weightHistory.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.line),
                        itemBuilder: (ctx, idx) {
                          final item = _weightHistory[idx];
                          final val = item['value'];
                          final dateStr = _formatDate(item['recorded_at']);
                          final isLatest = idx == 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isLatest ? AppColors.mint : AppColors.cleanWhite,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    LucideIcons.scale,
                                    size: 16,
                                    color: isLatest ? AppColors.teal : AppColors.mute,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$val kg',
                                        style: GoogleFonts.sora(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      Text(
                                        dateStr,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppColors.mute,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isLatest)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.mint,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Current',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Settings Rows ──────────────────────────────────────────────
              Container(
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
                    _buildSettingsRow(
                      icon: LucideIcons.fileText,
                      title: 'Terms of Service',
                      subtitle: 'Legal agreement and usage terms',
                      showDivider: true,
                      onTap: () => Navigator.of(context).pushNamed('/terms'),
                    ),
                    _buildSettingsRow(
                      icon: LucideIcons.shield,
                      title: 'Privacy Policy',
                      subtitle: 'Data protection and NDPA compliance',
                      showDivider: true,
                      onTap: () => Navigator.of(context).pushNamed('/privacy'),
                    ),
                    _buildSettingsRow(
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      subtitle: 'Meal & hydration reminders',
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Sign Out Button ────────────────────────────────────────────
              AppButton.outline(
                title: 'Sign Out',
                icon: LucideIcons.logOut,
                textColor: AppColors.coral,
                borderColor: AppColors.coral.withValues(alpha: 0.6),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.backgroundCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.line),
                      ),
                      title: Text(
                        'Sign Out',
                        style: GoogleFonts.sora(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to end your current session?',
                        style: GoogleFonts.inter(
                          color: AppColors.mute,
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: AppColors.mute,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            'Sign Out',
                            style: GoogleFonts.inter(
                              color: AppColors.coral,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await authController.logout();
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricTile({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.mute,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showDivider,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.teal, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.mute,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.mute),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.line),
          ),
      ],
    );
  }
}

/// Modal Bottom Sheet for editing all Health Profile fields
class _EditProfileSheet extends StatefulWidget {
  final HealthProfileModel? profile;
  final VoidCallback onProfileUpdated;

  const _EditProfileSheet({
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _goalController;
  late final TextEditingController _cityController;
  late final TextEditingController _lgaController;
  late final TextEditingController _areaController;

  late String _gender; // Only 'male' or 'female'
  late String _activityLevel;
  late Set<String> _conditions;
  String? _diabetesType;
  late Set<String> _dietaryPrefs;
  late Set<String> _allergies;
  String? _state;
  String? _region;

  bool _isSaving = false;
  String? _errorMessage;

  static const List<String> _availableConditions = [
    'Diabetes',
    'Hypertension',
    'High Cholesterol',
    'Heart Disease',
    'Celiac Disease',
    'IBS',
    'Kidney Disease',
  ];

  static const List<String> _diabetesTypes = [
    'Type 1 Diabetes',
    'Type 2 Diabetes',
    'Gestational Diabetes',
    'Other/Unspecified',
  ];

  static const List<Map<String, String>> _availableActivityLevels = [
    {
      'title': 'Sedentary',
      'subtitle': 'Mostly sitting throughout the day, with little exercise.',
      'emoji': '🪑',
    },
    {
      'title': 'Lightly Active',
      'subtitle': 'Mostly light daily activities, with some walking or occasional light exercise.',
      'emoji': '🚶',
    },
    {
      'title': 'Moderately Active',
      'subtitle': 'Regular walking, exercise, or moderate physical activity on several days of the week.',
      'emoji': '🏃',
    },
    {
      'title': 'Very Active',
      'subtitle': 'Frequent vigorous exercise or a physically demanding daily routine.',
      'emoji': '⚡',
    },
  ];

  static const List<String> _availableDiets = [
    'No restrictions',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Low-Sodium',
    'Low-Sugar',
    'Halal',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p?.name ?? '');
    _ageController = TextEditingController(text: p?.age != null ? '${p!.age}' : '');
    _weightController = TextEditingController(text: p?.weightKg != null ? '${p!.weightKg}' : '');
    _heightController = TextEditingController(text: p?.heightCm != null ? '${p!.heightCm}' : '');
    _goalController = TextEditingController(text: p?.goal ?? '');
    _cityController = TextEditingController(text: p?.city ?? '');
    _lgaController = TextEditingController(text: p?.lga ?? '');
    _areaController = TextEditingController(text: p?.area ?? '');

    _gender = (p?.gender?.toLowerCase() == 'female') ? 'female' : 'male';
    _activityLevel = p?.activityLevel ?? 'Moderately Active';

    _conditions = p?.conditions != null ? Set.from(p!.conditions) : {};
    _diabetesType = p?.diabetesType ?? 'Type 2 Diabetes';
    _dietaryPrefs = p?.dietaryPreferences != null ? Set.from(p!.dietaryPreferences) : {'No restrictions'};
    _allergies = p?.allergies != null ? Set.from(p!.allergies) : {};

    _state = p?.state;
    _region = p?.region ?? (p?.state != null ? NigeriaLocations.getRegionForState(p!.state!) : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    _cityController.dispose();
    _lgaController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final age = int.tryParse(_ageController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    if (weight != null && (weight < 20 || weight > 500)) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Please enter a realistic weight (20 - 500 kg)';
      });
      return;
    }

    if (height != null && (height < 50 || height > 300)) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Please enter a realistic height (50 - 300 cm)';
      });
      return;
    }

    try {
      final healthApi = context.read<HealthApiService>();
      final authCtrl = context.read<AuthController>();

      final hasDiabetes = _conditions.any((c) => c.toLowerCase().contains('diabet'));

      final updates = <String, dynamic>{
        'name': _nameController.text.trim(),
        'age': ?age,
        'gender': _gender,
        'weight_kg': ?weight,
        'height_cm': ?height,
        'conditions': _conditions.toList(),
        'diabetes_type': hasDiabetes ? _diabetesType : null,
        'activity_level': _activityLevel,
        'dietary_preferences': _dietaryPrefs.toList(),
        'allergies': _allergies.toList(),
        'goal': _goalController.text.trim(),
        'state': _state,
        'city': _cityController.text.trim(),
        'lga': _lgaController.text.trim(),
        'area': _areaController.text.trim(),
        'region': _region,
      };

      final updatedProfile = await healthApi.updateProfile(updates);
      authCtrl.updateHealthProfile(updatedProfile);
      widget.onProfileUpdated();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health profile updated successfully!'),
            backgroundColor: AppColors.teal,
          ),
        );
      }
    } catch (e) {
      debugPrint('[EditProfileSheet] error: $e');
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to update profile: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Health Profile',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: AppColors.mute),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.coral, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Full Name
                  _buildFieldLabel('Full Name'),
                  _buildTextField(_nameController, 'Your full name'),
                  const SizedBox(height: 14),

                  // Age & Biological Sex (Male / Female only)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Age'),
                            _buildTextField(_ageController, 'e.g. 30', isNumber: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Biological Sex'),
                            Row(
                              children: ['male', 'female'].map((s) {
                                final isSelected = _gender == s;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _gender = s),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      margin: EdgeInsets.only(right: s == 'male' ? 4 : 0, left: s == 'female' ? 4 : 0),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.brandLight : AppColors.cleanWhite,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? AppColors.brand : AppColors.line,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        s == 'male' ? 'Male' : 'Female',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? AppColors.brandDark : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Weight & Height
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Weight (kg)'),
                            _buildTextField(_weightController, 'e.g. 72.0', isNumber: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Height (cm)'),
                            _buildTextField(_heightController, 'e.g. 175', isNumber: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Activity Level (Requirement 4)
                  _buildFieldLabel('Activity Level'),
                  const SizedBox(height: 6),
                  ..._availableActivityLevels.map((lvl) {
                    final isSel = _activityLevel == lvl['title'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _activityLevel = lvl['title']!),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.brandLight : AppColors.cleanWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? AppColors.brand : AppColors.line,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(lvl['emoji']!, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lvl['title']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSel ? AppColors.brandDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      lvl['subtitle']!,
                                      style: const TextStyle(fontSize: 11, color: AppColors.mute),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSel)
                                const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.brand),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 18),

                  // Chronic Conditions (Requirement 3)
                  _buildFieldLabel('Chronic Health Conditions'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableConditions.map((cond) {
                      final isSel = _conditions.contains(cond);
                      return FilterChip(
                        label: Text(cond),
                        selected: isSel,
                        selectedColor: AppColors.brandLight,
                        checkmarkColor: AppColors.brand,
                        labelStyle: TextStyle(
                          color: isSel ? AppColors.brandDark : AppColors.textPrimary,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _conditions.add(cond);
                            } else {
                              _conditions.remove(cond);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (_conditions.contains('Diabetes')) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cleanWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diabetes Type (Requirement 3)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _diabetesTypes.map((dt) {
                              final isSelected = _diabetesType == dt;
                              return ChoiceChip(
                                label: Text(dt),
                                selected: isSelected,
                                selectedColor: AppColors.brand,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                                onSelected: (_) => setState(() => _diabetesType = dt),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // Dietary Preferences
                  _buildFieldLabel('Dietary Preferences'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableDiets.map((diet) {
                      final isSel = _dietaryPrefs.contains(diet);
                      return FilterChip(
                        label: Text(diet),
                        selected: isSel,
                        selectedColor: AppColors.brandLight,
                        checkmarkColor: AppColors.brand,
                        labelStyle: TextStyle(
                          color: isSel ? AppColors.brandDark : AppColors.textPrimary,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _dietaryPrefs.add(diet);
                            } else {
                              _dietaryPrefs.remove(diet);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Health Goal
                  _buildFieldLabel('Health Goal'),
                  _buildTextField(_goalController, 'e.g. Lose weight, manage diabetes, gain energy'),
                  const SizedBox(height: 18),

                  // Location (Requirement 7)
                  _buildFieldLabel('Geographical Location (Nigeria)'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cleanWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _state,
                        isExpanded: true,
                        hint: const Text('Select State', style: TextStyle(fontSize: 13, color: AppColors.mute)),
                        items: NigeriaLocations.states.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _state = val;
                            _region = val != null ? NigeriaLocations.getRegionForState(val) : null;
                          });
                        },
                      ),
                    ),
                  ),
                  if (_region != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Region: $_region (Auto-assigned)',
                      style: const TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_cityController, 'City (e.g. Ikeja)'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(_lgaController, 'LGA (e.g. Ikeja LGA)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(_areaController, 'Area / Neighborhood (e.g. Alausa)'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              text: 'Save Changes',
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cleanWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.mute),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
