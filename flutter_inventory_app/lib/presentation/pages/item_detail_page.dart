import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:intl/intl.dart';

import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/item/pages/item_form_page.dart';

const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismAccent = Color(0xFFE84A5F);
const Color _neubrutalismBorder = Colors.black;
const Offset _neubrutalismShadowOffset = Offset(4, 4);

class ItemDetailPage extends ConsumerWidget {
  final Item item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryName = ref.watch(categoriesProvider).when(
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
      backgroundColor: _neubrutalismBg,
      appBar: AppBar(
        title: Text(item.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: _neubrutalismBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: NeuIconButton(
              enableAnimation: true,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ItemFormPage(item: item)),
                );
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
            ),
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
              if (item.barcode != null && item.barcode!.isNotEmpty)
                _buildDetailRow(context, 'Barcode', item.barcode!),
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
                  child: NeuContainer(
                    color: Colors.red.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Peringatan: Stok Rendah!',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
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
              _buildDetailRow(context, 'Harga Beli', NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(item.purchasePrice ?? 0)),
              _buildDetailRow(context, 'Harga Jual', NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(item.salePrice ?? 0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(BuildContext context, String imageUrl) {
    return NeuContainer(
      borderColor: _neubrutalismBorder,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error, __) => _buildImagePlaceholder(context, hasError: true, error: error),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, {bool hasError = false, Object? error}) {
    return NeuContainer(
      borderColor: _neubrutalismBorder,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey[200],
      height: 200,
      width: double.infinity,
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
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, List<Widget> children) {
    return NeuContainer(
      borderColor: _neubrutalismBorder,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: NeuContainer(
                width: double.infinity,
                height: 2,
                color: _neubrutalismBorder,
                borderRadius: BorderRadius.zero,
              ),
            ),
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
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}