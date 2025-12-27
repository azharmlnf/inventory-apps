import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/presentation/pages/main_page.dart';
import 'package:flutter_inventory_app/presentation/pages/splash_page.dart';
import 'package:flutter_inventory_app/domain/services/notification_service.dart';
import 'package:flutter_inventory_app/providers/in_app_purchase_provider.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/features/auth/pages/login_page.dart';

// --- Providers ---

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// A provider that initializes all necessary services before the app starts.
final initializationProvider = FutureProvider<void>((ref) async {
  await dotenv.load(fileName: ".env");
  await MobileAds.instance.initialize();
  await ref.read(notificationServiceProvider).init();
  await ref.read(inAppPurchaseProvider).initialize();
});



// --- App Entry Point ---

void main() {
  // Only minimal, synchronous work should be done here.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}


// --- Main App Widget ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stoklog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
        // ... (rest of the theme remains the same)
      ),
      home: const AuthChecker(),
    );
  }
}

// --- Auth / Initialization Checker ---

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the initialization provider first.
    final init = ref.watch(initializationProvider);

    return init.when(
      loading: () => const SplashPage(),
      error: (err, stack) {
        // You can build a more sophisticated error screen
        return Scaffold(
          body: Center(
            child: Text('Gagal inisialisasi aplikasi:\n$err'),
          ),
        );
      },
      data: (_) {
        // Once initialization is done, watch the new session controller state.
        final authState = ref.watch(sessionControllerProvider);
        return authState.when(
          loading: () => const SplashPage(),
          error: (err, stack) => Scaffold(
            body: Center(
              child: Text('Gagal memuat sesi user:\n$err'),
            ),
          ),
          data: (user) {
            if (user != null) {
              // User is logged in
              return const MainPage();
            } else {
              // User is not logged in
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}
