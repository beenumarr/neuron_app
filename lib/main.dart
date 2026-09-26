import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'modules/auth/services/auth_api_service.dart';
import 'modules/chat/controllers/chat_controller.dart';
import 'modules/chat/services/chat_api_service.dart';
import 'modules/health/controllers/home_controller.dart';
import 'modules/health/controllers/onboarding_controller.dart';
import 'modules/health/services/health_api_service.dart';
import 'modules/scanner/controllers/scanner_controller.dart';
import 'modules/scanner/services/meal_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize secure token storage
  final tokenStorage = TokenStorage();
  await tokenStorage.init();

  // Load saved custom server base URL if previously configured
  final savedUrl = await tokenStorage.getCustomBaseUrl();
  if (savedUrl != null && savedUrl.isNotEmpty) {
    AppConfig.setBaseUrl(savedUrl);
  }

  late final AuthController authController;

  // Initialize API client with token expired callback
  final apiClient = ApiClient(
    tokenStorage: tokenStorage,
    onTokenExpired: () {
      authController.handleSessionExpired();
    },
  );

  // Initialize API services
  final authApiService = AuthApiService(apiClient: apiClient);
  final healthApiService = HealthApiService(apiClient: apiClient);
  final mealApiService = MealApiService(apiClient: apiClient);

  final chatApiService = ChatApiService(apiClient: apiClient);

  // Initialize controllers
  authController = AuthController(
    authApiService: authApiService,
    healthApiService: healthApiService,
    tokenStorage: tokenStorage,
  );

  final onboardingController = OnboardingController(
    healthApiService: healthApiService,
    authController: authController,
  );

  final homeController = HomeController(
    healthApiService: healthApiService,
    mealApiService: mealApiService,
  );

  final chatController = ChatController(
    chatApiService: chatApiService,
  );

  final scannerController = ScannerController(
    mealApiService: mealApiService,
  );

  // Initialize existing auth session asynchronously in the background
  authController.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthApiService>.value(value: authApiService),
        Provider<HealthApiService>.value(value: healthApiService),
        Provider<MealApiService>.value(value: mealApiService),
        Provider<ChatApiService>.value(value: chatApiService),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<OnboardingController>.value(value: onboardingController),
        ChangeNotifierProvider<HomeController>.value(value: homeController),
        ChangeNotifierProvider<ChatController>.value(value: chatController),
        ChangeNotifierProvider<ScannerController>.value(value: scannerController),
      ],
      child: const NeuronApp(),
    ),
  );
}

class NeuronApp extends StatefulWidget {
  const NeuronApp({super.key});

  @override
  State<NeuronApp> createState() => _NeuronAppState();
}

class _NeuronAppState extends State<NeuronApp> {
  late final _router = AppRouter.createRouter(context.read<AuthController>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NEURON',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
