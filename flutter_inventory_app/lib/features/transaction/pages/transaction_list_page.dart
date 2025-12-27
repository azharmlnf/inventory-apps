import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart'; // To get item details
import 'package:flutter_inventory_app/features/transaction/pages/transaction_form_page.dart'; // For adding/editing transactions
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:intl/intl.dart';

const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismAccent = Color(0xFFE84A5F);
const Color _neubrutalismText = Colors.black;
const Color _neubrutalismBorder = Colors.black;
const double _neubrutalismBorderWidth = 3.0;
const Offset _neubrutalismShadowOffset = Offset(5.0, 5.0);

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
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

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(transactionSortProvider);
    showDialog(
      context: context,
      builder: (context) {
        return NeuContainer(
          borderRadius: BorderRadius.circular(12),
          color: _neubrutalismBg,
          borderColor: _neubrutalismBorder,
          shadowColor: _neubrutalismBorder,
          offset: _neubrutalismShadowOffset,
          child: AlertDialog(
            backgroundColor: _neubrutalismBg,
            elevation: 0,
            title: const Text('Urutkan Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: TransactionSortType.values.map((sortType) {
                return RadioListTile<TransactionSortType>(
                  title: Text(sortType.label),
                  value: sortType,
                  groupValue: currentSort,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(transactionSortProvider.notifier).state = value;
                    }
                    Navigator.of(context).pop();
                  },
                  activeColor: _neubrutalismAccent,
                );
              }).toList(),
            ),
            actions: [
              NeuTextButton(
                onPressed: () => Navigator.of(context).pop(),
                text: const Text('Tutup'),
                buttonColor: Colors.white,
                borderColor: _neubrutalismBorder,
                shadowColor: _neubrutalismBorder,
                enableAnimation: true,
              )
            ],
          ),
        );
      },
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
        // Adjust endDate to include the entire day (23:59:59)
        final adjustedEndDate = pickedDate.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        ref.read(dateRangeProvider.notifier).state = (start: dateRange.start, end: adjustedEndDate);
      }
      // Force filteredTransactionsProvider to re-fetch data
      ref.refresh(filteredTransactionsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the async provider for loading/error state
    final transactionsAsyncValue = ref.watch(currentTransactionsProvider);
    // Watch the sync provider for the filtered/sorted list
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    
    final itemsAsyncValue = ref.watch(currentItemsProvider); // Watch item provider to get item names

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row( // Wrap in a Row to place sort button next to text
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Barang Keluar Masuk',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _neubrutalismText,
                          ),
                    ),
                  ),
                  Row( // Wrap sort and clear buttons in a Row
                    children: [
                      NeuIconButton(
                        onPressed: () {
                          ref.read(dateRangeProvider.notifier).state = (start: null, end: null); // Clear date range
                        },
                        icon: const Icon(Icons.refresh, color: _neubrutalismText),
                        buttonColor: Colors.white,
                        borderColor: _neubrutalismBorder,
                        shadowColor: _neubrutalismBorder,
                        enableAnimation: true,
                        buttonHeight: 40,
                        buttonWidth: 40,
                      ),
                      const SizedBox(width: 8),
                      NeuIconButton(
                        onPressed: () => _showSortDialog(context, ref),
                        icon: const Icon(Icons.sort, color: _neubrutalismText),
                        buttonColor: Colors.white,
                        borderColor: _neubrutalismBorder,
                        shadowColor: _neubrutalismBorder,
                        enableAnimation: true,
                        buttonHeight: 40,
                        buttonWidth: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: _neubrutalismText),
                                const SizedBox(width: 8),
                                Text(
                                  ref.watch(dateRangeProvider).start == null ? 'Mulai' : DateFormat('dd/MM/yy').format(ref.watch(dateRangeProvider).start!),
                                  style: const TextStyle(color: _neubrutalismText),
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: _neubrutalismText),
                                const SizedBox(width: 8),
                                Text(
                                  ref.watch(dateRangeProvider).end == null ? 'Akhir' : DateFormat('dd/MM/yy').format(ref.watch(dateRangeProvider).end!),
                                  style: const TextStyle(color: _neubrutalismText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                NeuTextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TransactionFormPage(),
                      ),
                    );
                  },
                  text: const Text(
                    'Tambah Transaksi',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  buttonColor: _neubrutalismAccent,
                  borderColor: _neubrutalismBorder,
                  shadowColor: _neubrutalismBorder,
                  enableAnimation: true,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactionsAsyncValue.when(
              data: (transactions) { // We get the raw list here to check for emptiness
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada transaksi. Tambahkan satu!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // But we display the filtered and sorted list
                final transactionsToDisplay = filteredTransactions;
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(currentTransactionsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: transactionsToDisplay.length,
                    itemBuilder: (context, index) {
                      final transaction = transactionsToDisplay[index];
                      
                      // Find item name from itemsAsyncValue
                      String itemName = 'Item Tidak Ditemukan';
                      itemsAsyncValue.whenData((items) {
                        try {
                          if (transaction.itemId.isNotEmpty) {
                            final foundItem = items.firstWhere((item) => item.id == transaction.itemId);
                            itemName = foundItem.name;
                          }
                        } catch (e) {
                          // Item not found, keep default name
                        }
                      });

                      final isMasuk = transaction.type == TransactionType.inType;
                      final transactionTypeLabel = isMasuk ? 'Masuk' : 'Keluar';
                      final transactionColor = isMasuk ? Colors.green.shade700 : Colors.red.shade700;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: NeuContainer(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          borderColor: _neubrutalismBorder,
                          borderWidth: _neubrutalismBorderWidth,
                          shadowColor: _neubrutalismBorder,
                          offset: _neubrutalismShadowOffset,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            title: Text(
                              itemName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: _neubrutalismText),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tipe: $transactionTypeLabel',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _neubrutalismText.withAlpha((255 * 0.7).round())),
                                ),
                                Text(
                                  'Jumlah: ${transaction.quantity}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _neubrutalismText.withAlpha((255 * 0.7).round())),
                                ),
                                Text(
                                  'Tanggal: ${transaction.date.toLocal().toString().split(' ')[0]}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _neubrutalismText.withAlpha((255 * 0.5).round())),
                                ),
                                if (transaction.note != null && transaction.note!.isNotEmpty)
                                  Text(
                                    'Catatan: ${transaction.note}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _neubrutalismText.withAlpha((255 * 0.5).round())),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              '${isMasuk ? '+' : '-'}${transaction.quantity}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: transactionColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              // Navigate to transaction detail/edit page
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TransactionFormPage(transaction: transaction),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
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
}