import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/data/repositories/transaction_repository.dart';

/// Service Layer untuk mengelola logika bisnis terkait transaksi.
class TransactionService {
  final TransactionRepository _transactionRepository;
  final ItemRepository _itemRepository;
  final Account _account;
  final ActivityLogService _activityLogService;

  TransactionService(
    this._transactionRepository,
    this._itemRepository,
    this._account,
    this._activityLogService,
  );

  /// Mengambil ID pengguna yang sedang login.
  Future<String> _getCurrentUserId() async {
    try {
      final appwrite_models.User user = await _account.get();
      return user.$id;
    } catch (e) {
      throw Exception('Pengguna tidak login atau sesi tidak valid.');
    }
  }

  /// Membuat transaksi baru untuk pengguna yang sedang login.
  Future<appwrite_models.Document> createTransaction(Transaction transaction) async {
    final userId = await _getCurrentUserId();
    final newTransaction = Transaction(
      id: '', // ID akan dibuat oleh repository
      userId: userId,
      itemId: transaction.itemId,
      type: transaction.type,
      quantity: transaction.quantity,
      date: transaction.date,
      note: transaction.note,
    );

    // 1. Create the transaction document
    final doc = await _transactionRepository.createTransaction(newTransaction);

    // 2. Get the item to update its quantity
    final itemToUpdate = await _itemRepository.getItemById(transaction.itemId);
    int newQuantity;
    if (transaction.type == TransactionType.inType) {
      newQuantity = itemToUpdate.quantity + transaction.quantity;
    } else {
      newQuantity = itemToUpdate.quantity - transaction.quantity;
    }

    // 3. Update the item's quantity
    final updatedItem = Item(
      id: itemToUpdate.id,
      userId: itemToUpdate.userId,
      name: itemToUpdate.name,
      brand: itemToUpdate.brand,
      description: itemToUpdate.description,
      quantity: newQuantity, // Updated quantity
      minQuantity: itemToUpdate.minQuantity,
      unit: itemToUpdate.unit,
      purchasePrice: itemToUpdate.purchasePrice,
      salePrice: itemToUpdate.salePrice,
      categoryId: itemToUpdate.categoryId,
      imageId: itemToUpdate.imageId,
    );
    await _itemRepository.updateItem(updatedItem);

    // 4. Record activity
    final action = transaction.type == TransactionType.inType ? 'masuk' : 'keluar';
    await _activityLogService.recordActivity(
      description:
          'Transaksi $action: ${transaction.quantity} ${itemToUpdate.unit} untuk item ${itemToUpdate.name}',
      itemId: transaction.itemId,
    );

    return doc;
  }

  // ... sisa method lainnya tidak berubah ...
  Future<List<Transaction>> getTransactions({
    String? itemId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = await _getCurrentUserId();
    return _transactionRepository.getTransactions(
      userId,
      itemId: itemId,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<appwrite_models.Document> updateTransaction(Transaction transaction) async {
    // 1. Get the original transaction to calculate the difference
    final originalTransaction = await _transactionRepository.getTransactionById(transaction.id);
    
    // 2. Get the item to update its quantity
    final itemToUpdate = await _itemRepository.getItemById(transaction.itemId);

    // 3. Calculate the change in quantity
    // First, revert the old transaction's effect
    int revertedQuantity;
    if (originalTransaction.type == TransactionType.inType) {
      revertedQuantity = itemToUpdate.quantity - originalTransaction.quantity;
    } else {
      revertedQuantity = itemToUpdate.quantity + originalTransaction.quantity;
    }
    
    // Second, apply the new transaction's effect
    int newQuantity;
    if (transaction.type == TransactionType.inType) {
      newQuantity = revertedQuantity + transaction.quantity;
    } else {
      newQuantity = revertedQuantity - transaction.quantity;
    }

    // 4. Update the item with the new calculated quantity
    final updatedItem = itemToUpdate.copyWith(quantity: newQuantity);
    await _itemRepository.updateItem(updatedItem);

    // 5. Now, update the transaction document itself
    final doc = await _transactionRepository.updateTransaction(transaction);
    
    // 6. Record activity
    await _activityLogService.recordActivity(
      description: 'Memperbarui transaksi untuk item: ${itemToUpdate.name}',
      itemId: transaction.itemId,
    );
    return doc;
  }

  Future<void> deleteTransaction(String transactionId) async {
    // 1. Get the transaction to be deleted to know its quantity and type
    final transactionToDelete = await _transactionRepository.getTransactionById(transactionId);
    
    // 2. Get the associated item
    final itemToUpdate = await _itemRepository.getItemById(transactionToDelete.itemId);

    // 3. Revert the stock based on the transaction type
    int newQuantity;
    if (transactionToDelete.type == TransactionType.inType) {
      newQuantity = itemToUpdate.quantity - transactionToDelete.quantity;
    } else {
      newQuantity = itemToUpdate.quantity + transactionToDelete.quantity;
    }

    // 4. Update the item with the reverted quantity
    final updatedItem = itemToUpdate.copyWith(quantity: newQuantity);
    await _itemRepository.updateItem(updatedItem);
    
    // 5. Delete the transaction document
    await _transactionRepository.deleteTransaction(transactionId);
    
    // 6. Record activity
    await _activityLogService.recordActivity(
      description: 'Menghapus transaksi untuk item: ${itemToUpdate.name}',
    );
  }
}
