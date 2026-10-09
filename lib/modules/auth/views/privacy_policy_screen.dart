import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.line),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Version & Effective Date Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shieldCheck, color: AppColors.teal, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NORI Privacy Policy · Version 1.0',
                            style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.teal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Effective: October 2026 · Pending Formal Legal Review',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.ink.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildSection(
                number: '1',
                title: 'Commitment to Your Privacy',
                content:
                    'At NORI, we recognize that nutrition, biometric measurements, and chronic health conditions are deeply personal. This Privacy Policy explains how NORI collects, processes, stores, and protects your information in compliance with relevant data privacy principles and the Nigeria Data Protection Act (NDPA).',
              ),

              _buildSection(
                number: '2',
                title: 'Information We Collect',
                content:
                    'We collect only information necessary to deliver personalized nutrition guidance:\n\n'
                    '• Account Credentials: Email address, encrypted password hash.\n'
                    '• Health & Biometrics: Weight (and dated measurement history), height, age, biological sex (Male/Female), activity level.\n'
                    '• Health Conditions & Preferences: Self-reported chronic conditions (such as Diabetes and specific diabetes type, Hypertension), food allergies, and dietary lifestyle.\n'
                    '• Geographical Information: State, City, Local Government Area (LGA), Area/Neighborhood, and Geopolitical Zone (used strictly for contextualizing regional food availability).\n'
                    '• Meal Diary & Scans: Uploaded food photos, nutritional estimates, and custom meal logs.\n'
                    '• Note: NORI does not track background GPS coordinates, physical home addresses, or financial records.',
              ),

              _buildSection(
                number: '3',
                title: 'How We Use Your Data',
                content:
                    'Your data is used solely to:\n\n'
                    '• Calculate personalized metrics such as BMI, calorie requirements, and macronutrient targets.\n'
                    '• Run deterministic clinical safety screening against food scans and meal entries.\n'
                    '• Contextualize AI assistant responses with locally accessible Nigerian foods in your state or region.\n'
                    '• Track progress and display your dated health measurement history over time.',
              ),

              _buildSection(
                number: '4',
                title: 'AI Companion & Chat Interactions',
                content:
                    'Conversations with the NORI AI companion use privacy-preserving prompts containing relevant clinical context without exposing sensitive authentication secrets. Queries submitted via "Tell NORI What\'s Going On" are processed strictly to assist you and are not sold or repurposed.',
              ),

              _buildSection(
                number: '5',
                title: 'Data Security and Storage',
                content:
                    'We employ industry-standard security safeguards, including TLS encryption in transit, bcrypt password hashing, rotating JWT session tokens, and secure database storage. Access to personal health records is strictly authenticated and isolated to your account.',
              ),

              _buildSection(
                number: '6',
                title: 'Data Sharing & Third Parties',
                content:
                    'WE DO NOT SELL, RENT, OR TRADE YOUR HEALTH DATA TO ADVERTISERS OR UNRELATED THIRD PARTIES. Data is shared only with trusted technical infrastructure providers (such as cloud hosting, image processing, and AI inference) bound by strict confidentiality and data protection obligations.',
              ),

              _buildSection(
                number: '7',
                title: 'Your Rights & Data Control',
                content:
                    'You have full control over your health profile:\n\n'
                    '• You can review and edit your biometrics, conditions, location, and activity level at any time in your Health Profile.\n'
                    '• You may review your historical weight measurements.\n'
                    '• You can request complete account deletion and erasure of your profile and meal diary by contacting privacy@nori.health.',
              ),

              _buildSection(
                number: '8',
                title: 'Contact Us',
                content:
                    'If you have any questions or data protection requests regarding this Privacy Policy, please contact our Data Protection team at privacy@nori.health.',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.ink.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
