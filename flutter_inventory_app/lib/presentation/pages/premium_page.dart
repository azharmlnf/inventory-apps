import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismAccent = Color(0xFFE84A5F);
const Color _neubrutalismText = Colors.black;
const Color _neubrutalismBorder = Colors.black;
const double _neubrutalismBorderWidth = 3.0;
const Offset _neubrutalismShadowOffset = Offset(5.0, 5.0);

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
  Future<void> _showDummyPaymentBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (ctx) {
        return NeuContainer(
          color: _neubrutalismBg,
          borderColor: _neubrutalismBorder,
          borderWidth: _neubrutalismBorderWidth,
          shadowColor: _neubrutalismBorder,
          offset: _neubrutalismShadowOffset,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _neubrutalismText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Anda akan berlangganan Inventarisku Premium seharga Rp 50.000.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _neubrutalismText),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ini adalah simulasi pembayaran. Tidak ada transaksi yang sebenarnya akan dilakukan.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: _neubrutalismText.withAlpha((255 * 0.7).round()),
                      ),
                ),
                const SizedBox(height: 32),
                NeuTextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulasi pembayaran berhasil!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // In a real app, you would verify payment and update user status here.
                    // For dummy, just show success.
                  },
                  buttonColor: _neubrutalismAccent,
                  borderColor: _neubrutalismBorder,
                  shadowColor: _neubrutalismBorder,
                  enableAnimation: true,
                  text: const Text(
                    'Konfirmasi & Bayar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                NeuTextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pembayaran dibatalkan.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  buttonColor: Colors.white,
                  borderColor: _neubrutalismBorder,
                  shadowColor: _neubrutalismBorder,
                  enableAnimation: true,
                  text: const Text(
                    'Batalkan',
                    style: TextStyle(color: _neubrutalismText, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      appBar: AppBar(
        title: const Text(
          'Halaman Premium',
          style: TextStyle(color: _neubrutalismText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _neubrutalismBg,
        foregroundColor: _neubrutalismText,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: NeuContainer(
            color: Colors.white,
            borderColor: _neubrutalismBorder,
            shadowColor: _neubrutalismBorder,
            offset: _neubrutalismShadowOffset,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPremium ? Icons.workspace_premium : Icons.stars_outlined,
                    size: 80,
                    color: isPremium ? _neubrutalismAccent : _neubrutalismText,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPremium ? 'Anda adalah pengguna Premium!' : 'Upgrade ke Premium',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPremium ? _neubrutalismAccent : _neubrutalismText,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPremium
                        ? 'Nikmati pengalaman aplikasi tanpa iklan!'
                        : 'Dapatkan pengalaman tanpa iklan dengan menjadi pengguna Premium.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _neubrutalismText.withAlpha((255 * 0.7).round()),
                        ),
                  ),
                  const SizedBox(height: 32),
                  if (!isPremium)
                    _isLoading
                        ? CircularProgressIndicator(color: _neubrutalismAccent)
                        : NeuTextButton(
                            onPressed: _showDummyPaymentBottomSheet,
                            buttonColor: _neubrutalismAccent,
                            borderColor: _neubrutalismBorder,
                            shadowColor: _neubrutalismBorder,
                            enableAnimation: true,
                            text: const Text(
                              'Upgrade Sekarang (Rp 50.000)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center, // Added this line
                            ),
                          ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
