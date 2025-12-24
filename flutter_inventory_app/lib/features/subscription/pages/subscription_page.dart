import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_inventory_app/providers/in_app_purchase_provider.dart';
import 'package:flutter_inventory_app/services/in_app_purchase_service.dart'; // Import service kita

// Renders the subscription page, allowing users to upgrade to premium.
class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inAppPurchaseService = ref.watch(inAppPurchaseProvider);

    // Listen for changes in the service
    ref.listen<InAppPurchaseService>(inAppPurchaseProvider, (previous, next) {
      if (next.purchasePendingError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.purchasePendingError!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade ke Premium'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(inAppPurchaseProvider).queryProductDetails(),
        child: inAppPurchaseService.isAvailable == false
            ? const Center(child: Text('Pembelian dalam aplikasi tidak tersedia.'))
            : inAppPurchaseService.products.isEmpty
                ? Center(
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
                          const Text(
                            'Tarik ke bawah untuk mencoba lagi.\nPastikan Anda terhubung ke internet dan produk langganan telah diatur di Google Play Console.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: inAppPurchaseService.products.length,
                    itemBuilder: (context, index) {
                      final product = inAppPurchaseService.products[index];

                      // Determine subscription period from product ID
                      String period = '';
                      if (product.id == 'premium-monthly') {
                        period = 'Per Bulan';
                      } else if (product.id == 'premium-yearly') {
                        period = 'Per Tahun';
                      }

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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (period.isNotEmpty) ...[
                                const SizedBox(height: 4.0),
                                Text(
                                  period,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 16.0),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Panggil metode pembelian dari service
                                    inAppPurchaseService
                                        .buySubscription(product);
                                  },
                                  child: const Text('Beli Sekarang'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          inAppPurchaseService.restorePurchases();
        },
        label: const Text('Pulihkan Pembelian'),
        icon: const Icon(Icons.restore),
      ),
    );
  }

}
