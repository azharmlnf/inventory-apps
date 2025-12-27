import 'package:appwrite/models.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/domain/services/notification_service.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';

/// Service Layer for managing business logic related to items.
/// This service is now stateless regarding the user.
class ItemService {
  final ItemRepository _itemRepository;
  final ActivityLogService _activityLogService;
  final NotificationService _notificationService;

  ItemService(this._itemRepository, this._activityLogService, this._notificationService);

  /// Fetches all items for a specific user, with optional search, filter, and sort.
  Future<List<Item>> getItems(
    String userId, {
    String? searchQuery,
    String? categoryId,
    ItemSortType? sortType,
  }) async {
    // The userId is now passed directly to the repository.
    return _itemRepository.getItems(
      userId,
      searchQuery: searchQuery,
      categoryId: categoryId,
      sortType: sortType,
    );
  }

  Future<void> _checkAndNotifyLowStock(Item item) async {
    if (item.quantity <= item.minQuantity) {
      await _notificationService.showNotification(
        'Stok Hampir Habis',
        'Stok untuk item ${item.name} hampir habis. Sisa ${item.quantity} ${item.unit}.',
      );
    }
  }

  /// Creates a new item for a specific user.
  Future<Document> createItem(String userId, Item item, {String? imagePath}) async {
    String? imageId;

    // Upload image if provided
    if (imagePath != null) {
      final uploadedFile = await _itemRepository.uploadItemImage(imagePath);
      imageId = uploadedFile.$id;
    }

    final newItem = item.copyWith(userId: userId, imageId: imageId);
    final doc = await _itemRepository.createItem(newItem);

    await _checkAndNotifyLowStock(newItem.copyWith(id: doc.$id));

    // Record activity
    await _activityLogService.recordActivity(
      userId: userId,
      description: 'Membuat item baru: ${item.name}',
      itemId: doc.$id,
    );

    return doc;
  }

  /// Updates an existing item. The user ID from the original item is preserved.
  Future<Document> updateItem(Item item, {String? imagePath}) async {
    String? newImageId;

    // If a new image is uploaded
    if (imagePath != null) {
      final uploadedFile = await _itemRepository.uploadItemImage(imagePath);
      newImageId = uploadedFile.$id;

      // Delete the old image if it exists
      if (item.imageId != null && item.imageId!.isNotEmpty) {
        await _itemRepository.deleteItemImage(item.imageId!);
      }
    }

    // Create the updated item with the new imageId (if any)
    final updatedItem = item.copyWith(imageId: newImageId ?? item.imageId);

    final doc = await _itemRepository.updateItem(updatedItem);
    await _checkAndNotifyLowStock(updatedItem);

    // Record activity
    await _activityLogService.recordActivity(
      userId: item.userId,
      description: 'Memperbarui item: ${item.name}',
      itemId: item.id,
    );

    return doc;
  }

  /// Deletes an item.
  Future<void> deleteItem(String userId, String itemId, String itemName, {String? imageId}) async {
    await _itemRepository.deleteItem(itemId, imageId: imageId);

    // Record activity
    await _activityLogService.recordActivity(
      userId: userId,
      description: 'Menghapus item: $itemName',
      itemId: itemId,
    );
  }

  /// Checks if an item with the same name already exists for a specific user.
  Future<bool> itemExists({required String name, required String userId}) async {
    return _itemRepository.itemExists(name: name, userId: userId);
  }

  /// Gets the image URL from the repository.
  String? getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return null;
    return _itemRepository.getItemImageUrl(imageId);
  }
}