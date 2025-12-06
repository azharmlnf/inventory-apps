import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  bool _isLoading = false;

  Future<void> _upgradeViaStripe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final functions = ref.read(appwriteFunctionProvider);
      final user = ref.read(authControllerProvider).user;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final result = await functions.createExecution(
        functionId: 'create-stripe-checkout', // Make sure this ID is correct
        body: '{"userId": "${user.$id}"}',
      );

      if (result.responseStatusCode == 200 && result.responseBody.isNotEmpty) {
        final response = json.decode(result.responseBody);
        if (response['ok'] == true && response['url'] != null) {
          final Uri url = Uri.parse(response['url']);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Could not launch ${response['url']}');
          }
        } else {
          throw Exception(response['msg'] ?? 'Failed to get checkout URL.');
        }
      } else {
        throw Exception(
            'Function execution failed with status: ${result.responseStatusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    ? 'Nikmati pengalaman aplikasi tanpa iklan!'
                    : 'Dapatkan pengalaman tanpa iklan dengan menjadi pengguna Premium.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (!isPremium)
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur Premium Segera Hadir!'),
                            ),
                          );
                        },
                        child: const Text('Upgrade Sekarang (Rp 50.000)'),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
