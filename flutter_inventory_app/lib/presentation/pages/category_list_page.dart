import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/features/category/providers/category_provider.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';

class CategoryListPage extends ConsumerStatefulWidget {
  const CategoryListPage({super.key});

  @override
  ConsumerState<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends ConsumerState<CategoryListPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    // _loadBannerAd() is now called in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load the ad here to handle rebuilds, e.g., after a dialog closes.
    if (!_isAdLoaded) {
      _loadBannerAd();
    }
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    // Jangan tampilkan iklan jika user premium
    if (ref.read(authControllerProvider).isPremium) {
      return;
    }

    _bannerAd = ref.read(adServiceProvider).createBannerAd(
      onAdLoaded: () { // Callback tanpa parameter 'ad'
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (error) { // Callback dengan satu parameter 'error'
        _bannerAd?.dispose(); // Dispose banner ad yang gagal dimuat
        if (mounted) {
          setState(() { // Opsional: set _isAdLoaded ke false jika ingin UI bereaksi
            _isAdLoaded = false;
          });
        }
      },
    );
  }

  void _loadInterstitialAd() {
    if (ref.read(authControllerProvider).isPremium) {
      return;
    }
    ref.read(adServiceProvider).createInterstitialAd(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
      },
    );
  }

  void _showInterstitialAd(VoidCallback onAdDismissed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Muat iklan baru untuk aksi berikutnya
          onAdDismissed(); // Panggil callback setelah iklan ditutup
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdDismissed(); // Langsung panggil callback jika iklan gagal tampil
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null; // Set null agar tidak ditampilkan dua kali
    } else {
      onAdDismissed(); // Jika tidak ada iklan (misal: user premium), langsung panggil callback
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
      ),
      body: Column(
        children: [
          Expanded(
            child: categoriesAsyncValue.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(child: Text('Belum ada kategori. Tambahkan satu!'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        title: Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                              onPressed: () => _showEditCategoryDialog(context, ref, category),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                              onPressed: () => _confirmDeleteCategory(context, ref, category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          if (_bannerAd != null && _isAdLoaded)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tambah Kategori Baru', style: Theme.of(context).textTheme.titleLarge),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(categoryProvider.notifier).addCategory(name: controller.text);
                _showInterstitialAd(() {
                  Navigator.pop(dialogContext);
                });
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, Category category) {
    final TextEditingController controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Kategori', style: Theme.of(context).textTheme.titleLarge),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) { // Kondisi "!=" dihapus
                // Tunggu proses update selesai
                await ref.read(categoryProvider.notifier).updateCategory(categoryId: category.id, name: controller.text);
                
                // Tampilkan iklan, dan pop context dialog setelah iklan ditutup
                _showInterstitialAd(() {
                  Navigator.pop(dialogContext);
                });
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Kategori', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(categoryProvider.notifier).deleteCategory(categoryId: category.id);
              _showInterstitialAd(() {
                Navigator.pop(dialogContext);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
