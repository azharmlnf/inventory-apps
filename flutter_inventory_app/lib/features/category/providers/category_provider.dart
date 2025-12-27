// # FILE: category_provider.dart
// # LOKASI: flutter_inventory_app/lib/features/category/providers/category_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/repositories/category_repository.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';

// # ASYNC NOTIFIER PROVIDER
// Ini adalah provider utama untuk state management kategori.
// Ia akan mengelola pengambilan data, caching, dan re-fetching secara otomatis.
final categoriesProvider = AsyncNotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);

/// Notifier ini bertanggung jawab untuk:
/// 1. Mengambil daftar kategori awal.
/// 2. Menyediakan metode untuk menambah, mengubah, dan menghapus kategori.
/// 3. Memperbarui state (daftar kategori) secara otomatis setelah operasi CRUD.
class CategoryNotifier extends AsyncNotifier<List<Category>> {

  // # FUNGSI BUILD (INITIAL FETCH)
  // Metode ini akan dipanggil secara otomatis saat provider pertama kali dibaca.
  // Tugasnya adalah mengambil daftar kategori awal.
  @override
  Future<List<Category>> build() async {
    // Wait for a stable session from the new session controller.
    final session = await ref.watch(sessionControllerProvider.future);

    // If there is no user session, return an empty list.
    if (session == null) {
      return [];
    }
    
    // Call the repository with the stable user ID.
    return ref.read(categoryRepositoryProvider).getCategories(session.$id);
  }

  // # FUNGSI CRUD: MENAMBAH KATEGORI
  Future<void> addCategory({required String name}) async {
    // Get the user ID from the stable session.
    final session = await ref.read(sessionControllerProvider.future);
    if (session == null) {
      throw Exception('User not logged in');
    }

    // Set state to loading to provide feedback to the UI
    state = const AsyncValue.loading();

    // Perform the operation and then refetch the data.
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).createCategory(userId: session.$id, name: name);
      // After success, refetch the latest data from the server
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
