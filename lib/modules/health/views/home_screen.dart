import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_ring.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final profile = authController.healthProfile;
    final displayName = profile?.name?.isNotEmpty == true
        ? profile!.name!
        : (user?.email.split('@').first ?? 'Alex');

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Greeting & Logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.logoGradient,
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'N',
                            style: AppTypography.title.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning,',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            displayName,
                            style: AppTypography.title.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                    tooltip: 'Log out',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text('Sign Out', style: AppTypography.title),
                          content: Text(
                            'Are you sure you want to sign out of your NEURON session?',
                            style: AppTypography.body,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text('Cancel', style: AppTypography.bodyBold),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(
                                'Sign Out',
                                style: AppTypography.bodyBold.copyWith(color: AppColors.danger),
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
                ],
              ),
              const SizedBox(height: 20),

              // Active JWT Session Card (Validating Backend Session)
              AppCard(
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.brand,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Authenticated JWT Session',
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.brandDark,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brandLight,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: AppTypography.micro.copyWith(
                              color: AppColors.brandDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.border.withValues(alpha: 0.7)),
                    const SizedBox(height: 8),
                    _buildSessionRow('User ID', user?.id ?? 'N/A'),
                    const SizedBox(height: 6),
                    _buildSessionRow('Email', user?.email ?? 'N/A'),
                    const SizedBox(height: 6),
                    _buildSessionRow('Role', (user?.role ?? 'patient').toUpperCase()),
                    const SizedBox(height: 6),
                    _buildSessionRow('Status', (user?.status ?? 'active').toUpperCase()),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Health Score Card (Centered around 87 / BMI)
              AppCard(
                child: Row(
                  children: [
                    AppRing(
                      value: 87,
                      max: 100,
                      size: 88,
                      strokeWidth: 7,
                      color: AppColors.brand,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '87',
                            style: AppTypography.heading2.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Score',
                            style: AppTypography.micro.copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.brandLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'OPTIMAL HEALTH',
                              style: AppTypography.micro.copyWith(
                                color: AppColors.brandDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Daily Health Index',
                            style: AppTypography.title.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.goal ?? 'Maintaining healthy nutrition balance.',
                            style: AppTypography.caption.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Vitals & Biometrics Snapshot Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vitals & Biometrics', style: AppTypography.title.copyWith(fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildMacroItem(
                          label: 'Weight',
                          value: '${profile?.weightKg ?? 72} kg',
                          color: AppColors.brand,
                          icon: Icons.monitor_weight_outlined,
                        ),
                        _buildMacroItem(
                          label: 'Height',
                          value: '${profile?.heightCm ?? 175} cm',
                          color: AppColors.indigo,
                          icon: Icons.height_rounded,
                        ),
                        _buildMacroItem(
                          label: 'BMI',
                          value: '${profile?.bmi ?? 23.5}',
                          color: AppColors.orange,
                          icon: Icons.speed_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI Health Assistant Quick Prompt Card
              AppCard(
                backgroundColor: AppColors.backgroundCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.brandLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: AppColors.brand, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'NEURON AI Companion',
                          style: AppTypography.title.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ready to analyze meals, calculate macros, and answer your health questions.',
                      style: AppTypography.caption.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ask NEURON about your next meal...',
                              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                          const Icon(Icons.mic_none_rounded, color: AppColors.brand, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyBold.copyWith(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.bodyBold.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
