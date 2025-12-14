import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isPremium = ref.watch(authControllerProvider).isPremium;
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
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      appBar: AppBar(
        title: const Text(
          'Manajemen Kategori',
          style: TextStyle(color: _neubrutalismText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _neubrutalismBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _neubrutalismText),
      ),
      body: Column(
        children: [
          Expanded(
            child: categoriesAsyncValue.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada kategori.\nTekan tombol (+) untuk menambahkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: _neubrutalismText.withAlpha(179)),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(categoriesProvider.notifier).refreshCategories(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return NeuContainer(
                        borderColor: _neubrutalismBorder,
                        borderWidth: _neubrutalismBorderWidth,
                        shadowColor: _neubrutalismBorder,
                        offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: NeuTextButton(
          enableAnimation: true,
          buttonColor: _neubrutalismAccent,
          borderColor: _neubrutalismBorder,
          shadowColor: _neubrutalismBorder,
          offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
          borderRadius: BorderRadius.circular(12),
          buttonHeight: 50,
          onPressed: () => _showCategoryFormBottomSheet(context),
          text: const Text(
            'Tambah Kategori',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showCategoryFormBottomSheet(BuildContext context, {Category? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (ctx) {
        return NeuContainer(
          color: _neubrutalismBg,
          borderColor: _neubrutalismBorder,
          borderWidth: _neubrutalismBorderWidth,
          shadowColor: _neubrutalismBorder,
          offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
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
          offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
          borderRadius: BorderRadius.circular(16),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            title: const Text(
              'Konfirmasi Hapus',
              style: TextStyle(color: _neubrutalismText, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text.rich(
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
                  await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
                  _showInterstitialAd(() {
                    Navigator.pop(dialogContext);
                  });
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
      final notifier = ref.read(categoriesProvider.notifier);
      final navigator = Navigator.of(context);
      
      final future = _isEditing
          ? notifier.updateCategory(widget.category!.id, _controller.text.trim())
          : notifier.addCategory(_controller.text.trim());

      await future;

      widget.showInterstitialAd(() {
        if (mounted) {
          navigator.pop();
        }
      });
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
              offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
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
                    floatingLabelBehavior: FloatingLabelBehavior.never,
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
              offset: const Offset(_neubrutalismShadowOffset, _neubrutalismShadowOffset),
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
