import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron_app/core/theme/app_colors.dart';
import 'package:neuron_app/core/widgets/app_button.dart';
import 'package:neuron_app/core/widgets/app_logo.dart';
import 'package:neuron_app/core/widgets/app_ring.dart';
import 'package:neuron_app/core/widgets/social_auth_button.dart';
import 'package:neuron_app/modules/auth/models/auth_payloads.dart';
import 'package:neuron_app/modules/health/models/onboarding_payload.dart';

void main() {
  test('AppColors brand color conforms to NORI design specs', () {
    expect(AppColors.brand, const Color(0xFFC67139));       // Terracotta
    expect(AppColors.brandDark, const Color(0xFF9E5A2D));   // Deep Terracotta
    expect(AppColors.backgroundPage, const Color(0xFFF5EAD8)); // Cream
  });

  test('Payload serialization matches backend expectations', () {
    final reg = RegisterPayload(
      email: 'Test@Example.com',
      password: 'password123',
    );
    expect(reg.toJson()['email'], 'test@example.com');
    expect(reg.toJson()['role'], 'patient');

    final onboard = OnboardingPayload(
      name: 'Alex Johnson',
      age: 28,
      weightKg: 75.0,
      heightCm: 180.0,
      conditions: ['None'],
      goal: 'Improve Energy',
    );
    final map = onboard.toJson();
    expect(map['name'], 'Alex Johnson');
    expect(map['age'], 28);
    expect(map['weight_kg'], 75.0);
    expect(map['height_cm'], 180.0);
  });

  testWidgets('AppButton renders and handles tap interaction', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'Get Started',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppLogo renders with custom painter', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo(size: 96),
        ),
      ),
    );

    expect(find.byType(AppLogo), findsOneWidget);
  });

  testWidgets('AppRing renders progress arc and center child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppRing(
            value: 87,
            max: 100,
            child: Text('87'),
          ),
        ),
      ),
    );

    expect(find.text('87'), findsOneWidget);
  });

  testWidgets('SocialAuthButton renders Google and Apple buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SocialAuthButton.google(),
              SocialAuthButton.apple(),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });
}
