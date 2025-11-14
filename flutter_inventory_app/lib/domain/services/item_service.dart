import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';

/// Provider untuk ItemService.
final itemServiceProvider = Provider<ItemService>((ref) {
  final itemRepository = ref.watch(itemRepositoryProvider);
  final account = ref.watch(appwriteAccountProvider);
  return ItemService(itemRepository, account);
});

/// Service Layer untuk mengelola logika bisnis terkait item.
class ItemService {
  final ItemRepository _itemRepository;
  final Account _account;

  ItemService(this._itemRepository, this._account);

  /// Mengambil ID pengguna yang sedang login.
  Future<String> _getCurrentUserId() async {
    try {
      final User user = await _account.get();
      return user.$id;
    } catch (e) {
      throw Exception('Pengguna tidak login atau sesi tidak valid.');
    }
  }

  /// Mengambil semua item milik pengguna yang sedang login.
  Future<List<Item>> getItems() async {
    final userId = await _getCurrentUserId();
    return _itemRepository.getItems(userId);
  }

  /// Membuat item baru untuk pengguna yang sedang login.
  Future<Document> createItem(Item item) async {
    // Pastikan userId pada item sesuai dengan pengguna yang sedang login
    final userId = await _getCurrentUserId();
    final newItem = Item(
      id: '', // ID akan dibuat oleh repository
      userId: userId,
      name: item.name,
      description: item.description,
      quantity: item.quantity,
      minQuantity: item.minQuantity,
      unit: item.unit,
      purchasePrice: item.purchasePrice,
      salePrice: item.salePrice,
      categoryId: item.categoryId,
      imageId: item.imageId,
    );
    return _itemRepository.createItem(newItem);
  }

  /// Memperbarui item yang sudah ada.
  Future<Document> updateItem(Item item) async {
    // Di sini, kita asumsikan repository sudah mengamankan update
    // berdasarkan permission di Appwrite, jadi kita tidak perlu cek userId lagi.
    return _itemRepository.updateItem(item);
  }

  /// Menghapus item.
  Future<void> deleteItem(String itemId) async {
    return _itemRepository.deleteItem(itemId);
  }
}
