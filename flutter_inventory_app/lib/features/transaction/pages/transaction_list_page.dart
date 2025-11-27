import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_provider.dart'; // To get item details
 // To use Item model
import 'package:flutter_inventory_app/features/transaction/pages/transaction_form_page.dart'; // For adding/editing transactions

class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionProvider);
    final itemsAsyncValue = ref.watch(itemProvider); // Watch item provider to get item names

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Transaksi'),
      ),
      body: transactionsAsyncValue.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada transaksi. Tambahkan satu!',
                textAlign: TextAlign.center,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transactionProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                
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

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(
                      itemName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipe: $transactionTypeLabel',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Jumlah: ${transaction.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Tanggal: ${transaction.date.toLocal().toString().split(' ')[0]}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (transaction.note != null && transaction.note!.isNotEmpty)
                          Text(
                            'Catatan: ${transaction.note}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    trailing: Text(
                      '${isMasuk ? '+' : '-'}${transaction.quantity}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: transactionColor,
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
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TransactionFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}