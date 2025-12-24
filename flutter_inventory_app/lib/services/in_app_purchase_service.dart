import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService extends ChangeNotifier {
  InAppPurchaseService._internal(); // Private constructor
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();

  factory InAppPurchaseService() {
    return _instance;
  }

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseStreamSubscription;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  String? _purchasePendingError;
  String? get purchasePendingError => _purchasePendingError;

  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      // Handle cases where in-app purchases are not available (e.g., on web or unsupported devices)
      print('In-app purchases not available on this device/platform.');
      return;
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _purchaseStreamSubscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _purchaseStreamSubscription.cancel();
      },
      onError: (error) {
        // Handle error here
        print('Error in purchase stream: $error');
        _purchasePendingError = 'Terjadi kesalahan saat memproses pembelian.';
        notifyListeners();
      },
    );

    // Fetch products as soon as service is initialized
    await _queryProductDetails();
  }

  void disposeService() {
    _purchaseStreamSubscription.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _handlePending(purchaseDetails);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                     purchaseDetails.status == PurchaseStatus.restored) {
          _handlePurchased(purchaseDetails);
        }
      }
    }
    notifyListeners();
  }

  void _handlePending(PurchaseDetails purchaseDetails) {
    _purchasePendingError = null; // Clear any previous errors
    print('Purchase pending: ${purchaseDetails.productID}');
    // You might want to show a loading indicator or similar UI
    notifyListeners();
  }

  void _handleError(PurchaseDetails purchaseDetails) {
    print('Purchase error: ${purchaseDetails.error?.message}');
    _purchasePendingError = purchaseDetails.error?.message ?? 'Pembelian gagal.';
    notifyListeners();
  }

  Future<void> _handlePurchased(PurchaseDetails purchaseDetails) async {
    _purchasePendingError = null; // Clear any previous errors
    print('Purchase successful: ${purchaseDetails.productID}');

    // Acknowledge the purchase (crucial step!)
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }

    // --- VALIDASI LOKAL (sementara, sesuai permintaan Anda) ---
    // Di sini Anda akan mengaktifkan fitur bebas iklan secara lokal.
    // Untuk produksi, ini adalah tempat di mana Anda akan mengirim
    // purchaseDetails.verificationData.serverVerificationData ke backend (FASE 2)
    // untuk validasi server yang aman dan mengaktifkan fitur dari sana.
    // Untuk sekarang, kita asumsikan valid jika sudah acknowledged.

    // Simpan status langganan secara lokal (misal: menggunakan shared_preferences)
    // atau update UI yang relevan.
    // Contoh:
    // isPremium = true;
    // notifyListeners();
  }

  Future<void> _queryProductDetails() async {
    // Daftar ID produk langganan yang sudah Anda buat di Google Play Console
    // Sesuaikan dengan Product ID langganan induk Anda
    const Set<String> productIds = {'premium_no_ads'}; // Gunakan ID produk langganan Anda

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);

    if (response.error != null) {
      print('Error querying product details: ${response.error?.message}');
      return;
    }

    if (response.productDetails.isNotEmpty) {
      _products = response.productDetails;
      print('Fetched products: ${_products.map((p) => p.id).join(', ')}');
    } else {
      print('No products found for IDs: $productIds');
    }
    notifyListeners();
  }

  // Metode untuk memulai pembelian
  Future<void> buySubscription(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Metode untuk memulihkan pembelian sebelumnya (penting untuk langganan)
  Future<void> restorePurchases() async {
    print('Restoring purchases...');
    await _inAppPurchase.restorePurchases();
  }
}