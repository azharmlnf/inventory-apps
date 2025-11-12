import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/domain/services/category_service.dart';
import 'package:flutter_riverpod/legacy.dart';

/// StateNotifierProvider untuk mengelola daftar kategori.
/// Ini akan menyediakan daftar kategori yang dapat diakses oleh UI,
/// serta metode untuk memuat, menambah, memperbarui, dan menghapus kategori.
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  final categoryService = ref.watch(categoryServiceProvider);
  return CategoriesNotifier(categoryService);
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryService _categoryService;

  CategoriesNotifier(this._categoryService) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  /// Memuat semua kategori dari layanan.
  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _categoryService.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Menambahkan kategori baru.
  Future<void> addCategory(String name) async {
    try {
      state = const AsyncValue.loading(); // Opsional: tampilkan loading saat menambah
      await _categoryService.createCategory(name);
      await loadCategories(); // Muat ulang kategori setelah penambahan
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Memperbarui kategori yang sudah ada.
  Future<void> updateCategory(Category category, String newName) async {
    try {
      state = const AsyncValue.loading(); // Opsional: tampilkan loading saat memperbarui
      await _categoryService.updateCategory(category.id, newName);
      await loadCategories(); // Muat ulang kategori setelah pembaruan
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Menghapus kategori.
  Future<void> deleteCategory(String categoryId) async {
    try {
      state = const AsyncValue.loading(); // Opsional: tampilkan loading saat menghapus
      await _categoryService.deleteCategory(categoryId);
      await loadCategories(); // Muat ulang kategori setelah penghapusan
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
