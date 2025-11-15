import 'dart:async';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/domain/services/item_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_search_provider.dart';

/// AsyncNotifierProvider untuk state management item.
/// Otomatis akan re-fetch data ketika user, query pencarian, filter, atau sort berubah.
final itemProvider = AsyncNotifierProvider<ItemNotifier, List<Item>>(ItemNotifier.new);

class ItemNotifier extends AsyncNotifier<List<Item>> {
  
  /// Metode `build` akan dipanggil otomatis untuk mengambil data awal.
  /// Ia juga akan dipanggil ulang jika dependensi (seperti auth state, search, filter, atau sort) berubah.
  @override
  FutureOr<List<Item>> build() {
    // Provider ini "mendengarkan" semua provider state yang relevan.
    final authState = ref.watch(authControllerProvider);
    final searchQuery = ref.watch(itemSearchQueryProvider);
    final categoryFilter = ref.watch(itemCategoryFilterProvider);
    final sortType = ref.watch(itemSortProvider);

    if (authState.status != AuthStatus.authenticated) {
      return []; // Kembalikan list kosong jika tidak ada user yang login
    }
    
    // Ambil data item dengan semua parameter yang ada.
    return ref.read(itemServiceProvider).getItems(
          searchQuery: searchQuery,
          categoryId: categoryFilter,
          sortType: sortType,
        );
  }

  /// Menambahkan item baru.
  Future<void> addItem(Item item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(itemServiceProvider).createItem(item);
      // Invalidate provider agar data di-refresh dan menampilkan item baru.
      ref.invalidateSelf();
      // Tunggu data baru selesai di-load sebelum mengembalikan list.
      return future;
    });
  }

  /// Memperbarui item yang ada.
  Future<void> updateItem(Item item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(itemServiceProvider).updateItem(item);
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
        // Log the error for debugging
        print('Error updating item quantity in Appwrite: $e');
        throw Exception('Gagal memperbarui kuantitas item: ${e.toString()}');
      }
    });
  }

  /// Menghapus item.
  Future<void> deleteItem(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(itemServiceProvider).deleteItem(itemId);
      ref.invalidateSelf();
      return future;
    });
  }
}
