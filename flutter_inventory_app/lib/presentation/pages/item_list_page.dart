import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/item/providers/item_provider.dart';
import 'package:flutter_inventory_app/presentation/pages/item_form_page.dart';

class ItemListPage extends ConsumerWidget {
  const ItemListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsyncValue = ref.watch(itemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(itemProvider),
          ),
        ],
      ),
      body: itemsAsyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada barang. Tekan tombol + untuk menambah.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isLowStock = item.quantity <= item.minQuantity;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  side: isLowStock
                      ? const BorderSide(color: Colors.red, width: 1.5)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Stok: ${item.quantity} ${item.unit} | Harga: Rp ${item.salePrice.toStringAsFixed(0)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ItemFormPage(item: item),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteItem(context, ref, item),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Optional: Show item details page
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ItemFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, WidgetRef ref, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus barang "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(itemProvider.notifier).deleteItem(item.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
