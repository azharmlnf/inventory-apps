import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/domain/services/item_service.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_search_provider.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/main.dart'; // For notificationServiceProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk ItemService.
final itemServiceProvider = Provider<ItemService>((ref) {
  final itemRepository = ref.watch(itemRepositoryProvider);
  final account = ref.watch(appwriteAccountProvider);
  final activityLogService = ref.watch(activityLogServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ItemService(itemRepository, account, activityLogService, notificationService);
});

/// AsyncNotifierProvider untuk mengelola daftar item.
final itemsProvider = AsyncNotifierProvider<ItemsNotifier, List<Item>>(() {
  return ItemsNotifier();
});

class ItemsNotifier extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build() async {
    // Wait for a stable session from the new session controller.
    final session = await ref.watch(sessionControllerProvider.future);

    // If there is no user session, return an empty list.
    if (session == null) {
      return [];
    }

    // Continue with fetching data as before, now that we know a user is logged in.
    final categoryId = ref.watch(itemCategoryFilterProvider);
    final sortType = ref.watch(itemSortProvider);

    final itemService = ref.read(itemServiceProvider);
    
    // The search query is now handled on the client-side.
    return itemService.getItems(
      categoryId: categoryId,
      sortType: sortType,
    );
  }

  /// Menambahkan item baru dan memuat ulang daftar.
  Future<void> addItem(Item item) async {
    // The service layer handles the actual creation.
    // We just call it and then invalidate our own provider to trigger a rebuild.
    await ref.read(itemServiceProvider).createItem(item);
    ref.invalidate(itemsProvider); // Use the provider itself
  }

  /// Memperbarui item dan memuat ulang daftar.
  Future<void> updateItem(Item item) async {
    await ref.read(itemServiceProvider).updateItem(item);
    ref.invalidate(itemsProvider); // Use the provider itself
  }

  /// Menghapus item dan memuat ulang daftar.
  Future<void> deleteItem(Item item) async {
    // Pass the necessary details to the service layer.
    await ref.read(itemServiceProvider).deleteItem(item.id, item.name, imageId: item.imageId);
    ref.invalidate(itemsProvider); // Use the provider itself
  }
}
