import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';

class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onSelectPrompt;

  const ChatEmptyState({super.key, required this.onSelectPrompt});

  static const List<Map<String, String>> _prompts = [
    {
      'title': 'Healthy Nigerian Breakfast',
      'prompt': 'Can you recommend a healthy Nigerian breakfast for my health profile?',
      'icon': '🍲',
    },
    {
      'title': 'Analyze My Nutrition Today',
      'prompt': 'How is my daily protein and calorie intake looking based on my profile?',
      'icon': '📊',
    },
    {
      'title': 'Low-GI Local Meals',
      'prompt': 'What are some delicious low-GI Nigerian foods that prevent blood sugar spikes?',
      'icon': '🌾',
    },
    {
      'title': 'Local Protein Sources',
      'prompt': 'What are the best Nigerian whole foods to hit my protein targets?',
      'icon': '🍗',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nori Brand Logo
            const AppLogo(
              size: 64,
              variant: NoriLogoVariant.contained,
              showShadow: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Chat with nori',
              style: AppTypography.heading2.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your AI dietitian reading your health context, answering in plain language, and always saying what it measured against.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.mute,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Quick Starter Prompt Cards
            ..._prompts.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => onSelectPrompt(p['prompt']!),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                          Text(
                            p['icon']!,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['title']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p['prompt']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: AppColors.mute,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.arrowRight,
                            size: 16,
                            color: AppColors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
