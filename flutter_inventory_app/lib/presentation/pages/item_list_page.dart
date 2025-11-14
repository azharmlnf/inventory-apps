import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/category/providers/category_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_search_provider.dart';
import 'package:flutter_inventory_app/presentation/pages/item_detail_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_form_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemListPage extends ConsumerStatefulWidget {
  const ItemListPage({super.key});

  @override
  ConsumerState<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends ConsumerState<ItemListPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Sync search controller with provider state if needed when page loads
    _searchController.text = ref.read(itemSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(itemSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsyncValue = ref.watch(itemProvider);
    final categoryFilter = ref.watch(itemCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari barang...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          IconButton(
            icon: Icon(categoryFilter == null ? Icons.filter_list_off_outlined : Icons.filter_list),
            tooltip: 'Filter by Category',
            onPressed: () => _showFilterDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Items',
            onPressed: () => _showSortDialog(context, ref),
          ),
        ],
      ),
      body: itemsAsyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Barang tidak ditemukan atau belum ada.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(itemProvider);
            },
            child: ListView.builder(
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
                      'Stok: ${item.quantity} ${item.unit} | Harga: Rp ${item.salePrice?.toStringAsFixed(0) ?? '0'}',
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
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ItemDetailPage(item: item),
                                          ),
                                        );
                                      },                  ),
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
              builder: (context) => const ItemFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(itemSortProvider);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: ItemSortType.values.map((sortType) {
            return ListTile(
              title: Text(sortType.label),
              leading: Radio<ItemSortType>(
                value: sortType,
                groupValue: currentSort,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(itemSortProvider.notifier).state = value;
                  }
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                ref.read(itemSortProvider.notifier).state = sortType;
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);
    final currentFilter = ref.read(itemCategoryFilterProvider);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Category'),
          content: categoriesAsync.when(
            data: (categories) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: const Text('Semua Kategori'),
                      leading: Radio<String?>(
                        value: null,
                        groupValue: currentFilter,
                        onChanged: (value) {
                          ref.read(itemCategoryFilterProvider.notifier).state = value;
                          Navigator.of(context).pop();
                        },
                      ),
                      onTap: () {
                        ref.read(itemCategoryFilterProvider.notifier).state = null;
                        Navigator.of(context).pop();
                      },
                    ),
                    ...categories.map((cat) {
                      return ListTile(
                        title: Text(cat.name),
                        leading: Radio<String?>(
                          value: cat.id,
                          groupValue: currentFilter,
                          onChanged: (value) {
                            ref.read(itemCategoryFilterProvider.notifier).state = value;
                            Navigator.of(context).pop();
                          },
                        ),
                        onTap: () {
                          ref.read(itemCategoryFilterProvider.notifier).state = cat.id;
                          Navigator.of(context).pop();
                        },
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Text('Gagal memuat kategori.'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            )
          ],
        );
      },
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
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog first
              try {
                await ref.read(itemProvider.notifier).deleteItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Barang "${item.name}" berhasil dihapus.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
