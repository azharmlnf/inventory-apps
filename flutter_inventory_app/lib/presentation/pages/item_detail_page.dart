import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/category/providers/category_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
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

    final imageUrl = item.imageId != null
        ? ref.read(itemServiceProvider).getImageUrl(item.imageId!)
        : null;

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
          if (imageUrl != null)
            _buildItemImage(context, imageUrl)
          else
            _buildImagePlaceholder(context),
          const SizedBox(height: 16),
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

  Widget _buildItemImage(BuildContext context, String imageUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          return progress == null ? child : const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          // Pass the actual error to the placeholder for debugging
          return _buildImagePlaceholder(context, hasError: true, error: error);
        },
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, {bool hasError = false, Object? error}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasError ? Icons.error_outline : Icons.image_not_supported_outlined,
              size: 60,
              color: hasError ? Colors.red : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              hasError ? 'Gagal Memuat Gambar' : 'Tidak Ada Gambar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            // Display the actual error if available
            if (hasError && error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
                ),
              ),
          ],
        ),
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
