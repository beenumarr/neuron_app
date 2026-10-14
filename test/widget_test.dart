import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuron_app/core/data/nigeria_locations.dart';
import 'package:neuron_app/core/theme/app_colors.dart';
import 'package:neuron_app/core/widgets/app_button.dart';
import 'package:neuron_app/core/widgets/app_logo.dart';
import 'package:neuron_app/core/widgets/app_ring.dart';
import 'package:neuron_app/core/widgets/social_auth_button.dart';
import 'package:neuron_app/modules/auth/models/auth_payloads.dart';
import 'package:neuron_app/modules/health/models/health_profile_model.dart';
import 'package:neuron_app/modules/health/models/onboarding_payload.dart';

void main() {
  test('AppColors brand color conforms to NORI design specs', () {
    expect(AppColors.brand, const Color(0xFF0B4F4A));       // Deep Teal
    expect(AppColors.brandDark, const Color(0xFF0A2E2C));   // Ink
    expect(AppColors.backgroundPage, const Color(0xFFF5FAF8)); // Clean White
  });

  test('Payload serialization matches backend expectations including mentor requirements', () {
    final reg = RegisterPayload(
      email: 'Test@Example.com',
      password: 'password123',
      agreedToTerms: true,
    );
    expect(reg.toJson()['email'], 'test@example.com');
    expect(reg.toJson()['role'], 'patient');
    expect(reg.toJson()['agreed_to_terms'], true);

    final onboard = OnboardingPayload(
      name: 'Chioma Adeleke',
      age: 32,
      gender: 'female',
      weightKg: 68.5,
      heightCm: 168.0,
      conditions: ['Diabetes', 'Hypertension'],
      diabetesType: 'Type 2 Diabetes',
      activityLevel: 'Moderately Active',
      state: 'Lagos',
      city: 'Ikeja',
      lga: 'Ikeja',
      area: 'Alausa',
      region: 'South West',
      goal: 'Manage blood sugar',
    );
    final map = onboard.toJson();
    expect(map['name'], 'Chioma Adeleke');
    expect(map['age'], 32);
    expect(map['gender'], 'female');
    expect(map['weight_kg'], 68.5);
    expect(map['height_cm'], 168.0);
    expect(map['conditions'], ['Diabetes', 'Hypertension']);
    expect(map['diabetes_type'], 'Type 2 Diabetes');
    expect(map['activity_level'], 'Moderately Active');
    expect(map['state'], 'Lagos');
    expect(map['city'], 'Ikeja');
    expect(map['lga'], 'Ikeja');
    expect(map['area'], 'Alausa');
    expect(map['region'], 'South West');
  });

  test('HealthProfileModel serialization handles diabetes type, location and activity level', () {
    final json = {
      'id': 'test-id-123',
      'user_id': 'user-123',
      'name': 'Amina Bello',
      'age': 29,
      'gender': 'female',
      'weight_kg': 62.0,
      'height_cm': 165.0,
      'conditions': ['Diabetes'],
      'diabetes_type': 'Type 1 Diabetes',
      'activity_level': 'Very Active',
      'state': 'Kano',
      'city': 'Kano',
      'lga': 'Nassarawa',
      'area': 'Bompai',
      'region': 'North West',
      'goal': 'Maintain energy',
      'onboarding_complete': true,
      'bmi': 22.8,
      'bmi_category': 'Normal weight',
    };

    final model = HealthProfileModel.fromJson(json);
    expect(model.name, 'Amina Bello');
    expect(model.diabetesType, 'Type 1 Diabetes');
    expect(model.activityLevel, 'Very Active');
    expect(model.state, 'Kano');
    expect(model.region, 'North West');
    expect(model.weightKg, 62.0);

    final out = model.toJson();
    expect(out['diabetes_type'], 'Type 1 Diabetes');
    expect(out['state'], 'Kano');
    expect(out['region'], 'North West');
  });

  test('NigeriaLocations contains 37 states/FCT and correctly maps regions', () {
    expect(NigeriaLocations.states.length, 37);
    expect(NigeriaLocations.getRegionForState('Lagos'), 'South West');
    expect(NigeriaLocations.getRegionForState('Kano'), 'North West');
    expect(NigeriaLocations.getRegionForState('Enugu'), 'South East');
    expect(NigeriaLocations.getRegionForState('Rivers'), 'South South');
    expect(NigeriaLocations.getRegionForState('FCT (Abuja)'), 'North Central');
    expect(NigeriaLocations.getRegionForState('Borno'), 'North East');
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
