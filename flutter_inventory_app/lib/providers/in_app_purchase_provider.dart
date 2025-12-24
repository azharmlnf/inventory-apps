import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/services/in_app_purchase_service.dart';

final inAppPurchaseProvider =
    ChangeNotifierProvider<InAppPurchaseService>((ref) {
  return InAppPurchaseService(ref);
});
