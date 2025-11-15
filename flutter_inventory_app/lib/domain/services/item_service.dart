import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';

/// Service Layer untuk mengelola logika bisnis terkait item.
class ItemService {
  final ItemRepository _itemRepository;
  final Account _account;
  final ActivityLogService _activityLogService;

  ItemService(this._itemRepository, this._account, this._activityLogService);

  /// Mengambil ID pengguna yang sedang login.
  Future<String> _getCurrentUserId() async {
    try {
      final User user = await _account.get();
      return user.$id;
    } catch (e) {
      throw Exception('Pengguna tidak login atau sesi tidak valid.');
    }
  }

  /// Mengambil semua item milik pengguna yang sedang login, dengan opsi pencarian, filter, dan sortir.
  Future<List<Item>> getItems({
    String? searchQuery,
    String? categoryId,
    ItemSortType? sortType,
  }) async {
    final userId = await _getCurrentUserId();
    return _itemRepository.getItems(
      userId,
      searchQuery: searchQuery,
      categoryId: categoryId,
      sortType: sortType,
    );
  }

  /// Membuat item baru untuk pengguna yang sedang login.
  Future<Document> createItem(Item item) async {
    // Pastikan userId pada item sesuai dengan pengguna yang sedang login
    final userId = await _getCurrentUserId();
    final newItem = Item(
      id: '', // ID akan dibuat oleh repository
      userId: userId,
      name: item.name,
      brand: item.brand,
      description: item.description,
      quantity: item.quantity,
      minQuantity: item.minQuantity,
      unit: item.unit,
      purchasePrice: item.purchasePrice,
      salePrice: item.salePrice,
      categoryId: item.categoryId,
      imageId: item.imageId,
    );
    final doc = await _itemRepository.createItem(newItem);

    // Record activity
    await _activityLogService.recordActivity(
      description: 'Membuat item baru: ${item.name}',
      itemId: doc.$id,
    );

    return doc;
  }

  /// Memperbarui item yang sudah ada.
  Future<Document> updateItem(Item item) async {
    final doc = await _itemRepository.updateItem(item);

    // Record activity
    await _activityLogService.recordActivity(
      description: 'Memperbarui item: ${item.name}',
      itemId: item.id,
    );

    return doc;
  }

  /// Menghapus item.
  Future<void> deleteItem(String itemId, String itemName) async {
    await _itemRepository.deleteItem(itemId);

    // Record activity
    await _activityLogService.recordActivity(
      description: 'Menghapus item: $itemName',
      itemId: itemId,
    );
  }

  /// Memeriksa apakah item dengan nama yang sama sudah ada.
  Future<bool> itemExists({required String name}) async {
    final userId = await _getCurrentUserId();
    return _itemRepository.itemExists(name: name, userId: userId);
  }
}