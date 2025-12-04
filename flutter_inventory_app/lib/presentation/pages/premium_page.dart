import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';

class PremiumPage extends ConsumerWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Premium'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPremium ? Icons.workspace_premium : Icons.stars_outlined,
                size: 80,
                color: isPremium ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                isPremium ? 'Anda adalah pengguna Premium!' : 'Upgrade ke Premium',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.amber : Colors.blueGrey,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                isPremium
                    ? 'Nikmati pengalaman aplikasi tanpa iklan dan akses ke fitur eksklusif!'
                    : 'Dapatkan pengalaman tanpa iklan, fitur pelaporan lanjutan, dan dukungan prioritas dengan menjadi pengguna Premium.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (!isPremium)
                ElevatedButton.icon(
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Upgrade Sekarang'),
                  onPressed: () {
                    // Placeholder for Stripe integration
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Integrasi Stripe sedang dalam pengembangan. Silakan ikuti checklist di dokumen.'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                    // TODO: Call the actual Stripe payment flow here
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
