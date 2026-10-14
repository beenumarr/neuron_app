import '../../modules/auth/views/privacy_policy_screen.dart';
import '../../modules/auth/views/terms_of_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/auth/views/forgot_password_screen.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/register_screen.dart';
import '../../modules/auth/views/reset_password_screen.dart';
import '../../modules/auth/views/welcome_screen.dart';
import '../../modules/health/views/main_screen.dart';
import '../../modules/health/views/onboarding_complete_screen.dart';
import '../../modules/health/views/onboarding_screen.dart';
import '../../modules/health/views/onboarding_setup_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthController authController) {
    return GoRouter(
      initialLocation: authController.isAuthenticated
          ? (authController.isOnboarded ? '/home' : '/onboarding-setup')
          : '/welcome',
      refreshListenable: authController,
      redirect: (BuildContext context, GoRouterState state) {
        final isAuth = authController.isAuthenticated;
        final isOnboarded = authController.isOnboarded;
        final loc = state.matchedLocation;

        final isPublicRoute = loc == '/welcome' ||
            loc == '/onboarding' ||
            loc == '/login' ||
            loc == '/register' ||
            loc == '/forgot-password' ||
            loc == '/reset-password' ||
            loc == '/terms' ||
            loc == '/privacy';

        // Unauthenticated users attempting to access protected screens
        if (!isAuth) {
          if (!isPublicRoute) {
            return '/welcome';
          }
          return null;
        }

        // Authenticated users
        if (isAuth) {
          // If on public auth screens, redirect into the app flow
          if (loc == '/welcome' || loc == '/login' || loc == '/register') {
            return isOnboarded ? '/home' : '/onboarding-setup';
          }

          // If trying to access home before onboarding is complete
          if (!isOnboarded && loc == '/home') {
            return '/onboarding-setup';
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsOfServiceScreen(),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) {
            final token = state.uri.queryParameters['token'];
            return ResetPasswordScreen(initialToken: token);
          },
        ),
        GoRoute(
          path: '/onboarding-setup',
          builder: (context, state) => const OnboardingSetupScreen(),
        ),
        GoRoute(
          path: '/onboarding-complete',
          builder: (context, state) => const OnboardingCompleteScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const MainScreen(initialTab: 4),
        ),
      ],
    );
  }
}
