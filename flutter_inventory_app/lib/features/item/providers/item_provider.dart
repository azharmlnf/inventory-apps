import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart'; // <-- Needed for itemServiceProvider
import 'package:flutter_inventory_app/features/item/providers/item_search_provider.dart';

/// AsyncNotifierProvider untuk state management item.
/// Otomatis akan re-fetch data ketika user, query pencarian, filter, atau sort berubah.
final itemProvider = AsyncNotifierProvider<ItemNotifier, List<Item>>(ItemNotifier.new);

class ItemNotifier extends AsyncNotifier<List<Item>> {
  
  /// Metode `build` akan dipanggil otomatis untuk mengambil data awal.
  /// Ia juga akan dipanggil ulang jika dependensi (seperti auth state, search, filter, atau sort) berubah.
  @override
  Future<List<Item>> build() async {
    // Wait for a stable session from the new session controller.
    final session = await ref.watch(sessionControllerProvider.future);

    // If there is no user session, return an empty list.
    if (session == null) {
      return [];
    }

    // This provider now "listens" to the other state providers.
    final searchQuery = ref.watch(itemSearchQueryProvider);
    final categoryFilter = ref.watch(itemCategoryFilterProvider);
    final sortType = ref.watch(itemSortProvider);
    
    // Fetch item data with all available parameters.
    return ref.read(itemServiceProvider).getItems(
          session.$id,
          searchQuery: searchQuery,
          categoryId: categoryFilter,
          sortType: sortType,
        );
  }

  /// Menambahkan item baru.
  Future<void> addItem(Item item, {String? imagePath}) async {
    state = const AsyncValue.loading();
    final session = await ref.read(sessionControllerProvider.future);
    if (session == null) throw Exception("User not logged in");

    state = await AsyncValue.guard(() async {
      await ref.read(itemServiceProvider).createItem(session.$id, item, imagePath: imagePath);
      // Invalidate provider to refresh and show the new item.
      ref.invalidateSelf();
      // await the new future
      return await future;
    });
  }

  /// Memperbarui item yang ada.
  Future<void> updateItem(Item item, {String? imagePath}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(itemServiceProvider).updateItem(item, imagePath: imagePath);
      ref.invalidateSelf();
      return future;
    });
  }

  /// Memperbarui kuantitas item.
  Future<void> updateItemQuantity(String itemId, int quantityChange) async {
    state = await AsyncValue.guard(() async {
      final currentItems = state.value ?? [];
      
      // Find the item to update
      final itemToUpdateIndex = currentItems.indexWhere((item) => item.id == itemId);
      if (itemToUpdateIndex == -1) {
        throw Exception('Item dengan ID $itemId tidak ditemukan.');
      }
      final itemToUpdate = currentItems[itemToUpdateIndex];

      final updatedQuantity = itemToUpdate.quantity + quantityChange;

      final updatedItem = itemToUpdate.copyWith(quantity: updatedQuantity);
      
      try {
        await ref.read(itemServiceProvider).updateItem(updatedItem);
        // If update is successful, replace the item in the current state
        final updatedList = List<Item>.from(currentItems);
        updatedList[itemToUpdateIndex] = updatedItem;
        return updatedList; // Return the updated list directly
      } catch (e) {
        throw Exception('Gagal memperbarui kuantitas item: ${e.toString()}');
      }
    });
  }

  /// Menghapus item.
  Future<void> deleteItem(String itemId) async {
    state = const AsyncValue.loading();
    final session = await ref.read(sessionControllerProvider.future);
    if (session == null) throw Exception("User not logged in");
    
    state = await AsyncValue.guard(() async {
      // Get the item name from the current state before deleting.
      final items = state.value ?? [];
      final itemToDelete = items.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw Exception('Item not found for deletion.'),
      );

      await ref.read(itemServiceProvider).deleteItem(
            session.$id,
            itemId,
            itemToDelete.name,
            imageId: itemToDelete.imageId,
          );
      ref.invalidateSelf();
      return await future;
    });
  }
}
