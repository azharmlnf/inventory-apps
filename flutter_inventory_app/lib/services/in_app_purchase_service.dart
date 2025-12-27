import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';


// Service is now a standard class, managed by Riverpod
class InAppPurchaseService extends ChangeNotifier {
  final Ref _ref; // To interact with other providers

  InAppPurchaseService(this._ref); // Constructor accepts a Ref

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
      print('In-app purchases not available on this device/platform.');
      return;
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _purchaseStreamSubscription = purchaseUpdated.listen(
      (purchaseDetailsList) => _listenToPurchaseUpdated(purchaseDetailsList),
      onDone: () => _purchaseStreamSubscription.cancel(),
      onError: (error) {
        print('Error in purchase stream: $error');
        _purchasePendingError = 'Terjadi kesalahan saat memproses pembelian.';
        notifyListeners();
      },
    );

    await queryProductDetails();
  }

  @override
  void dispose() {
    _purchaseStreamSubscription.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _handlePending();
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _handlePurchased(purchaseDetails);
      }
    }
    notifyListeners();
  }

  void _handlePending() {
    _purchasePendingError = null;
    print('Purchase pending...');
    notifyListeners();
  }

  void _handleError(PurchaseDetails purchaseDetails) {
    print('Purchase error: ${purchaseDetails.error?.message}');
    _purchasePendingError =
        purchaseDetails.error?.message ?? 'Pembelian gagal.';
    notifyListeners();
  }

  Future<void> _handlePurchased(PurchaseDetails purchaseDetails) async {
    _purchasePendingError = null;
    print('Purchase successful or restored: ${purchaseDetails.productID}');

    // Acknowledge the purchase (crucial step!)
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }

    // Update the user's premium status via AuthController
    try {
      await _ref.read(sessionControllerProvider.notifier).updatePremiumStatus(
        true,
        productId: purchaseDetails.productID,
      );
      print('User premium status and product ID updated successfully via provider.');
    } catch (e) {
      print('Error updating premium status via provider: $e');
    }

    notifyListeners();
  }

  Future<void> queryProductDetails() async {
    // FIX: Use the correct subscription product IDs
    const Set<String> productIds = {'premium_no_ads'};

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);

    if (response.error != null) {
      print('Error querying product details: ${response.error?.message}');
      _products = [];
      notifyListeners();
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      print(
          'Warning: The following product IDs were not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    print('Fetched products: ${_products.map((p) => p.id).join(', ')}');

    if (_products.isEmpty) {
      print(
          'No products found. Make sure IDs are correct and set up in Play Console.');
    }
    notifyListeners();
  }

  Future<void> buySubscription(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    print('Restoring purchases...');
    await _inAppPurchase.restorePurchases();
  }
}