import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const TransactionFormPage({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _noteController;
  String? _selectedItemId;
  TransactionType? _selectedType;
  DateTime _selectedTransactionDate = DateTime.now();
  bool _isLoading = false;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _quantityController = TextEditingController(text: transaction?.quantity.toString() ?? '1');
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _selectedItemId = transaction?.itemId;
    _selectedType = transaction?.type ?? TransactionType.inType;
    _selectedTransactionDate = transaction?.date ?? DateTime.now();
    // _loadBannerAd() is now called in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAdLoaded) {
      _loadBannerAd();
    }
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    if (ref.read(authControllerProvider).isPremium) {
      return;
    }

    _bannerAd = ref.read(adServiceProvider).createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (error) {
        _bannerAd?.dispose();
        if (mounted) {
          setState(() {
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
          onAdDismissed(); // Panggil callback setelah iklan ditutup
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onAdDismissed(); // Langsung panggil callback jika iklan gagal tampil
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onAdDismissed(); // Jika tidak ada iklan, langsung panggil callback
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTransactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedTransactionDate) {
      setState(() {
        _selectedTransactionDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedItemId == null || _selectedItemId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon pilih barang.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final isEditMode = widget.transaction != null;


      final newTransaction = Transaction(
        id: widget.transaction?.id ?? '',
        userId: widget.transaction?.userId ?? '', // userId will be set by the service
        itemId: _selectedItemId!, // Ditambahkan '!' karena sudah divalidasi tidak null
        type: _selectedType!,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        date: _selectedTransactionDate,
        note: _noteController.text.isNotEmpty ? _noteController.text.trim() : null,
      );

      try {
        if (isEditMode) {
          await ref.read(transactionsProvider.notifier).updateTransaction(newTransaction);
        } else {
          await ref.read(transactionsProvider.notifier).addTransaction(newTransaction);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaksi berhasil ${isEditMode ? 'diperbarui' : 'ditambahkan'}!'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(transactionsProvider); // Invalidate transactionsProvider to refresh the list
          ref.invalidate(itemsProvider); // Invalidate itemsProvider as item quantities might have changed
          
          _showInterstitialAd(() {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
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
    final isEditMode = widget.transaction != null;
    final itemsAsync = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi Baru'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          itemsAsync.when(
                            data: (items) {
                              // Ensure _selectedItemId is valid
                              if (_selectedItemId != null && !items.any((item) => item.id == _selectedItemId)) {
                                _selectedItemId = null;
                              }
                              return _buildItemDropdown(items);
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, st) => Text('Gagal memuat barang: $err'),
                          ),
                          const SizedBox(height: 16),
                          _buildTransactionTypeDropdown(),
                          const SizedBox(height: 16),
                          _buildNumericField(_quantityController, 'Kuantitas', 'Kuantitas tidak boleh kosong'),
                          const SizedBox(height: 16),
                          _buildDateField(context),
                          const SizedBox(height: 16),
                          _buildTextField(_noteController, 'Catatan (Opsional)', null, maxLines: 3),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(isEditMode ? 'Simpan Perubahan' : 'Tambah Transaksi'),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildNumericField(TextEditingController controller, String label, String validationMsg) {
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
          if (value == null || value.isEmpty) {
            return validationMsg;
          }
          if (int.tryParse(value) == null || int.parse(value) <= 0) {
            return 'Masukkan angka positif valid';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildItemDropdown(List<Item> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedItemId,
        decoration: const InputDecoration(
          labelText: 'Barang',
        ),
        hint: const Text('Pilih Barang'),
        items: items.map((Item item) {
          return DropdownMenuItem<String>(
            value: item.id,
            child: Text(item.name),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedItemId = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Mohon pilih barang';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTransactionTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<TransactionType>(
        value: _selectedType,
        decoration: const InputDecoration(
          labelText: 'Tipe Transaksi',
        ),
        hint: const Text('Pilih Tipe'),
        items: TransactionType.values.map((TransactionType type) {
          return DropdownMenuItem<TransactionType>(
            value: type,
            child: Text(type == TransactionType.inType ? 'Barang Masuk' : 'Barang Keluar'),
          );
        }).toList(),
        onChanged: (TransactionType? newValue) {
          setState(() {
            _selectedType = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Mohon pilih tipe transaksi';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Tanggal Transaksi',
          ),
          baseStyle: Theme.of(context).textTheme.bodyLarge,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${_selectedTransactionDate.toLocal().day}/${_selectedTransactionDate.toLocal().month}/${_selectedTransactionDate.toLocal().year}',
              ),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }
}