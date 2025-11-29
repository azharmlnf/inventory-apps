import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/app_constants.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';

/// Provider untuk ItemRepository.
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  final storage = ref.watch(appwriteStorageProvider);
  return ItemRepository(databases, storage);
});

/// Repository untuk mengelola operasi data terkait 'items' di Appwrite.
class ItemRepository {
  final Databases _databases;
  final Storage _storage;

  ItemRepository(this._databases, this._storage);

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

  /// Mengambil semua item milik pengguna, dengan opsi pencarian, filter, dan sortir.
  Future<List<Item>> getItems(
    String userId, {
    String? searchQuery,
    String? categoryId,
    ItemSortType? sortType,
  }) async {
    try {
      final List<String> queries = [Query.equal('userId', userId)];

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queries.add(Query.search('name', searchQuery));
      }

      if (categoryId != null) {
        queries.add(Query.equal('categoryId', categoryId));
      }

      // Add sorting logic
      sortType ??= ItemSortType.byNameAsc; // Default sort
      switch (sortType) {
        case ItemSortType.byNameAsc:
          queries.add(Query.orderAsc('name'));
          break;
        case ItemSortType.byNameDesc:
          queries.add(Query.orderDesc('name'));
          break;
        case ItemSortType.byQuantityAsc:
          queries.add(Query.orderAsc('quantity'));
          break;
        case ItemSortType.byQuantityDesc:
          queries.add(Query.orderDesc('quantity'));
          break;
      }

      final result = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.itemsCollectionId,
        queries: queries,
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
  Future<void> deleteItem(String itemId, {String? imageId}) async {
    try {
      // Hapus gambar dari storage terlebih dahulu jika ada
      if (imageId != null && imageId.isNotEmpty) {
        await deleteItemImage(imageId);
      }
      await _databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.itemsCollectionId,
        documentId: itemId,
      );
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal menghapus item.';
    }
  }

  // - - - - - Image Storage Methods - - - - -

  /// Upload gambar item ke Appwrite Storage.
  Future<models.File> uploadItemImage(String filePath) async {
    try {
      final file = await _storage.createFile(
        bucketId: AppConstants.itemImagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath),
        permissions: [Permission.read(Role.any())], // Public read access
      );
      return file;
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal mengupload gambar.';
    }
  }

  /// Mendapatkan URL publik untuk preview gambar.
  String getItemImageUrl(String fileId) {
    // URL-Structure: {endpoint}/storage/buckets/{bucketId}/files/{fileId}/preview?project={projectId}
    const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
    const String projectId = '691431ef001f61d2ee98';
    const String bucketId = AppConstants.itemImagesBucketId;
    
    return '$endpoint/storage/buckets/$bucketId/files/$fileId/preview?project=$projectId';
  }

  /// Menghapus gambar dari Appwrite Storage.
  Future<void> deleteItemImage(String fileId) async {
    try {
      await _storage.deleteFile(
        bucketId: AppConstants.itemImagesBucketId,
        fileId: fileId,
      );
    } on AppwriteException catch (e) {
      // Jangan lemparkan error jika file tidak ada, karena mungkin sudah terhapus
      if (e.code != 404) {
        throw e.message ?? 'Gagal menghapus gambar lama.';
      }
    }
  }

  /// Memeriksa apakah item dengan nama yang sama sudah ada untuk user tertentu.
  Future<bool> itemExists({required String name, required String userId}) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.itemsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('name', name),
          Query.limit(1),
        ],
      );
      return result.total > 0;
    } on AppwriteException {
      // Jika ada error (misal: network), anggap saja tidak ada untuk sementara
      // agar tidak memblokir user. Bisa disempurnakan nanti.
      return false;
    }
  }

  /// Mengambil satu item berdasarkan ID-nya.
  Future<Item> getItemById(String itemId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.itemsCollectionId,
        documentId: itemId,
      );
      return Item.fromDocument(doc);
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal mengambil data item.';
    }
  }
}
