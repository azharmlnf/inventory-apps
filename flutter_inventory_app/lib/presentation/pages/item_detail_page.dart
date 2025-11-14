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
            icon: const Icon(Icons.edit),
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
            'Informasi Umum',
            [
              _buildDetailRow('Nama', item.name),
              if (item.brand != null && item.brand!.isNotEmpty)
                _buildDetailRow('Merek', item.brand!),
              if (item.description != null && item.description!.isNotEmpty)
                _buildDetailRow('Deskripsi', item.description!),
              _buildDetailRow('Kategori', categoryName),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            'Informasi Stok',
            [
              _buildDetailRow('Kuantitas', '${item.quantity} ${item.unit}'),
              _buildDetailRow('Batas Stok Rendah', '${item.minQuantity} ${item.unit}'),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            'Informasi Harga',
            [
              _buildDetailRow('Harga Beli', 'Rp ${item.purchasePrice?.toStringAsFixed(0) ?? '0'}'),
              _buildDetailRow('Harga Jual', 'Rp ${item.salePrice?.toStringAsFixed(0) ?? '0'}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
