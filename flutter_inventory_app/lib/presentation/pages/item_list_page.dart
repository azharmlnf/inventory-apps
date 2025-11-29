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
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:intl/intl.dart';


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
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.75, // Adjust this ratio to fit content
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _ItemCard(item: item);
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
      
  // ... (Dialog methods _showSortDialog, _showFilterDialog, _confirmDeleteItem are unchanged)
  // ... They will be called from the _ItemCard now.

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
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Hapus Barang', style: Theme.of(context).textTheme.titleLarge),
          content: Text('Apakah Anda yakin ingin menghapus barang "${item.name}"?', style: Theme.of(context).textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); 
                try {
                  await ref.read(itemProvider.notifier).deleteItem(item.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Barang "${item.name}" berhasil dihapus.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
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

// New Widget for the Grid View Item
class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = item.imageId != null
        ? ref.read(itemServiceProvider).getImageUrl(item.imageId!)
        : null;
    final isLowStock = item.quantity <= item.minQuantity;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ItemDetailPage(item: item)),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias, // Important for image border radius
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                AspectRatio(
                  aspectRatio: 1.5,
                  child: Container(
                    color: Colors.grey[200],
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                            loadingBuilder: (context, child, progress) =>
                              progress == null ? child : const Center(child: CircularProgressIndicator()),
                          )
                        : const Center(child: Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 40)),
                  ),
                ),
                // Details Section
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stok: ${item.quantity} ${item.unit}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(item.salePrice ?? 0),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Low Stock Banner
            if (isLowStock)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)],
                  ),
                  child: const Text(
                    'Stok Rendah',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            // Popup Menu for Actions
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: imageUrl != null ? Colors.white : Colors.grey.shade700),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ItemFormPage(item: item)));
                  } else if (value == 'delete') {
                    // We need to access the _ItemListPageState to call the dialog
                    // A better way is to use a provider, but for simplicity, let's find the state
                    final parentState = context.findAncestorStateOfType<_ItemListPageState>();
                    parentState?._confirmDeleteItem(context, ref, item);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(leading: Icon(Icons.delete), title: Text('Hapus')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
