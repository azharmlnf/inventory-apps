import 'package:flutter_inventory_app/domain/services/item_service.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk ItemService.
final itemServiceProvider = Provider<ItemService>((ref) {
  final itemRepository = ref.watch(itemRepositoryProvider);
  final account = ref.watch(appwriteAccountProvider);
  final activityLogService = ref.watch(activityLogServiceProvider);
  return ItemService(itemRepository, account, activityLogService);
});

/// AsyncNotifierProvider untuk mengelola daftar item.
/// Ini akan secara otomatis memuat item saat pertama kali diakses
/// dan menyediakan cara untuk me-refresh daftar.
final itemsProvider = AsyncNotifierProvider<ItemsNotifier, List<Item>>(() {
  return ItemsNotifier();
});

class ItemsNotifier extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build() async {
    // Load initial items from the service
    return _fetchItems();
  }

  Future<List<Item>> _fetchItems() async {
    final itemService = ref.read(itemServiceProvider);
    return itemService.getItems();
  }

  /// Memuat ulang daftar item.
  Future<void> refreshItems() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItems());
  }

  /// Menambahkan item baru dan memuat ulang daftar.
  Future<void> addItem(Item item) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => ref.read(itemServiceProvider).createItem(item));
    state = await AsyncValue.guard(() => _fetchItems());
  }

  /// Memperbarui item dan memuat ulang daftar.
  Future<void> updateItem(Item item) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => ref.read(itemServiceProvider).updateItem(item));
    state = await AsyncValue.guard(() => _fetchItems());
  }

  /// Menghapus item dan memuat ulang daftar.
  Future<void> deleteItem(String itemId, String itemName) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => ref.read(itemServiceProvider).deleteItem(itemId, itemName));
    state = await AsyncValue.guard(() => _fetchItems());
  }
}