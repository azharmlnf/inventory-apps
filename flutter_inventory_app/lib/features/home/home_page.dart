import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/home/providers/dashboard_providers.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/presentation/widgets/stock_chart.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_log_providers.dart';

// Top-level constants for Neubrutalism style used in this page
const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismText = Colors.black;
const Color _neubrutalismBorder = Colors.black;
const Offset _neubrutalismShadowOffset = Offset(5.0, 5.0);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  // NOTE: This ID is specific to your store configuration (Google Play, App Store)
  static const String _premiumProductId = 'premium_access'; 

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error In-App Purchase: ${error.toString()}')),
        );
      }
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        ref.read(authControllerProvider.notifier).updatePremiumStatus(true).then((_) {
          if (mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anda sekarang adalah pengguna premium!')),
            );
          }
        });

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi error pada pembelian: ${purchaseDetails.error?.message}')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch dashboard providers
    final totalJenisBarangAsync = ref.watch(totalItemsCountProvider);
    final lowStockItemsAsync = ref.watch(lowStockItemsProvider);
    final transactionsTodayAsync = ref.watch(transactionsTodayProvider);
    final latestTransactionsAsync = ref.watch(latestTransactionsProvider);

    // Listen for auth state changes to refresh data
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.user == null && next.user != null) {
        ref.invalidate(itemsProvider);
        ref.invalidate(categoriesProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(activityLogsProvider);
      }
    });

    return Container(
      color: _neubrutalismBg,
      child: SingleChildScrollView(
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
                        'Total Jenis Barang', count.toString(), Icons.category_outlined, Colors.blue.shade300),
                    loading: () => _buildLoadingCard(),
                    error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                  ),
                  lowStockItemsAsync.when(
                    data: (items) => _buildSummaryCard(
                        'Stok Akan Habis', items.length.toString(), Icons.warning_amber_rounded, Colors.orange.shade300),
                    loading: () => _buildLoadingCard(),
                    error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                  ),
                  transactionsTodayAsync.when(
                    data: (transactions) => _buildSummaryCard(
                        'Transaksi Hari Ini', transactions.length.toString(), Icons.swap_horiz, Colors.green.shade300),
                    loading: () => _buildLoadingCard(),
                    error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                  ),
                ],
              ),
              const SizedBox(height: 20,),

              // Notifikasi Penting (Stok Rendah)
              const Text(
                'Notifikasi Penting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _neubrutalismText),
              ),
              const SizedBox(height: 10),
              lowStockItemsAsync.when(
                data: (lowStockItems) {
                  return NeuContainer(
                    borderColor: _neubrutalismBorder,
                    shadowColor: _neubrutalismBorder,
                    offset: _neubrutalismShadowOffset,
                    color: lowStockItems.isNotEmpty ? Colors.yellow.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: lowStockItems.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${lowStockItems.length} barang memiliki stok rendah:',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: _neubrutalismText),
                                ),
                                const SizedBox(height: 5),
                                ...lowStockItems
                                    .map((item) => Text(
                                          '${item.name} (${item.quantity} ${item.unit})',
                                          style: const TextStyle(fontSize: 12, color: _neubrutalismText),
                                        )),
                              ],
                            )
                          : const Text(
                              'Tidak ada notifikasi stok rendah.',
                              style: TextStyle(color: _neubrutalismText),
                            ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildErrorCard(err.toString()),
              ),
              const SizedBox(height: 20),

              // Stock Chart
              const Text(
                'Grafik Stok Berdasarkan Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _neubrutalismText),
              ),
              const SizedBox(height: 10),
              ref.watch(stockByCategoryProvider).when(
                    data: (categoryStocks) => categoryStocks.isEmpty
                        ? _buildErrorCard('Tidak ada data stok untuk ditampilkan.')
                        : StockChart(categoryStocks: categoryStocks),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => _buildErrorCard(err.toString()),
                  ),

              // Transaksi Terbaru
              const SizedBox(height: 20),
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _neubrutalismText),
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
                            final itemAsync = ref.watch(itemByIdProvider(transaction.itemId));

                            return itemAsync.when(
                              data: (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: NeuContainer(
                                  borderColor: _neubrutalismBorder,
                                  shadowColor: _neubrutalismBorder,
                                  offset: _neubrutalismShadowOffset,
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item?.name ?? 'Barang Dihapus',
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: _neubrutalismText, fontSize: 16),
                                              ),
                                              Text(
                                                '${DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)} - ${transaction.note}',
                                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${isMasuk ? '+' : '-'}${transaction.quantity}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isMasuk ? Colors.green.shade700 : Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (err, stack) => _buildErrorCard(err.toString()),
                            );
                          },
                        )
                      : _buildErrorCard('Belum ada transaksi terbaru.');
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => _buildErrorCard(err.toString()),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return NeuContainer(
      borderColor: _neubrutalismBorder,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      color: color,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 30, color: Colors.black),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _neubrutalismText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return NeuContainer(
      borderColor: _neubrutalismBorder,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_neubrutalismText),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return NeuContainer(
      borderColor: _neubrutalismBorder,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
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
