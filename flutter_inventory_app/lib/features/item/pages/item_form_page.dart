import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';

import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';

const Color _neubrutalismBg = Color(0xFFF9F9F9);
const Color _neubrutalismAccent = Color(0xFFE84A5F);
const Color _neubrutalismBorder = Colors.black;
const Offset _neubrutalismShadowOffset = Offset(4, 4);

class ItemFormPage extends ConsumerStatefulWidget {
  final Item? item;
  const ItemFormPage({super.key, this.item});

  @override
  ConsumerState<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends ConsumerState<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _minQuantityController;
  late TextEditingController _unitController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  String? _selectedCategoryId;
  bool _isLoading = false;
  File? _imageFile;
  String? _networkImageUrl;
  final ImagePicker _picker = ImagePicker();
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _barcodeController = TextEditingController(text: item?.barcode ?? '');
    _brandController = TextEditingController(text: item?.brand ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _quantityController = TextEditingController(text: item?.quantity.toString() ?? '0');
    _minQuantityController = TextEditingController(text: item?.minQuantity.toString() ?? '10');
    _unitController = TextEditingController(text: item?.unit ?? 'Pcs');
    _purchasePriceController = TextEditingController(text: item?.purchasePrice?.toStringAsFixed(0) ?? '');
    _salePriceController = TextEditingController(text: item?.salePrice?.toStringAsFixed(0) ?? '');
    _selectedCategoryId = item?.categoryId;

    final imageId = widget.item?.imageId;
    if (imageId != null && imageId.isNotEmpty) {
      _networkImageUrl = ref.read(itemServiceProvider).getImageUrl(imageId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    if (kIsWeb || ref.read(authControllerProvider).isPremium) return;
    ref.read(adServiceProvider).createInterstitialAd(
      onAdLoaded: (ad) => _interstitialAd = ad,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _unitController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 800);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _networkImageUrl = null;
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _neubrutalismBg,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              NeuTextButton(
                text: const Text("Galeri"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
                buttonColor: Colors.white,
                borderColor: _neubrutalismBorder,
                shadowColor: _neubrutalismBorder,
                enableAnimation: true,
              ),
              const SizedBox(height: 10),
              NeuTextButton(
                text: const Text("Kamera"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
                buttonColor: Colors.white,
                borderColor: _neubrutalismBorder,
                shadowColor: _neubrutalismBorder,
                enableAnimation: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final isEditMode = widget.item != null;
      final itemName = _nameController.text.trim();
      bool shouldContinue = true;

      if (!isEditMode || (isEditMode && itemName != widget.item!.name)) {
        final exists = await ref.read(itemServiceProvider).itemExists(name: itemName);
        if (mounted && exists) {
          final continueSave = await showDialog<bool>(
            context: context,
            builder: (context) => NeuContainer(
              color: _neubrutalismBg,
              borderColor: _neubrutalismBorder,
              shadowColor: _neubrutalismBorder,
              borderRadius: BorderRadius.circular(12),
              child: AlertDialog(
                elevation: 0,
                backgroundColor: _neubrutalismBg,
                title: const Text('Barang Sudah Ada', style: TextStyle(fontWeight: FontWeight.bold)),
                content: Text('Barang dengan nama "$itemName" sudah ada. Tetap simpan?'),
                actions: [
                  NeuTextButton(onPressed: () => Navigator.of(context).pop(false), text: const Text("Batal"), buttonColor: Colors.white, borderColor: _neubrutalismBorder, shadowColor: _neubrutalismBorder, enableAnimation: true),
                  NeuTextButton(onPressed: () => Navigator.of(context).pop(true), text: const Text("Ya, Tetap Simpan"), buttonColor: _neubrutalismAccent, borderColor: _neubrutalismBorder, shadowColor: _neubrutalismBorder, enableAnimation: true),
                ],
              ),
            ),
          );
          shouldContinue = continueSave ?? false;
        }
      }

      if (!shouldContinue) {
        setState(() => _isLoading = false);
        return;
      }
      
      final itemData = Item(
        id: widget.item?.id ?? '', userId: widget.item?.userId ?? '', name: itemName,
        barcode: _barcodeController.text.isNotEmpty ? _barcodeController.text.trim() : null,
        brand: _brandController.text.isNotEmpty ? _brandController.text.trim() : null,
        description: _descriptionController.text.trim(),
        quantity: int.tryParse(_quantityController.text) ?? 0,
        minQuantity: int.tryParse(_minQuantityController.text) ?? 0,
        unit: _unitController.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceController.text),
        salePrice: double.tryParse(_salePriceController.text),
        categoryId: _selectedCategoryId, imageId: widget.item?.imageId,
      );

      try {
        if (isEditMode) {
          await ref.read(itemServiceProvider).updateItem(itemData, imagePath: _imageFile?.path);
        } else {
          await ref.read(itemServiceProvider).createItem(itemData, imagePath: _imageFile?.path);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Barang berhasil ${isEditMode ? 'diperbarui' : 'ditambahkan'}!'), backgroundColor: Colors.green,));
          ref.invalidate(itemsProvider);
          _showAdAndPop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showAdAndPop() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if(mounted) Navigator.of(context).pop();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          if(mounted) Navigator.of(context).pop();
        }
      );
      _interstitialAd!.show();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.item != null;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: _neubrutalismBg,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Barang' : 'Tambah Barang Baru', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: _neubrutalismBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _neubrutalismAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildTextField(_nameController, 'Nama Barang', 'Nama tidak boleh kosong'),
                    _buildTextField(_barcodeController, 'Barcode (Opsional)', null),
                    _buildTextField(_brandController, 'Merek (Opsional)', null),
                    _buildTextField(_descriptionController, 'Deskripsi (Opsional)', null, maxLines: 3),
                    _buildTextField(_unitController, 'Unit (e.g., Pcs, Box)', 'Unit tidak boleh kosong'),
                    Row(
                      children: [
                        Expanded(child: _buildNumericField(_quantityController, 'Kuantitas (jumlah stok saat ini)')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildNumericField(_minQuantityController, 'Batas Stok Rendah (untuk notifikasi)')),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildNumericField(_purchasePriceController, 'Harga Beli', isOptional: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildNumericField(_salePriceController, 'Harga Jual', isOptional: true)),
                      ],
                    ),
                    categoriesAsync.when(
                      data: (categories) {
                        if (_selectedCategoryId != null && !categories.any((c) => c.id == _selectedCategoryId)) {
                          _selectedCategoryId = null;
                        }
                        return _buildCategoryDropdown(categories);
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, st) => Text('Gagal memuat kategori: $err'),
                    ),
                    const SizedBox(height: 24),
                    NeuTextButton(
                      onPressed: _submitForm,
                      enableAnimation: true,
                      buttonColor: _neubrutalismAccent,
                      borderColor: _neubrutalismBorder,
                      shadowColor: _neubrutalismBorder,
                      text: Text(isEditMode ? 'Simpan Perubahan' : 'Tambah Barang', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: _showImageSourceActionSheet,
            child: NeuContainer(
              height: 150,
              width: 150,
              borderColor: _neubrutalismBorder,
              shadowColor: _neubrutalismBorder,
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : _networkImageUrl != null
                        ? Image.network(_networkImageUrl!, fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tambah Gambar', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
              ),
            ),
          ),
          NeuIconButton(
            onPressed: _showImageSourceActionSheet,
            enableAnimation: true,
            buttonColor: _neubrutalismAccent,
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? validationMsg, {int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: NeuContainer(
        borderColor: _neubrutalismBorder,
        shadowColor: _neubrutalismBorder,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
            ),
            validator: (value) {
              if (validationMsg != null && (value == null || value.isEmpty)) {
                return validationMsg;
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNumericField(TextEditingController controller, String label, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: NeuContainer(
         borderColor: _neubrutalismBorder,
        shadowColor: _neubrutalismBorder,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(hintText: label, border: InputBorder.none),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (!isOptional && (value == null || value.isEmpty)) return 'Wajib diisi';
              if (value != null && value.isNotEmpty && int.tryParse(value) == null) return 'Angka tidak valid';
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: NeuContainer(
        borderColor: _neubrutalismBorder,
        shadowColor: _neubrutalismBorder,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: const InputDecoration(border: InputBorder.none, hintText: 'Pilih Kategori'),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('Tidak Berkategori')),
              ...categories.map((Category category) {
                return DropdownMenuItem<String>(value: category.id, child: Text(category.name));
              }),
            ],
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategoryId = newValue;
              });
            },
          ),
        ),
      ),
    );
  }
}