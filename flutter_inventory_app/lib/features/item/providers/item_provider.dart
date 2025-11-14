import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/domain/services/item_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';

/// AsyncNotifierProvider untuk state management item.
/// Otomatis akan re-fetch data ketika user berubah.
final itemProvider = AsyncNotifierProvider<ItemNotifier, List<Item>>(ItemNotifier.new);

class ItemNotifier extends AsyncNotifier<List<Item>> {
  
  /// Metode `build` akan dipanggil otomatis untuk mengambil data awal.
  /// Ia juga akan dipanggil ulang jika dependensi (seperti auth state) berubah.
  @override
  FutureOr<List<Item>> build() {
    // Provider ini "mendengarkan" perubahan pada authControllerProvider.
    // Jika user berubah (login/logout), `build` akan dijalankan kembali.
    final authState = ref.watch(authControllerProvider);
    if (authState.status != AuthStatus.authenticated) {
      return []; // Kembalikan list kosong jika tidak ada user yang login
    }
    // Ambil data item untuk user yang sedang login.
    return ref.read(itemServiceProvider).getItems();
  }

  /// Menambah item baru.
  Future<void> addItem(Item item) async {
    // Set state ke loading untuk memberikan feedback ke UI.
    state = const AsyncValue.loading();
    // Lakukan operasi dan setelah selesai, panggil `build` lagi untuk refresh data.
    state = await AsyncValue.guard(() async {
      await ref.read(itemServiceProvider).createItem(item);
      return build();
    });
  }

  /// Memperbarui item yang ada.
  Future<void> updateItem(Item item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(itemServiceProvider).updateItem(item);
      return build();
    });
  }

  /// Menghapus item.
  Future<void> deleteItem(String itemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(itemServiceProvider).deleteItem(itemId);
      return build();
    });
  }
}
