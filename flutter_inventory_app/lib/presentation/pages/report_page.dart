import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/domain/services/export_service.dart';
import 'package:flutter_inventory_app/features/home/providers/dashboard_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:intl/intl.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  @override
  Widget build(BuildContext context) {
    final dateRange = ref.watch(dateRangeProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final allItems = ref.watch(allItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(dateRangeProvider.notifier).state = (start: null, end: null);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final exportService = ref.read(exportServiceProvider);
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
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: dateRange.start ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      ref.read(dateRangeProvider.notifier).state = (
                        start: pickedDate,
                        end: dateRange.end,
                      );
                    }
                  },
                  child: Text(dateRange.start == null
                      ? 'Pilih Tanggal Mulai'
                      : 'Mulai: ${DateFormat('dd/MM/yyyy').format(dateRange.start!)}'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: dateRange.end ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      ref.read(dateRangeProvider.notifier).state = (
                        start: dateRange.start,
                        end: pickedDate,
                      );
                    }
                  },
                  child: Text(dateRange.end == null
                      ? 'Pilih Tanggal Akhir'
                      : 'Akhir: ${DateFormat('dd/MM/yyyy').format(dateRange.end!)}'),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTransactions.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(child: Text('Tidak ada transaksi pada rentang tanggal ini.'));
                }
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      title: Text('Item ID: ${transaction.itemId}'),
                      subtitle: Text(
                          'Jumlah: ${transaction.quantity} | Tipe: ${transaction.type.name}'),
                      trailing: Text(
                          DateFormat('dd/MM/yyyy').format(transaction.date)),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
