import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/category/providers/category_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';

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

    if (item?.imageId != null && item!.imageId!.isNotEmpty) {
      _networkImageUrl = ref.read(itemServiceProvider).getImageUrl(item.imageId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    if (kIsWeb || ref.read(authControllerProvider).isPremium) {
      return;
    }
    ref.read(adServiceProvider).createInterstitialAd(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
      },
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
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      bool success = false;

      final isEditMode = widget.item != null;
      final itemName = _nameController.text.trim();

      if (!isEditMode || (isEditMode && itemName != widget.item!.name)) {
        final exists = await ref.read(itemServiceProvider).itemExists(name: itemName);
        if (mounted && exists) {
          final continueSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Barang Sudah Ada', style: Theme.of(context).textTheme.titleLarge),
              content: Text('Barang dengan nama "$itemName" sudah ada. Anda yakin ingin tetap menyimpannya?', style: Theme.of(context).textTheme.bodyMedium),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Batal')),
                ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ya, Tetap Simpan')),
              ],
            ),
          );
          if (continueSave == null || !continueSave) {
            setState(() => _isLoading = false);
            return;
          }
        }
      }

      final itemData = Item(
        id: widget.item?.id ?? '',
        userId: widget.item?.userId ?? '',
        name: itemName,
        barcode: _barcodeController.text.isNotEmpty ? _barcodeController.text.trim() : null,
        brand: _brandController.text.isNotEmpty ? _brandController.text.trim() : null,
        description: _descriptionController.text.trim(),
        quantity: int.tryParse(_quantityController.text) ?? 0,
        minQuantity: int.tryParse(_minQuantityController.text) ?? 0,
        unit: _unitController.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceController.text),
        salePrice: double.tryParse(_salePriceController.text),
        categoryId: _selectedCategoryId,
        imageId: widget.item?.imageId,
      );

      try {
        if (isEditMode) {
          await ref.read(itemProvider.notifier).updateItem(itemData, imagePath: _imageFile?.path);
        } else {
          await ref.read(itemProvider.notifier).addItem(itemData, imagePath: _imageFile?.path);
        }
        success = true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barang berhasil ${isEditMode ? 'diperbarui' : 'ditambahkan'}!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(itemProvider);

        if (_interstitialAd != null) {
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              Navigator.of(context).pop();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              Navigator.of(context).pop();
            }
          );
          _interstitialAd!.show();
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.item != null;
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Barang' : 'Tambah Barang Baru'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 16),
                    _buildTextField(_nameController, 'Nama Barang', 'Nama tidak boleh kosong'),
                    _buildTextField(_barcodeController, 'Barcode (Opsional)', null),
                    _buildTextField(_brandController, 'Merek (Opsional)', null),
                    _buildTextField(_descriptionController, 'Deskripsi (Opsional)', null, maxLines: 3),
                    _buildTextField(_unitController, 'Unit (e.g., Pcs, Box)', 'Unit tidak boleh kosong'),
                    Row(
                      children: [
                        Expanded(child: _buildNumericField(_quantityController, 'Kuantitas')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildNumericField(_minQuantityController, 'Batas Stok Rendah')),
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
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(isEditMode ? 'Simpan Perubahan' : 'Tambah Barang'),
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
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : _networkImageUrl != null
                        ? Image.network(_networkImageUrl!, fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              return progress == null ? child : const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Gagal memuat gambar:\n${error.toString()}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
                                ),
                              );
                            },
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
          Material(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _showImageSourceActionSheet,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? validationMsg, {int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
        ),
        validator: (value) {
          if (validationMsg != null && (value == null || value.isEmpty)) {
            return validationMsg;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumericField(TextEditingController controller, String label, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Wajib diisi';
          }
          if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
            return 'Masukkan angka valid';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategoryId,
        decoration: const InputDecoration(
          labelText: 'Kategori',
        ),
        hint: const Text('Pilih Kategori'),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Tidak Berkategori'),
          ),
          ...categories.map((Category category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            );
          }),
        ],
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategoryId = newValue;
          });
        },
      ),
    );
  }
}