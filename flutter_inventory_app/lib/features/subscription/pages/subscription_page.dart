import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/providers/in_app_purchase_provider.dart';
import 'package:flutter_inventory_app/services/in_app_purchase_service.dart';

// Renders the subscription page, allowing users to upgrade to premium
// or view their premium status.
class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inAppPurchaseService = ref.watch(inAppPurchaseProvider);
    final isPremium = ref.watch(authControllerProvider).isPremium;

    // Listen for changes in the service for error snackbars
    ref.listen<InAppPurchaseService>(inAppPurchaseProvider, (previous, next) {
      if (next.purchasePendingError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.purchasePendingError!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isPremium ? 'Status Premium' : 'Upgrade ke Premium'),
        centerTitle: true,
      ),
      body: isPremium
          ? _buildPremiumStatus(context)
          : _buildPurchaseOptions(context, ref, inAppPurchaseService),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          inAppPurchaseService.restorePurchases();
        },
        label: const Text('Pulihkan Pembelian'),
        icon: const Icon(Icons.restore),
      ),
    );
  }

  // Widget to show when the user is already a premium member
  Widget _buildPremiumStatus(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 80,
              color: Color(0xFFFFD700),
            ),
            const SizedBox(height: 24),
            Text(
              'Anda Adalah Anggota Premium',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Terima kasih telah mendukung aplikasi ini. Anda kini memiliki akses ke semua fitur premium.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget to show when the user is not premium, showing purchase options
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
              : _buildProductList(context, inAppPurchaseService),
    );
  }
  
  // Loading indicator while fetching products
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
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Tarik ke bawah untuk mencoba lagi.\nPastikan Anda terhubung ke internet dan produk langganan telah diatur di Google Play Console.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // List of available subscription products
  Widget _buildProductList(
      BuildContext context, InAppPurchaseService inAppPurchaseService) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: inAppPurchaseService.products.length,
      itemBuilder: (context, index) {
        final product = inAppPurchaseService.products[index];
        
        // This logic is fragile; it's better to get this from the base plan details if available
        String period = product.id.contains('yearly') ? 'Per Tahun' : 'Per Bulan';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8.0),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8.0),
                Text(
                  product.price,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  period,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      inAppPurchaseService.buySubscription(product);
                    },
                    child: const Text('Beli Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
