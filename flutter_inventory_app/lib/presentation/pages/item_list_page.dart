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
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
            fillColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
            prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          onChanged: _onSearchChanged,
        ),
        actions: [
          IconButton(
            icon: Icon(
              categoryFilter == null ? Icons.filter_list_off_outlined : Icons.filter_list,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            tooltip: 'Filter by Category',
            onPressed: () => _showFilterDialog(context, ref),
          ),
          IconButton(
            icon: Icon(Icons.sort, color: Theme.of(context).colorScheme.onPrimary),
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
              padding: const EdgeInsets.all(12.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isLowStock = item.quantity <= item.minQuantity;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: isLowStock
                        ? BorderSide(color: Colors.red.shade400, width: 1.5)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stok: ${item.quantity} ${item.unit}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Harga Jual: Rp ${item.salePrice?.toStringAsFixed(0) ?? '0'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isLowStock)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Stok Rendah!',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ItemFormPage(item: item),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Urutkan Berdasarkan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    ...ItemSortType.values.map((sortType) {
                      return RadioListTile<ItemSortType>(
                        title: Text(sortType.label, style: Theme.of(context).textTheme.bodyLarge),
                        value: sortType,
                        groupValue: currentSort,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(itemSortProvider.notifier).state = value;
                          }
                          Navigator.of(context).pop();
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      );
                    }),
                  ],
                ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Filter Berdasarkan Kategori', style: Theme.of(context).textTheme.titleLarge),
                content: categoriesAsync.when(
                  data: (categories) {
                    return SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          RadioListTile<String?>(
                            title: Text('Semua Kategori', style: Theme.of(context).textTheme.bodyLarge),
                            value: null,
                            groupValue: currentFilter,
                            onChanged: (value) {
                              ref.read(itemCategoryFilterProvider.notifier).state = value;
                              Navigator.of(context).pop();
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          ...categories.map((cat) {
                            return RadioListTile<String?>(
                              title: Text(cat.name, style: Theme.of(context).textTheme.bodyLarge),
                              value: cat.id,
                              groupValue: currentFilter,
                              onChanged: (value) {
                                ref.read(itemCategoryFilterProvider.notifier).state = value;
                                Navigator.of(context).pop();
                              },
                              activeColor: Theme.of(context).colorScheme.primary,
                            );
                          }),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Gagal memuat kategori: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Tutup', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  )
                ],
              );
            },
          );
        }
      
        void _confirmDeleteItem(BuildContext context, WidgetRef ref, Item item) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog( // Use dialogContext to avoid confusion
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Hapus Barang', style: Theme.of(context).textTheme.titleLarge),
              content: Text('Apakah Anda yakin ingin menghapus barang "${item.name}"?', style: Theme.of(context).textTheme.bodyMedium),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(), // Use dialogContext here
                  child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // dialogContext is still valid to pop the dialog
                    Navigator.of(dialogContext).pop(); 
                    try {
                      await ref.read(itemProvider.notifier).deleteItem(item.id);
                      if (mounted) { // Check mounted before using widget.context
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Barang "${item.name}" berhasil dihapus.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) { // Check mounted before using widget.context
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menghapus: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      }
