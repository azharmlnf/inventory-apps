import 'package:flutter/material.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:flutter_inventory_app/domain/services/export_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/features/home/providers/dashboard_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:intl/intl.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismAccent = Color(0xFFE84A5F);
const Color _neubrutalismText = Colors.black;
const Color _neubrutalismBorder = Colors.black;
const double _neubrutalismBorderWidth = 3.0;
const Offset _neubrutalismShadowOffset = Offset(5.0, 5.0);

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAdLoaded) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    final user = ref.read(sessionControllerProvider).value;
    
    final dynamic premiumValue = user?.prefs.data['isPremium'];
    bool isPremium = false;
    if (premiumValue is bool) {
      isPremium = premiumValue;
    } else if (premiumValue is String) {
      isPremium = premiumValue.toLowerCase() == 'true';
    }

    if (isPremium) {
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

  Item _getDummyItem() {
    return Item(
      id: '',
      userId: '',
      name: 'Item Tidak Dikenal',
      quantity: 0,
      minQuantity: 0,
      unit: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(dateRangeProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    
    // Watch dashboard providers for the summary
    final totalItemsAsync = ref.watch(totalItemsCountProvider);
    final lowStockItemsAsync = ref.watch(lowStockItemsProvider);
    final totalValueAsync = ref.watch(totalStockValueProvider);
    final allItemsAsync = ref.watch(allItemsProvider);

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  NeuIconButton(
                    onPressed: () {
                      ref.invalidate(totalItemsCountProvider);
                      ref.invalidate(lowStockItemsProvider);
                      ref.invalidate(totalStockValueProvider);
                      ref.read(dateRangeProvider.notifier).state = (start: null, end: null);
                    },
                    icon: const Icon(Icons.refresh, color: _neubrutalismText),
                    buttonColor: Colors.white,
                    borderColor: _neubrutalismBorder,
                    shadowColor: _neubrutalismBorder,
                    enableAnimation: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeuTextButton(
                      onPressed: () {
                        final exportService = ref.read(exportServiceProvider);
                        final allItems = ref.read(allItemsProvider);
                        allItems.whenData((items) {
                          exportService.exportItemsToCsv(items);
                        });
                      },
                      text: const Text(
                        'Ekspor Item',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      buttonColor: _neubrutalismAccent,
                      borderColor: _neubrutalismBorder,
                      shadowColor: _neubrutalismBorder,
                      enableAnimation: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeuTextButton(
                      onPressed: () {
                        final exportService = ref.read(exportServiceProvider);
                        final allItems = ref.read(allItemsProvider); // Get all items
                        filteredTransactions.whenData((transactions) {
                          allItems.whenData((items) {
                            final Map<String, String> itemNames = {
                              for (var item in items) item.id: item.name,
                            };
                            exportService.exportTransactionsToCsv(transactions, itemNames);
                          });
                        });
                      },
                      text: const Text(
                        'Ekspor Transaksi',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      buttonColor: _neubrutalismAccent,
                      borderColor: _neubrutalismBorder,
                      shadowColor: _neubrutalismBorder,
                      enableAnimation: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          NeuContainer(
            height: 3,
            color: _neubrutalismBorder,
            borderRadius: BorderRadius.zero,
          ),
          // Transaction Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Filter Transaksi", 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _neubrutalismText,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: NeuContainer(
                    color: Colors.white,
                    borderColor: _neubrutalismBorder,
                    shadowColor: _neubrutalismBorder,
                    offset: _neubrutalismShadowOffset,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _selectDate(isStartDate: true),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: _neubrutalismText),
                            SizedBox(width: 8),
                            Text(
                              dateRange.start == null ? 'Mulai' : DateFormat('dd/MM/yy').format(dateRange.start!),
                              style: TextStyle(color: _neubrutalismText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeuContainer(
                    color: Colors.white,
                    borderColor: _neubrutalismBorder,
                    shadowColor: _neubrutalismBorder,
                    offset: _neubrutalismShadowOffset,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _selectDate(isStartDate: false),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: _neubrutalismText),
                            SizedBox(width: 8),
                            Text(
                              dateRange.end == null ? 'Akhir' : DateFormat('dd/MM/yy').format(dateRange.end!),
                              style: TextStyle(color: _neubrutalismText),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                                                                            String itemName = 'Item Tidak Dikenal';
                                                                                            allItemsAsync.whenData((allItems) {
                                                                                                                                                                                                  final item = allItems.firstWhere(
                                                                                                                                                                                                    (item) => item.id == transaction.itemId,
                                                                                                                                                                                                    orElse: () => _getDummyItem(),
                                                                                                                                                                                                  );
                                                                                                                                                                                                  itemName = item.name;                                                                                            });
                                                                                            return Padding(
                                                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                              child: NeuContainer(
                                                                                                borderRadius: BorderRadius.circular(12),
                                                                                                color: Colors.white,
                                                                                                borderColor: _neubrutalismBorder,
                                                                                                borderWidth: _neubrutalismBorderWidth,
                                                                                                shadowColor: _neubrutalismBorder,
                                                                                                offset: _neubrutalismShadowOffset,
                                                                                                child: ListTile(
                                                                                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                                                                  title: Text(itemName, style: const TextStyle(color: _neubrutalismText, fontWeight: FontWeight.bold)),                                                  subtitle: Text('Jumlah: ${transaction.quantity} | Tipe: ${transaction.type.name}', style: TextStyle(color: _neubrutalismText.withAlpha((255 * 0.7).round()))),
                                                  trailing: Text(DateFormat('dd/MM/yyyy').format(transaction.date), style: const TextStyle(color: _neubrutalismText)),
                                                ),
                                              ),
                                            );                    },
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
    return NeuContainer(
      color: Colors.white,
      borderColor: _neubrutalismBorder,
      borderWidth: _neubrutalismBorderWidth,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      borderRadius: BorderRadius.circular(12),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _neubrutalismText.withAlpha((255 * 0.7).round())),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: _neubrutalismText),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return NeuContainer(
      color: Colors.white,
      borderColor: _neubrutalismBorder,
      borderWidth: _neubrutalismBorderWidth,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      borderRadius: BorderRadius.circular(12),
      child: Center(child: CircularProgressIndicator(color: _neubrutalismAccent)),
    );
  }

  Widget _buildErrorCard(String message) {
    return NeuContainer(
      color: Colors.white,
      borderColor: _neubrutalismBorder,
      borderWidth: _neubrutalismBorderWidth,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _neubrutalismAccent)),
        ),
      ),
    );
  }
}
