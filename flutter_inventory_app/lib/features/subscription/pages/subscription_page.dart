import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
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
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;
    final activeSubscriptionId = authState.activeSubscriptionId;

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: NeuContainer(
          width: double.infinity,
          borderColor: _neubrutalismBorder,
          shadowColor: _neubrutalismBorder,
          color: const Color(0x4DFFD700),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 80,
                  color: Color(0xFFFFD700),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Anda Adalah Anggota Premium',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Terima kasih telah mendukung aplikasi ini. Anda kini memiliki akses ke semua fitur premium.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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