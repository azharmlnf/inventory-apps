import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/category/providers/category_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_provider.dart';
import 'package:flutter_inventory_app/domain/services/item_service.dart';

class ItemFormPage extends ConsumerStatefulWidget {
  final Item? item;

  const ItemFormPage({super.key, this.item});

  @override
  ConsumerState<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends ConsumerState<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _minQuantityController;
  late TextEditingController _unitController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _brandController = TextEditingController(text: item?.brand ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _quantityController = TextEditingController(text: item?.quantity.toString() ?? '0');
    _minQuantityController = TextEditingController(text: item?.minQuantity.toString() ?? '10');
    _unitController = TextEditingController(text: item?.unit ?? 'Pcs');
    _purchasePriceController = TextEditingController(text: item?.purchasePrice?.toStringAsFixed(0) ?? '');
    _salePriceController = TextEditingController(text: item?.salePrice?.toStringAsFixed(0) ?? '');
    _selectedCategoryId = item?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _unitController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final isEditMode = widget.item != null;
      final itemName = _nameController.text.trim();

      // Cek duplikasi hanya jika ini adalah item baru
      if (!isEditMode) {
        final exists = await ref.read(itemServiceProvider).itemExists(name: itemName);
        if (mounted && exists) {
          final continueSave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Barang Sudah Ada', style: Theme.of(context).textTheme.titleLarge),
              content: Text('Barang dengan nama "$itemName" sudah ada. Anda yakin ingin tetap menyimpannya?', style: Theme.of(context).textTheme.bodyMedium),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Ya, Tetap Simpan'),
                ),
              ],
            ),
          );
          // Jika user menekan batal, hentikan proses
          if (continueSave == null || !continueSave) {
            setState(() => _isLoading = false);
            return;
          }
        }
      }

      final newItem = Item(
        id: widget.item?.id ?? '',
        userId: widget.item?.userId ?? '', // userId will be set by the service
        name: itemName,
        brand: _brandController.text.isNotEmpty ? _brandController.text.trim() : null,
        description: _descriptionController.text.trim(),
        quantity: int.tryParse(_quantityController.text) ?? 0,
        minQuantity: int.tryParse(_minQuantityController.text) ?? 0,
        unit: _unitController.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceController.text),
        salePrice: double.tryParse(_salePriceController.text),
        categoryId: _selectedCategoryId,
      );

      try {
        if (isEditMode) {
          await ref.read(itemProvider.notifier).updateItem(newItem);
        } else {
          await ref.read(itemProvider.notifier).addItem(newItem);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Barang berhasil ${isEditMode ? 'diperbarui' : 'ditambahkan'}!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
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
                    _buildTextField(_nameController, 'Nama Barang', 'Nama tidak boleh kosong'),
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
                        // Ensure _selectedCategoryId is valid
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
          }).toList(),
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
