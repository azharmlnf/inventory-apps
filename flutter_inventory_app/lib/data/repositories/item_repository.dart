import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/app_constants.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/item.dart';

/// Provider untuk ItemRepository.
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  return ItemRepository(databases);
});

/// Repository untuk mengelola operasi data terkait 'items' di Appwrite.
class ItemRepository {
  final Databases _databases;

  ItemRepository(this._databases);

  /// Membuat item baru di database.
  Future<models.Document> createItem(Item item) async {
    try {
      return await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.itemsCollectionId,
        documentId: ID.unique(),
        data: item.toJson(),
        permissions: [
          Permission.read(Role.user(item.userId)),
          Permission.update(Role.user(item.userId)),
          Permission.delete(Role.user(item.userId)),
        ],
      );
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal membuat item.';
    }
  }

  /// Mengambil semua item milik pengguna.
  Future<List<Item>> getItems(String userId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.itemsCollectionId,
        queries: [
          Query.equal('userId', userId),
        ],
      );
      return result.documents.map((doc) => Item.fromDocument(doc)).toList();
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal mengambil data item.';
    }
  }

  /// Memperbarui item yang sudah ada.
  Future<models.Document> updateItem(Item item) async {
    try {
      return await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.itemsCollectionId,
        documentId: item.id,
        data: item.toJson(),
      );
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal memperbarui item.';
    }
  }

  /// Menghapus item.
  Future<void> deleteItem(String itemId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.itemsCollectionId,
        documentId: itemId,
      );
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal menghapus item.';
    }
  }
}
