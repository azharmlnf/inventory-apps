import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/pages/login_page.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/presentation/pages/main_page.dart';
import 'package:flutter_inventory_app/domain/services/notification_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/providers/in_app_purchase_provider.dart';
import 'package:flutter_inventory_app/services/in_app_purchase_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await MobileAds.instance.initialize();
  final container = ProviderContainer();
  await container.read(notificationServiceProvider).init();
  await container.read(inAppPurchaseProvider).initialize();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventarisku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.blue.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // Corrected from ElevatedButtonData
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Add text theme for better typography control
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends ConsumerStatefulWidget {
  const AuthChecker({super.key});

  @override
  ConsumerState<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends ConsumerState<AuthChecker> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(authControllerProvider.notifier).checkCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    switch (authState.status) {
      case AuthStatus.authenticated:
        return const MainPage();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginPage();
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const SplashScreen();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}