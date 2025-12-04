import 'dart:async'; // Moved to top
import 'package:in_app_purchase/in_app_purchase.dart'; // Moved to top
import 'package:flutter_inventory_app/presentation/widgets/stock_chart.dart';
import 'package:flutter_inventory_app/presentation/pages/report_page.dart';
import 'package:flutter_inventory_app/features/transaction/pages/transaction_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/activity_log_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/category_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/home/providers/dashboard_providers.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:intl/intl.dart'; // For date formatting

// Import providers yang diperlukan untuk refresh
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_log_providers.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final String _premiumProductId = 'premium_access'; // Ganti dengan ID produk Anda

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // Handle error here.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error In-App Purchase: ${error.toString()}')),
      );
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Pembelian berhasil, update status premium di Appwrite
        ref.read(authControllerProvider.notifier).updatePremiumStatus(true).then((_) {
          // Tampilkan notifikasi atau update UI bahwa user sudah premium
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda sekarang adalah pengguna premium!')),
          );
        });

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi error pada pembelian: ${purchaseDetails.error?.message}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _buyPremium() async {
    // 1. Cek ketersediaan layanan pembelian
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan pembelian tidak tersedia.')),
      );
      return;
    }

    // 2. Ambil detail produk
    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails({_premiumProductId});
    if (productDetailResponse.error != null || productDetailResponse.productDetails.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: ${productDetailResponse.error?.message}')),
        );
        return;
    }
    
    final ProductDetails productDetails = productDetailResponse.productDetails.first;

    // 3. Buat parameter pembelian dan mulai proses
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Watch dashboard providers - RE-ADDED
    final totalJenisBarangAsync = ref.watch(totalItemsCountProvider);
    final lowStockItemsAsync = ref.watch(lowStockItemsProvider);
    final transactionsTodayAsync = ref.watch(transactionsTodayProvider);
    final latestTransactionsAsync = ref.watch(latestTransactionsProvider);

    // Listen for auth state changes to refresh data
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.user == null && next.user != null) {
        // User logged in, refresh all data
        ref.invalidate(itemsProvider);
        ref.invalidate(categoriesProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(activityLogsProvider);
      } else if (previous?.user != null && next.user == null) {
        // User logged out, clear data (optional, providers will handle this)
      }
    });

    return SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                totalJenisBarangAsync.when(
                  data: (count) => _buildSummaryCard(
                      'Total Jenis Barang', count.toString(), Icons.category, Colors.blue.shade700),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                ),
                lowStockItemsAsync.when(
                  data: (items) => _buildSummaryCard(
                      'Stok Akan Habis', items.length.toString(), Icons.warning_amber, Colors.orange.shade700),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                ),
                transactionsTodayAsync.when(
                  data: (transactions) => _buildSummaryCard(
                      'Transaksi Hari Ini', transactions.length.toString(), Icons.swap_horiz, Colors.green.shade700),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notifikasi Penting (Stok Rendah)
            Text(
              'Notifikasi Penting',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            lowStockItemsAsync.when(
              data: (lowStockItems) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: lowStockItems.isNotEmpty
                          ? Colors.red.shade50
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: lowStockItems.isNotEmpty
                          ? Border.all(color: Colors.red.shade200, width: 1)
                          : null,
                    ),
                    child: lowStockItems.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${lowStockItems.length} barang memiliki stok rendah:',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              ...lowStockItems
                                  .map((item) => Text(
                                        '${item.name} (${item.quantity} ${item.unit})',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      )),
                            ],
                          )
                        : Text(
                            'Tidak ada notifikasi stok rendah.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: ${err.toString()}'),
            ),
            const SizedBox(height: 20),

            // Stock Chart
            Text(
              'Grafik Stok Berdasarkan Kategori',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ref.watch(stockByCategoryProvider).when(
                  data: (categoryStocks) => categoryStocks.isEmpty
                      ? const Center(child: Text('Tidak ada data stok untuk ditampilkan.'))
                      : StockChart(categoryStocks: categoryStocks),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: ${err.toString()}'),
                ),

            // Transaksi Terbaru
            const SizedBox(height: 20),
            Text(
              'Transaksi Terbaru',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            latestTransactionsAsync.when(
              data: (latestTransactions) {
                return latestTransactions.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: latestTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = latestTransactions[index];
                          final isMasuk = transaction.type == TransactionType.inType;

                          // Watch item details for the transaction
                          final itemAsync = ref.watch(itemByIdProvider(transaction.itemId));

                          return itemAsync.when(
                            data: (item) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item?.name ?? 'Barang Tidak Ditemukan',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)} - ${transaction.note}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${isMasuk ? '+' : '-'}${transaction.quantity}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: isMasuk ? Colors.green.shade700 : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, stack) => Text('Error: ${err.toString()}'),
                          );
                        },
                      )
                    : Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            'Belum ada transaksi terbaru.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: ${err.toString()}'),
            ),
          ],
        ),
      );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
