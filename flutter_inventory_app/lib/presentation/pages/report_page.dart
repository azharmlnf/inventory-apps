import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:flutter_inventory_app/domain/services/export_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/home/providers/dashboard_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:intl/intl.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // _loadBannerAd() is now called in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAdLoaded) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    if (ref.read(authControllerProvider).isPremium) {
      return;
    }

    _bannerAd = ref.read(adServiceProvider).createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (error) {
        _bannerAd?.dispose();
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(dateRangeProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    
    // Watch dashboard providers for the summary
    final totalItemsAsync = ref.watch(totalItemsCountProvider);
    final lowStockItemsAsync = ref.watch(lowStockItemsProvider);
    final totalValueAsync = ref.watch(totalStockValueProvider);

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(totalItemsCountProvider);
              ref.invalidate(lowStockItemsProvider);
              ref.invalidate(totalStockValueProvider);
              ref.read(dateRangeProvider.notifier).state = (start: null, end: null);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final exportService = ref.read(exportServiceProvider);
              final allItems = ref.read(allItemsProvider);
              if (value == 'export_items') {
                allItems.whenData((items) {
                  exportService.exportItemsToCsv(items);
                });
              } else if (value == 'export_transactions') {
                filteredTransactions.whenData((transactions) {
                  exportService.exportTransactionsToCsv(transactions);
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'export_items',
                child: Text('Ekspor Item'),
              ),
              const PopupMenuItem<String>(
                value: 'export_transactions',
                child: Text('Ekspor Transaksi'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                totalItemsAsync.when(
                  data: (count) => _buildSummaryCard('Total Item', count.toString(), Icons.inventory_2_outlined, Colors.blue),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error'),
                ),
                lowStockItemsAsync.when(
                  data: (items) => _buildSummaryCard('Stok Rendah', items.length.toString(), Icons.warning_amber_rounded, Colors.orange),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error'),
                ),
                totalValueAsync.when(
                  data: (value) => _buildSummaryCard('Total Nilai Stok', currencyFormatter.format(value), Icons.monetization_on_outlined, Colors.green),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Transaction Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Filter Transaksi", style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    onPressed: () => _selectDate(isStartDate: true),
                    label: Text(dateRange.start == null ? 'Mulai' : DateFormat('dd/MM/yy').format(dateRange.start!)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    onPressed: () => _selectDate(isStartDate: false),
                    label: Text(dateRange.end == null ? 'Akhir' : DateFormat('dd/MM/yy').format(dateRange.end!)),
                  ),
                ),
              ],
            ),
          ),
          // Transaction List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: filteredTransactions.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Center(child: Text('Tidak ada transaksi pada rentang tanggal ini.'));
                  }
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text('Item ID: ${transaction.itemId}'), // Consider resolving to item name
                          subtitle: Text('Jumlah: ${transaction.quantity} | Tipe: ${transaction.type.name}'),
                          trailing: Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
          if (_bannerAd != null && _isAdLoaded)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final dateRange = ref.read(dateRangeProvider);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? dateRange.start : dateRange.end) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      if (isStartDate) {
        ref.read(dateRangeProvider.notifier).state = (start: pickedDate, end: dateRange.end);
      } else {
        ref.read(dateRangeProvider.notifier).state = (start: dateRange.start, end: pickedDate);
      }
    }
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
