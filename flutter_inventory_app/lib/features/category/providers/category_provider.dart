// # FILE: category_provider.dart
// # LOKASI: flutter_inventory_app/lib/features/category/providers/category_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/repositories/category_repository.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';

// # ASYNC NOTIFIER PROVIDER
// Ini adalah provider utama untuk state management kategori.
// Ia akan mengelola pengambilan data, caching, dan re-fetching secara otomatis.
final categoryProvider = AsyncNotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);

/// Notifier ini bertanggung jawab untuk:
/// 1. Mengambil daftar kategori awal.
/// 2. Menyediakan metode untuk menambah, mengubah, dan menghapus kategori.
/// 3. Memperbarui state (daftar kategori) secara otomatis setelah operasi CRUD.
class CategoryNotifier extends AsyncNotifier<List<Category>> {

  // # FUNGSI BUILD (INITIAL FETCH)
  // Metode ini akan dipanggil secara otomatis saat provider pertama kali dibaca.
  // Tugasnya adalah mengambil daftar kategori awal.
  @override
  FutureOr<List<Category>> build() {
    // Dapatkan userId dari provider otentikasi
    final userId = ref.watch(authControllerProvider).user?.$id;
    // Jika tidak ada userId (belum login), kembalikan list kosong
    if (userId == null) {
      return [];
    }
    // Panggil repository untuk mengambil data dari Appwrite
    return ref.read(categoryRepositoryProvider).getCategories(userId);
  }

  // # FUNGSI CRUD: MENAMBAH KATEGORI
  Future<void> addCategory({required String name}) async {
    final userId = ref.read(authControllerProvider).user?.$id;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Set state ke loading untuk memberikan feedback ke UI
    state = const AsyncValue.loading();

    // Lakukan operasi secara optimis: perbarui state dengan data baru
    // sambil menunggu hasil dari server.
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).createCategory(userId: userId, name: name);
      // Setelah berhasil, panggil kembali build() untuk mengambil data terbaru dari server
      return build();
    });
  }

  // # FUNGSI CRUD: MEMPERBARUI KATEGORI
  Future<void> updateCategory({required String categoryId, required String name}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).updateCategory(categoryId: categoryId, name: name);
      return build();
    });
  }

  // # FUNGSI CRUD: MENGHAPUS KATEGORI
  Future<void> deleteCategory({required String categoryId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).deleteCategory(categoryId: categoryId);
      return build();
    });
  }
}
