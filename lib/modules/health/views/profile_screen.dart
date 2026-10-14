import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:provider/provider.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/widgets/app_button.dart";
import "../../auth/controllers/auth_controller.dart";
import "../models/health_profile_model.dart";
import "../services/health_api_service.dart";

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _isLoadingHistory = true);
    try {
      final healthApi = context.read<HealthApiService>();
      final items = await healthApi.getMeasurements(measurementType: "weight", limit: 5);
      if (mounted) {
        setState(() {
          _weightHistory = items;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return "Recent";
    try {
      final dt = DateTime.parse(dateVal.toString());
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    } catch (_) {
      return dateVal.toString();
    }
  }

  void _showLogWeightDialog(BuildContext context, HealthProfileModel? profile) {
    final weightController = TextEditingController(
      text: profile?.weightKg != null ? profile!.weightKg!.toStringAsFixed(1) : "",
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Log Current Weight",
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Record today's weight measurement to track progress over time.",
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mute),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Weight (kg)",
                suffixText: "kg",
                filled: true,
                fillColor: AppColors.cleanWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(weightController.text.trim());
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final healthApi = context.read<HealthApiService>();
                final authCtrl = context.read<AuthController>();
                try {
                  await healthApi.recordMeasurement(
                    measurementType: "weight",
                    value: val,
                    unit: "kg",
                  );
                  final updated = await healthApi.updateProfile({"weight_kg": val});
                  authCtrl.updateHealthProfile(updated);
                  _loadHistory();
                  messenger.showSnackBar(
                    const SnackBar(content: Text("Weight logged and profile updated")),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text("Failed to log weight: $e")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, HealthProfileModel? profile) {
    final weightCtrl = TextEditingController(text: profile?.weightKg?.toString() ?? "");
    final heightCtrl = TextEditingController(text: profile?.heightCm?.toString() ?? "");
    final ageCtrl = TextEditingController(text: profile?.age?.toString() ?? "");
    final goalCtrl = TextEditingController(text: profile?.goal ?? "");

    final selectedConditions = List<String>.from(profile?.conditions ?? []);
    final selectedDiets = List<String>.from(profile?.dietaryPreferences ?? []);

    final commonConditions = [
      "Diabetes (Type 2)",
      "Diabetes (Type 1)",
      "Gestational Diabetes",
      "Hypertension",
      "High Cholesterol",
      "Celiac Disease",
      "IBS",
      "Kidney Disease",
    ];

    final commonDiets = [
      "No restrictions",
      "Vegetarian",
      "Vegan",
      "Low-Sodium",
      "Low-Sugar",
      "Ulcer-Friendly",
      "Lagos (South West)",
      "Abuja / FCT",
      "Kano (North West)",
      "Desk Worker",
      "Cooks at Home",
      "Buys from Local Market",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.88,
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Health Profile",
                    style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Biometrics",
                        style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: weightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: "Weight (kg)",
                                filled: true,
                                fillColor: AppColors.backgroundPage,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: heightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: "Height (cm)",
                                filled: true,
                                fillColor: AppColors.backgroundPage,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: ageCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Age",
                                filled: true,
                                fillColor: AppColors.backgroundPage,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Primary Health Goal",
                        style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: goalCtrl,
                        decoration: InputDecoration(
                          hintText: "e.g. Manage blood sugar, Eat healthier",
                          filled: true,
                          fillColor: AppColors.backgroundPage,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Health Conditions",
                        style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: commonConditions.map((cond) {
                          final isSelected = selectedConditions.contains(cond);
                          return FilterChip(
                            label: Text(cond, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.ink)),
                            selected: isSelected,
                            selectedColor: AppColors.teal,
                            backgroundColor: AppColors.backgroundPage,
                            checkmarkColor: Colors.white,
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedConditions.add(cond);
                                } else {
                                  selectedConditions.remove(cond);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Diet, Lifestyle & Environment",
                        style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: commonDiets.map((diet) {
                          final isSelected = selectedDiets.contains(diet);
                          return FilterChip(
                            label: Text(diet, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.ink)),
                            selected: isSelected,
                            selectedColor: AppColors.teal,
                            backgroundColor: AppColors.backgroundPage,
                            checkmarkColor: Colors.white,
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedDiets.add(diet);
                                } else {
                                  selectedDiets.remove(diet);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final healthApi = context.read<HealthApiService>();
                    final authCtrl = context.read<AuthController>();
                    Navigator.pop(ctx);

                    final updates = <String, dynamic>{};
                    final w = double.tryParse(weightCtrl.text.trim());
                    if (w != null) updates["weight_kg"] = w;
                    final h = double.tryParse(heightCtrl.text.trim());
                    if (h != null) updates["height_cm"] = h;
                    final a = int.tryParse(ageCtrl.text.trim());
                    if (a != null) updates["age"] = a;
                    if (goalCtrl.text.trim().isNotEmpty) updates["goal"] = goalCtrl.text.trim();
                    updates["conditions"] = selectedConditions;
                    updates["dietary_preferences"] = selectedDiets;

                    try {
                      final updated = await healthApi.updateProfile(updates);
                      authCtrl.updateHealthProfile(updated);

                      if (w != null && (profile?.weightKg == null || (profile!.weightKg! - w).abs() > 0.01)) {
                        await healthApi.recordMeasurement(measurementType: "weight", value: w, unit: "kg");
                        _loadHistory();
                      }

                      messenger.showSnackBar(
                        const SnackBar(content: Text("Health profile updated successfully")),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text("Failed to update profile: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        : (user?.email.split("@").first ?? "Alex Johnson");
    final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : "U";

    final conditions = profile?.conditions ?? [];
    final diets = profile?.dietaryPreferences ?? [];
    final goal = (profile?.goal != null && profile!.goal!.trim().isNotEmpty)
        ? profile.goal!.trim()
        : "Improve Energy & Health";

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Hero Card (Deep Teal Gradient)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
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
                        IconButton(
                          icon: const Icon(LucideIcons.pencil, color: Colors.white, size: 20),
                          tooltip: "Edit Profile",
                          onPressed: () => _showEditProfileModal(context, profile),
                        ),
                      ],
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
                      user?.email ?? "patient@nori.ai",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                            "Patient · Verified Account",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4-Grid Biometrics (Weight, Height, BMI, Age)
              Row(
                children: [
                  _buildBiometricTile(
                    label: "Weight",
                    value: profile?.weightKg != null
                        ? "${profile!.weightKg!.toStringAsFixed(1)} kg"
                        : "--",
                  ),
                  const SizedBox(width: 8),
                  _buildBiometricTile(
                    label: "Height",
                    value: profile?.heightCm != null
                        ? "${profile!.heightCm!.round()} cm"
                        : "--",
                  ),
                  const SizedBox(width: 8),
                  _buildBiometricTile(
                    label: "BMI",
                    value: profile?.bmi != null
                        ? profile!.bmi!.toStringAsFixed(1)
                        : (profile?.weightKg != null && profile?.heightCm != null
                            ? (profile!.weightKg! / ((profile.heightCm! / 100) * (profile.heightCm! / 100))).toStringAsFixed(1)
                            : "--"),
                  ),
                  const SizedBox(width: 8),
                  _buildBiometricTile(
                    label: "Age",
                    value: profile?.age != null ? "${profile!.age}" : "--",
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weight Tracking History Card (Requirement 6)
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
                                "Weight Tracking History",
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
                                    ? "Last entry: ${_formatDate(_weightHistory.first["recorded_at"])}"
                                    : "No measurements logged yet",
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
                            "Log Weight",
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
                          "No historical weight entries yet. Tap \"+ Log Weight\" to start tracking changes over time.",
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
                          final val = item["value"];
                          final dateStr = _formatDate(item["recorded_at"]);
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
                                        "$val kg",
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
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      "Current",
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

              // Health Conditions, Goals & Lifestyle Card
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
                          "Health Goal",
                          style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        GestureDetector(
                          onTap: () => _showEditProfileModal(context, profile),
                          child: Text(
                            "Edit",
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        goal,
                        style: GoogleFonts.inter(color: AppColors.teal, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 16),

                    Text(
                      "Health Conditions",
                      style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
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
                          "No known conditions",
                          style: GoogleFonts.inter(color: AppColors.mute, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: conditions.map((c) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              c,
                              style: GoogleFonts.inter(color: AppColors.teal, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 16),

                    Text(
                      "Diet, Lifestyle & Environment",
                      style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 8),
                    if (diets.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cleanWhite,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Text(
                          "No restrictions specified",
                          style: GoogleFonts.inter(color: AppColors.mute, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: diets.map((d) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cleanWhite,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Text(
                              d,
                              style: GoogleFonts.inter(color: AppColors.ink, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sign Out Button (Pill Danger Style)
              AppButton.outline(
                title: "Sign Out",
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
                        "Sign Out",
                        style: GoogleFonts.sora(color: AppColors.ink, fontWeight: FontWeight.w700),
                      ),
                      content: Text(
                        "Are you sure you want to end your current session?",
                        style: GoogleFonts.inter(color: AppColors.mute, fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text("Cancel", style: GoogleFonts.inter(color: AppColors.mute, fontWeight: FontWeight.w600)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text("Sign Out", style: GoogleFonts.inter(color: AppColors.coral, fontWeight: FontWeight.w700)),
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
              style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.mute, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
