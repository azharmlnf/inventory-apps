import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart'; // Import provider kita
import 'package:flutter_inventory_app/services/in_app_purchase_service.dart'; // Import service kita

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inAppPurchaseService = ref.watch(inAppPurchaseServiceProvider);

    // Listen for changes in the service
    ref.listen<InAppPurchaseService>(inAppPurchaseServiceProvider, (previous, next) {
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
      body: inAppPurchaseService.isAvailable == false
          ? const Center(child: Text('Pembelian dalam aplikasi tidak tersedia.'))
          : inAppPurchaseService.products.isEmpty
              ? const Center(child: CircularProgressIndicator())
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
