import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
            // NORI AI Glowing Avatar
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brand, AppColors.indigo],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chat with NORI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your clinical AI health companion tailored with personalized Nigerian nutrition insights. Ask about your meals, health goals, or recovery.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
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
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
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
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p['prompt']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.brand,
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
