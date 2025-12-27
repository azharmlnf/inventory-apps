import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

// Top-level constants for Neubrutalism style
const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismAccent = Color(0xFFE84A5F);
const Color _neubrutalismText = Colors.black;
const Color _neubrutalismBorder = Colors.black;
const double _neubrutalismBorderWidth = 3.0;
const double _neubrutalismShadowOffset = 5.0;

class CategoryListPage extends ConsumerStatefulWidget {
  const CategoryListPage({super.key});

  @override
  ConsumerState<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends ConsumerState<CategoryListPage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  InterstitialAd? _interstitialAd;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.watch(sessionControllerProvider).value;

    final dynamic premiumValue = user?.prefs.data['isPremium'];
    bool isPremium = false;
    if (premiumValue is bool) {
      isPremium = premiumValue;
    } else if (premiumValue is String) {
      isPremium = premiumValue.toLowerCase() == 'true';
    }
    
    if (!isPremium && !_isAdLoaded) {
      _loadBannerAd();
    }
    if (!isPremium) {
      _loadInterstitialAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = ref.read(adServiceProvider).createBannerAd(
      onAdLoaded: () {
        if (mounted) setState(() => _isAdLoaded = true);
      },
      onAdFailedToLoad: (error) {
        _bannerAd?.dispose();
        if (mounted) setState(() => _isAdLoaded = false);
      },
    );
  }

  void _loadInterstitialAd() {
    ref.read(adServiceProvider).createInterstitialAd(
      onAdLoaded: (ad) => _interstitialAd = ad,
    );
  }

  void _showInterstitialAd(VoidCallback onAdDismissed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdDismissed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onAdDismissed();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(currentCategoriesProvider);

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      appBar: AppBar(
        title: null, // Title removed
        backgroundColor: _neubrutalismBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _neubrutalismText),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: NeuContainer(
              borderColor: _neubrutalismBorder,
              borderWidth: _neubrutalismBorderWidth,
              shadowColor: _neubrutalismBorder,
              offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari kategori...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: _neubrutalismText.withAlpha(100)),
                  ),
                ),
              ),
            ),
          ),
          // Add Category Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: NeuTextButton(
              enableAnimation: true,
              buttonColor: _neubrutalismAccent,
              borderColor: _neubrutalismBorder,
              shadowColor: _neubrutalismBorder,
              offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
              borderRadius: BorderRadius.circular(12),
              onPressed: () => _showCategoryFormBottomSheet(context),
              text: const Text(
                'Tambah Kategori',
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Category List
          Expanded(
            child: categoriesAsyncValue.when(
              data: (categories) {
                final filteredCategories = categories.where((category) {
                  return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Belum ada kategori.'
                          : 'Kategori tidak ditemukan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: _neubrutalismText.withAlpha(179)),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(currentCategoriesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: NeuContainer(
                          borderColor: _neubrutalismBorder,
                          borderWidth: _neubrutalismBorderWidth,
                          shadowColor: _neubrutalismBorder,
                          offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: _neubrutalismText,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    NeuIconButton(
                                      enableAnimation: true,
                                      onPressed: () => _showCategoryFormBottomSheet(context, category: category),
                                      buttonColor: Colors.yellow.shade200,
                                      borderColor: _neubrutalismBorder,
                                      shadowColor: _neubrutalismBorder,
                                      offset: const Offset(3, 3),
                                      borderRadius: BorderRadius.circular(8),
                                      icon: const Icon(Icons.edit_outlined, size: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    NeuIconButton(
                                      enableAnimation: true,
                                      onPressed: () => _confirmDeleteCategory(context, category),
                                      buttonColor: _neubrutalismAccent.withAlpha(179),
                                      borderColor: _neubrutalismBorder,
                                      shadowColor: _neubrutalismBorder,
                                      offset: const Offset(3, 3),
                                      borderRadius: BorderRadius.circular(8),
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: _neubrutalismAccent)),
              error: (error, stack) => Center(
                child: Text('Gagal memuat data: $error', textAlign: TextAlign.center, style: const TextStyle(color: _neubrutalismText)),
              ),
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

  void _showCategoryFormBottomSheet(BuildContext context, {Category? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return NeuContainer(
          color: _neubrutalismBg,
          borderColor: _neubrutalismBorder,
          borderWidth: _neubrutalismBorderWidth,
          shadowColor: _neubrutalismBorder,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: _CategoryFormContent(
            category: category,
            showInterstitialAd: _showInterstitialAd,
          ),
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return NeuContainer(
          color: _neubrutalismBg,
          borderColor: _neubrutalismBorder,
          borderWidth: _neubrutalismBorderWidth,
          shadowColor: _neubrutalismBorder,
          borderRadius: BorderRadius.circular(16),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: const EdgeInsets.all(20),
            title: const Text(
              'Konfirmasi Hapus',
              style: TextStyle(color: _neubrutalismText, fontWeight: FontWeight.bold),
            ),
            content: Text.rich(
              TextSpan(
                text: 'Anda yakin ingin menghapus kategori "',
                style: TextStyle(color: _neubrutalismText.withAlpha(179)),
                children: [
                  TextSpan(
                    text: category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: _neubrutalismText),
                  ),
                  const TextSpan(text: '"?'),
                ],
              ),
            ),
            actions: [
              NeuTextButton(
                enableAnimation: true,
                onPressed: () => Navigator.pop(dialogContext),
                buttonColor: Colors.white,
                borderColor: _neubrutalismBorder,
                shadowColor: _neubrutalismBorder,
                offset: const Offset(3, 3),
                borderRadius: BorderRadius.circular(8),
                text: const Text('Batal', style: TextStyle(color: _neubrutalismText)),
              ),
              NeuTextButton(
                enableAnimation: true,
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await ref.read(categoryServiceProvider).deleteCategory(category.id);
                    ref.invalidate(currentCategoriesProvider);
                    _showInterstitialAd(() {});
                  } catch (e) {
                    if(mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus: ${e.toString()}'))
                      );
                    }
                  }
                },
                buttonColor: _neubrutalismAccent,
                borderColor: _neubrutalismBorder,
                shadowColor: _neubrutalismBorder,
                offset: const Offset(3, 3),
                borderRadius: BorderRadius.circular(8),
                text: const Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryFormContent extends ConsumerStatefulWidget {
  final Category? category;
  final void Function(VoidCallback) showInterstitialAd;

  const _CategoryFormContent({
    this.category,
    required this.showInterstitialAd,
  });

  @override
  ConsumerState<_CategoryFormContent> createState() => __CategoryFormContentState();
}

class __CategoryFormContentState extends ConsumerState<_CategoryFormContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.category?.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);
      final session = ref.read(sessionControllerProvider).value;
      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi tidak valid. Mohon login kembali.'))
        );
        return;
      }

      try {
        if (_isEditing) {
          await ref.read(categoryServiceProvider).updateCategory(widget.category!.id, _controller.text.trim());
        } else {
          await ref.read(categoryServiceProvider).createCategory(session.$id, _controller.text.trim());
        }

        ref.invalidate(currentCategoriesProvider);
        
        widget.showInterstitialAd(() {
          if (mounted) {
            navigator.pop();
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: ${e.toString()}'))
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: keyboardPadding + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Edit Kategori' : 'Kategori Baru',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _neubrutalismText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            NeuContainer(
              borderColor: _neubrutalismBorder,
              borderWidth: _neubrutalismBorderWidth,
              shadowColor: _neubrutalismBorder,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    labelStyle: TextStyle(color: _neubrutalismText.withAlpha(179)),
                    border: InputBorder.none,
                    filled: false,
                  ),
                  style: const TextStyle(color: _neubrutalismText),
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama kategori tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            NeuTextButton(
              enableAnimation: true,
              buttonColor: _neubrutalismAccent,
              borderColor: _neubrutalismBorder,
              shadowColor: _neubrutalismBorder,
              borderRadius: BorderRadius.circular(12),
              onPressed: _submit,
              buttonHeight: 50,
              text: Text(
                _isEditing ? 'Simpan' : 'Tambah',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}