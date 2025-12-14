import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/item/providers/item_search_provider.dart';
import 'package:flutter_inventory_app/presentation/pages/item_detail_page.dart';
import 'package:flutter_inventory_app/features/item/pages/item_form_page.dart';

const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismAccent = Color(0xFFE84A5F);
const Color _neubrutalismBorder = Colors.black;
const Offset _neubrutalismShadowOffset = Offset(4, 4);

class ItemListPage extends ConsumerStatefulWidget {
  const ItemListPage({super.key});

  @override
  ConsumerState<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends ConsumerState<ItemListPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(itemSearchQueryProvider);
    // The onChanged property of the TextField is now used directly.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAdLoaded) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    if (kIsWeb || ref.read(authControllerProvider).isPremium) return;
    _bannerAd = ref.read(adServiceProvider).createBannerAd(
      onAdLoaded: () => setState(() => _isAdLoaded = true),
      onAdFailedToLoad: (error) => _bannerAd?.dispose(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(itemSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsyncValue = ref.watch(itemsProvider);
    final categoryFilter = ref.watch(itemCategoryFilterProvider);
    final searchQuery = ref.watch(itemSearchQueryProvider);

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      body: Column(
        children: [
          _buildHeader(context, categoryFilter),
          Expanded(
            child: itemsAsyncValue.when(
              data: (items) {
                final filteredItems = items.where((item) {
                  return item.name.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.isEmpty ? 'Belum ada barang.' : 'Barang tidak ditemukan.',
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(itemsProvider),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return _ItemCard(
                        item: filteredItems[index],
                        onDelete: (itemToDelete) => _confirmDeleteItem(context, ref, itemToDelete),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: _neubrutalismAccent)),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          if (_bannerAd != null && _isAdLoaded)
            SafeArea(
              top: false,
              child: Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? categoryFilter) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: NeuContainer(
                    borderColor: _neubrutalismBorder,
                    shadowColor: _neubrutalismBorder,
                    offset: _neubrutalismShadowOffset,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged, // Fix: Use onChanged
                        decoration: InputDecoration(
                          hintText: 'Cari barang...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: _neubrutalismBorder.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                NeuIconButton(
                  buttonColor: Colors.white,
                  borderColor: _neubrutalismBorder,
                  shadowColor: _neubrutalismBorder,
                  enableAnimation: true,
                  icon: Icon(
                    categoryFilter == null ? Icons.filter_list_off_outlined : Icons.filter_list,
                    color: categoryFilter == null ? Colors.grey : _neubrutalismAccent,
                  ),
                  onPressed: () => _showFilterDialog(context, ref),
                ),
                const SizedBox(width: 8),
                NeuIconButton(
                   buttonColor: Colors.white,
                  borderColor: _neubrutalismBorder,
                  shadowColor: _neubrutalismBorder,
                  enableAnimation: true,
                  icon: const Icon(Icons.sort, color: _neubrutalismBorder),
                  onPressed: () => _showSortDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NeuTextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ItemFormPage())),
              enableAnimation: true,
              buttonColor: _neubrutalismAccent,
              borderColor: _neubrutalismBorder,
              shadowColor: _neubrutalismBorder,
              text: const Text(
                'Tambah Barang Baru',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(itemSortProvider);
    showDialog(
      context: context,
      builder: (context) {
        return NeuContainer(
          borderRadius: BorderRadius.circular(12),
          color: _neubrutalismBg,
          borderColor: _neubrutalismBorder,
          shadowColor: _neubrutalismBorder,
          offset: _neubrutalismShadowOffset,
          child: AlertDialog(
            backgroundColor: _neubrutalismBg,
            elevation: 0,
            title: const Text('Urutkan Berdasarkan', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: ItemSortType.values.map((sortType) {
                return RadioListTile<ItemSortType>(
                  title: Text(sortType.label),
                  value: sortType,
                  groupValue: currentSort,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(itemSortProvider.notifier).state = value;
                    }
                    Navigator.of(context).pop();
                  },
                  activeColor: _neubrutalismAccent,
                );
              }).toList(),
            ),
            actions: [
              NeuTextButton(
                onPressed: () => Navigator.of(context).pop(),
                text: const Text('Tutup'),
                buttonColor: Colors.white,
                borderColor: _neubrutalismBorder,
                shadowColor: _neubrutalismBorder,
                enableAnimation: true,
              )
            ],
          ),
        );
      },
    );
  }
      
  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final currentFilter = ref.read(itemCategoryFilterProvider);
  
    showDialog(
      context: context,
      builder: (context) {
        return NeuContainer(
          borderRadius: BorderRadius.circular(12),
          color: _neubrutalismBg,
          borderColor: _neubrutalismBorder,
          shadowColor: _neubrutalismBorder,
          offset: _neubrutalismShadowOffset,
          child: AlertDialog(
            elevation: 0,
            backgroundColor: _neubrutalismBg,
            title: const Text('Filter Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
            content: categoriesAsync.when(
              data: (categories) {
                return SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      RadioListTile<String?>(
                        title: const Text('Semua Kategori'),
                        value: null,
                        groupValue: currentFilter,
                        onChanged: (value) {
                          ref.read(itemCategoryFilterProvider.notifier).state = value;
                          Navigator.of(context).pop();
                        },
                        activeColor: _neubrutalismAccent,
                      ),
                      ...categories.map((cat) {
                        return RadioListTile<String?>(
                          title: Text(cat.name),
                          value: cat.id,
                          groupValue: currentFilter,
                          onChanged: (value) {
                            ref.read(itemCategoryFilterProvider.notifier).state = value;
                            Navigator.of(context).pop();
                          },
                          activeColor: _neubrutalismAccent,
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Gagal memuat kategori: $e', style: const TextStyle(color: Colors.red)),
            ),
            actions: [
              NeuTextButton(
                onPressed: () => Navigator.of(context).pop(),
                text: const Text('Tutup'),
                buttonColor: Colors.white,
                borderColor: _neubrutalismBorder,
                shadowColor: _neubrutalismBorder,
                enableAnimation: true,
              )
            ],
          ),
        );
      },
    );
  }
  
  void _confirmDeleteItem(BuildContext context, WidgetRef ref, Item item) {
    showDialog(
      context: context,
      builder: (dialogContext) => NeuContainer(
        color: _neubrutalismBg,
        borderColor: _neubrutalismBorder,
        shadowColor: _neubrutalismBorder,
        borderRadius: BorderRadius.circular(12),
        child: AlertDialog(
          elevation: 0,
          backgroundColor: _neubrutalismBg,
          title: const Text('Hapus Barang', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Anda yakin ingin menghapus "${item.name}"?'),
          actions: [
            NeuTextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              text: const Text('Batal'),
              buttonColor: Colors.white,
              borderColor: _neubrutalismBorder,
              shadowColor: _neubrutalismBorder,
              enableAnimation: true,
            ),
            NeuTextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); 
                try {
                  await ref.read(itemsProvider.notifier).deleteItem(item);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${item.name}" berhasil dihapus.'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              buttonColor: _neubrutalismAccent,
              borderColor: _neubrutalismBorder,
              shadowColor: _neubrutalismBorder,
              enableAnimation: true,
              text: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item, required this.onDelete});

  final Item item;
  final Function(Item) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = item.imageId != null ? ref.read(itemServiceProvider).getImageUrl(item.imageId) : null;
    final isLowStock = item.quantity <= item.minQuantity;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return NeuContainer(
      borderColor: _neubrutalismBorder,
      shadowColor: _neubrutalismBorder,
      offset: _neubrutalismShadowOffset,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ItemDetailPage(item: item)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                          )
                        : const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stok: ${item.quantity} ${item.unit}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(item.salePrice ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: _neubrutalismAccent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isLowStock)
              Positioned(
                top: 8,
                left: 8,
                child: NeuContainer(
                  color: _neubrutalismAccent,
                  borderColor: _neubrutalismBorder,
                  shadowColor: _neubrutalismBorder,
                  offset: const Offset(2, 2),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Stok Rendah',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: NeuIconButton(
                buttonColor: Colors.white.withOpacity(0.7),
                enableAnimation: true,
                buttonHeight: 40,
                buttonWidth: 40,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.transparent,
                      contentPadding: EdgeInsets.zero,
                      insetPadding: const EdgeInsets.all(10),
                      content: NeuContainer(
                        color: _neubrutalismBg,
                        borderColor: _neubrutalismBorder,
                        shadowColor: _neubrutalismBorder,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             NeuTextButton(
                                text: const Text('Edit'),
                                onPressed: (){
                                  Navigator.of(ctx).pop();
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ItemFormPage(item: item)));
                                },
                                buttonColor: Colors.white,
                                borderColor: _neubrutalismBorder,
                                shadowColor: _neubrutalismBorder,
                                enableAnimation: true,
                             ),
                              NeuTextButton(
                                text: const Text('Hapus', style: TextStyle(color: _neubrutalismAccent)),
                                onPressed: (){
                                  Navigator.of(ctx).pop();
                                  onDelete(item);
                                },
                                buttonColor: Colors.white,
                                borderColor: _neubrutalismBorder,
                                shadowColor: _neubrutalismBorder,
                                enableAnimation: true,
                             ),
                          ],
                        ),
                      ),
                    )
                  );
                },
                icon: const Icon(Icons.more_vert, color: _neubrutalismBorder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
