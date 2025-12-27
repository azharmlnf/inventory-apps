import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/providers/in_app_purchase_provider.dart';
import 'package:flutter_inventory_app/services/in_app_purchase_service.dart';

// Top-level constants for Neubrutalism style
const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismBorder = Colors.black;

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inAppPurchaseService = ref.watch(inAppPurchaseProvider);

    // Correctly get user data from the new session controller
    final userAsync = ref.watch(sessionControllerProvider);
    final user = userAsync.value;

    final dynamic premiumValue = user?.prefs.data['isPremium'];
    bool isPremium = false;
    if (premiumValue is bool) {
      isPremium = premiumValue;
    } else if (premiumValue is String) {
      isPremium = premiumValue.toLowerCase() == 'true';
    }
    
    final activeSubscriptionId = user?.prefs.data['activeSubscriptionId'] as String?;

    ref.listen<InAppPurchaseService>(inAppPurchaseProvider, (previous, next) {
      if (next.purchasePendingError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.purchasePendingError!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      appBar: AppBar(
        title: Text(
          isPremium ? 'Status Premium' : 'Upgrade ke Premium',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _neubrutalismBg,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isPremium
          ? _buildPremiumStatus(context, activeSubscriptionId)
          : _buildPurchaseOptions(context, ref, inAppPurchaseService),
    );
  }

  Widget _buildPremiumStatus(BuildContext context, String? subscriptionId) {
    const premiumColor = Color(0xFFFBC02D); // A nice gold color

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: NeuContainer(
          width: double.infinity,
          borderColor: _neubrutalismBorder,
          shadowColor: _neubrutalismBorder,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeuContainer(
                  color: premiumColor,
                  borderRadius: BorderRadius.circular(50),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.workspace_premium,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Anda Adalah Anggota Premium',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Terima kasih telah mendukung aplikasi ini. Nikmati semua fitur premium tanpa batas.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: NeuContainer(height: 2, color: _neubrutalismBorder),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Keuntungan Anda:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureRow(Icons.assessment, 'Akses Laporan & Analisis Mendalam'),
                _buildFeatureRow(Icons.file_download, 'Ekspor Data tanpa batas (CSV)'),
                _buildFeatureRow(Icons.remove_red_eye_outlined, 'Pengalaman Sepenuhnya Bebas Iklan'),
                const SizedBox(height: 32),
                if (subscriptionId != null)
                  Text(
                    'Paket Aktif: $subscriptionId',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOptions(
    BuildContext context,
    WidgetRef ref,
    InAppPurchaseService inAppPurchaseService,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(inAppPurchaseProvider).queryProductDetails(),
      child: !inAppPurchaseService.isAvailable
          ? const Center(child: Text('Pembelian dalam aplikasi tidak tersedia.'))
          : inAppPurchaseService.products.isEmpty
              ? _buildLoadingProducts(context)
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildProductList(context, inAppPurchaseService),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildLoadingProducts(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Memuat produk...',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.black),
            const SizedBox(height: 16),
            Text(
              'Tarik ke bawah untuk mencoba lagi.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(
      BuildContext context, InAppPurchaseService inAppPurchaseService) {
    return ListView.builder(
      itemCount: inAppPurchaseService.products.length,
      itemBuilder: (context, index) {
        final product = inAppPurchaseService.products[index];
        
        if (kDebugMode) {
          print("Subscription Product ID: ${product.id}");
        }

        final bool isYearly = product.id.toLowerCase().contains('year') || product.id.toLowerCase().contains('tahunan');
        final String period = isYearly ? 'Per Tahun' : 'Per Bulan';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: NeuContainer(
            borderColor: _neubrutalismBorder,
            shadowColor: _neubrutalismBorder,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8.0),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        product.price,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (isYearly)
                        const Text(
                          'Rp 240.000',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4.0),
                  Text(
                    period,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: NeuContainer(
                      borderColor: _neubrutalismBorder,
                      shadowColor: _neubrutalismBorder,
                      color: Colors.green.shade300,
                      child: InkWell(
                        onTap: () {
                          inAppPurchaseService.buySubscription(product);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Text('Beli Sekarang', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}