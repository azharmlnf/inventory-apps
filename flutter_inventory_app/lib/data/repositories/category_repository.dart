// # FILE: category_repository.dart
// # LOKASI: flutter_inventory_app/lib/data/repositories/category_repository.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/category.dart';



// # PROVIDER UNTUK REPOSITORY
// Provider ini memungkinkan UI atau Service Layer untuk mengakses CategoryRepository.
final categoryRepositoryProvider = Provider.autoDispose<CategoryRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  return CategoryRepository(databases);
});

/// Repository ini bertanggung jawab untuk semua operasi data
/// yang terkait dengan koleksi 'categories' di Appwrite.
class CategoryRepository {
  final Databases _databases;
  final String _databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  final String _collectionId = dotenv.env['APPWRITE_CATEGORIES_COLLECTION_ID']!;

  CategoryRepository(this._databases);

  // # FUNGSI: MEMBUAT KATEGORI BARU
  Future<Category> createCategory({
    required String userId,
    required String name,
  }) async {
    try {
      final models.Document document = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'name': name,
        },
        // # PENTING: Menetapkan izin akses hanya untuk pengguna yang membuat
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );
      return Category.fromDocument(document);
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal membuat kategori.';
    } catch (e) {
      throw 'Terjadi kesalahan tak terduga saat membuat kategori.';
    }
  }

  // # FUNGSI: MENGAMBIL SEMUA KATEGORI MILIK PENGGUNA
  Future<List<Category>> getCategories(String userId) async {
    try {
      final models.DocumentList result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
        // # PENTING: Query untuk memfilter data di sisi server
        // Meskipun izin sudah menjamin keamanan, query ini meningkatkan performa.
        queries: [
          Query.equal('userId', userId),
        ],
      );
      return result.documents.map((doc) => Category.fromDocument(doc)).toList();
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal mengambil kategori.';
    } catch (e) {
      throw 'Terjadi kesalahan tak terduga saat mengambil kategori.';
    }
  }

  // # FUNGSI: MEMPERBARUI KATEGORI
  Future<Category> updateCategory({
    required String categoryId,
    required String name,
  }) async {
    try {
      final models.Document document = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: categoryId,
        data: {
          'name': name,
        },
      );
      return Category.fromDocument(document);
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal memperbarui kategori.';
    } catch (e) {
      throw 'Terjadi kesalahan tak terduga saat memperbarui kategori.';
    }
  }

  // # FUNGSI: MENGHAPUS KATEGORI
  Future<void> deleteCategory({
    required String categoryId,
  }) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: categoryId,
      );
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal menghapus kategori.';
    } catch (e) {
      throw 'Terjadi kesalahan tak terduga saat menghapus kategori.';
    }
  }
}
