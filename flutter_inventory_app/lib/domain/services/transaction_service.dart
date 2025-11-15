import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/data/repositories/transaction_repository.dart';

/// Provider untuk TransactionService.
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final account = ref.watch(appwriteAccountProvider);
  return TransactionService(transactionRepository, account);
});

/// Service Layer untuk mengelola logika bisnis terkait transaksi.
class TransactionService {
  final TransactionRepository _transactionRepository;
  final Account _account;

  TransactionService(this._transactionRepository, this._account);

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
    return _transactionRepository.createTransaction(newTransaction);
  }

  /// Mengambil semua transaksi milik pengguna yang sedang login, dengan opsi filter.
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

  /// Memperbarui transaksi yang sudah ada.
  Future<appwrite_models.Document> updateTransaction(Transaction transaction) async {
    // Di sini, kita asumsikan repository sudah mengamankan update
    // berdasarkan permission di Appwrite, jadi kita tidak perlu cek userId lagi.
    return _transactionRepository.updateTransaction(transaction);
  }

  /// Menghapus transaksi.
  Future<void> deleteTransaction(String transactionId) async {
    return _transactionRepository.deleteTransaction(transactionId);
  }
}