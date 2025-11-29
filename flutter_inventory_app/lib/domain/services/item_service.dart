import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/domain/services/notification_service.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';

/// Service Layer untuk mengelola logika bisnis terkait item.
class ItemService {
  final ItemRepository _itemRepository;
  final Account _account;
  final ActivityLogService _activityLogService;
  final NotificationService _notificationService;

  ItemService(this._itemRepository, this._account, this._activityLogService,
      this._notificationService);

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

  Future<void> _checkAndNotifyLowStock(Item item) async {
    if (item.quantity <= item.minQuantity) {
      await _notificationService.showNotification(
        'Stok Hampir Habis',
        'Stok untuk item ${item.name} hampir habis. Sisa ${item.quantity} ${item.unit}.',
      );
    }
  }

  /// Membuat item baru untuk pengguna yang sedang login.
  Future<Document> createItem(Item item, {String? imagePath}) async {
    final userId = await _getCurrentUserId();
    String? imageId;

    // Cek duplikasi nama item
    if (await itemExists(name: item.name)) {
      // Di service, kita bisa melempar exception atau handle sesuai kebutuhan
      // UI akan menangani konfirmasi dari user.
    }

    // Upload gambar jika ada
    if (imagePath != null) {
      final uploadedFile = await _itemRepository.uploadItemImage(imagePath);
      imageId = uploadedFile.$id;
    }

    final newItem = item.copyWith(userId: userId, imageId: imageId);
    final doc = await _itemRepository.createItem(newItem);

    await _checkAndNotifyLowStock(newItem.copyWith(id: doc.$id));

    // Record activity
    await _activityLogService.recordActivity(
      description: 'Membuat item baru: ${item.name}',
      itemId: doc.$id,
    );

    return doc;
  }

  /// Memperbarui item yang sudah ada.
  Future<Document> updateItem(Item item, {String? imagePath}) async {
    String? newImageId;

    // Jika ada gambar baru yang di-upload
    if (imagePath != null) {
      final uploadedFile = await _itemRepository.uploadItemImage(imagePath);
      newImageId = uploadedFile.$id;

      // Hapus gambar lama jika ada
      if (item.imageId != null && item.imageId!.isNotEmpty) {
        await _itemRepository.deleteItemImage(item.imageId!);
      }
    }

    // Buat item yang diperbarui dengan imageId baru (jika ada)
    final updatedItem = item.copyWith(imageId: newImageId ?? item.imageId);

    final doc = await _itemRepository.updateItem(updatedItem);
    await _checkAndNotifyLowStock(updatedItem);

    // Record activity
    await _activityLogService.recordActivity(
      description: 'Memperbarui item: ${item.name}',
      itemId: item.id,
    );

    return doc;
  }

  /// Menghapus item.
  Future<void> deleteItem(String itemId, String itemName, {String? imageId}) async {
    await _itemRepository.deleteItem(itemId, imageId: imageId);

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

  /// Mendapatkan URL gambar dari repository.
  String? getImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) return null;
    return _itemRepository.getItemImageUrl(imageId);
  }
}