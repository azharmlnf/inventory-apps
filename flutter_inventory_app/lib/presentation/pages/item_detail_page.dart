import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/category/providers/category_provider.dart';
import 'package:flutter_inventory_app/presentation/pages/item_form_page.dart';

class ItemDetailPage extends ConsumerWidget {
  final Item item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Helper untuk mendapatkan nama kategori dari ID
    final categoryName = ref.watch(categoryProvider).when(
          data: (categories) {
            try {
              return categories.firstWhere((cat) => cat.id == item.categoryId).name;
            } catch (e) {
              return 'Tidak Berkategori';
            }
          },
          loading: () => '...',
          error: (e, s) => 'Error',
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
            tooltip: 'Edit Barang',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ItemFormPage(item: item),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDetailCard(
            context,
            'Informasi Umum',
            [
              _buildDetailRow(context, 'Nama', item.name),
              if (item.brand != null && item.brand!.isNotEmpty)
                _buildDetailRow(context, 'Merek', item.brand!),
              if (item.description != null && item.description!.isNotEmpty)
                _buildDetailRow(context, 'Deskripsi', item.description!),
              _buildDetailRow(context, 'Kategori', categoryName),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            context,
            'Informasi Stok',
            [
              _buildDetailRow(context, 'Kuantitas', '${item.quantity} ${item.unit}'),
              _buildDetailRow(context, 'Batas Stok Rendah', '${item.minQuantity} ${item.unit}'),
              if (item.quantity <= item.minQuantity)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Peringatan: Stok Rendah!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            context,
            'Informasi Harga',
            [
              _buildDetailRow(context, 'Harga Beli', 'Rp ${item.purchasePrice?.toStringAsFixed(0) ?? '0'}'),
              _buildDetailRow(context, 'Harga Jual', 'Rp ${item.salePrice?.toStringAsFixed(0) ?? '0'}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
