import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/repositories/category_repository.dart';

/// Service Layer untuk mengelola operasi bisnis terkait kategori.
/// Bertanggung jawab untuk berinteraksi dengan CategoryRepository
/// dan menyediakan logika bisnis tambahan jika diperlukan.
class CategoryService {
  final CategoryRepository _categoryRepository;
  final Account _account;

  CategoryService(this._categoryRepository, this._account);

  /// Mendapatkan ID pengguna yang sedang login.
  /// Melemparkan exception jika tidak ada pengguna yang login.
    Future<String> _getCurrentUserId() async {
      try {
        final User user = await _account.get();
        return user.$id;
      } catch (e) {
        throw Exception('Pengguna tidak login atau sesi tidak valid.');
      }
    }

  /// Membuat kategori baru untuk pengguna yang sedang login.
  Future<Category> createCategory(String name) async {
    final userId = await _getCurrentUserId();
    return _categoryRepository.createCategory(userId: userId, name: name);
  }

  /// Mengambil semua kategori milik pengguna yang sedang login.
  Future<List<Category>> getCategories() async {
    final userId = await _getCurrentUserId();
    return _categoryRepository.getCategories(userId);
  }

  /// Memperbarui kategori yang sudah ada.
  Future<Category> updateCategory(String categoryId, String name) async {
    // Tidak perlu userId di sini karena permissions sudah diatur di Appwrite
    // dan repository akan menangani update berdasarkan categoryId.
    return _categoryRepository.updateCategory(categoryId: categoryId, name: name);
  }

  /// Menghapus kategori yang sudah ada.
  Future<void> deleteCategory(String categoryId) async {
    // Tidak perlu userId di sini karena permissions sudah diatur di Appwrite
    // dan repository akan menangani delete berdasarkan categoryId.
    return _categoryRepository.deleteCategory(categoryId: categoryId);
  }
}
