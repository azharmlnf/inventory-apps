import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';

/// Provider untuk TransactionRepository.
final transactionRepositoryProvider = Provider.autoDispose<TransactionRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  return TransactionRepository(databases);
});

/// Repository untuk mengelola operasi data terkait 'transactions' di Appwrite.
class TransactionRepository {
  final Databases _databases;
  final String _databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  final String _collectionId = dotenv.env['APPWRITE_TRANSACTIONS_COLLECTION_ID']!;

  TransactionRepository(this._databases);

  /// Membuat transaksi baru di database.
  Future<models.Document> createTransaction(Transaction transaction) async {
    try {
      return await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: ID.unique(),
        data: transaction.toJson(),
        permissions: [
          Permission.read(Role.user(transaction.userId)),
          Permission.update(Role.user(transaction.userId)),
          Permission.delete(Role.user(transaction.userId)),
        ],
      );
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal membuat transaksi.';
    }
  }

  /// Mengambil semua transaksi milik pengguna, dengan opsi filter.
  Future<List<Transaction>> getTransactions(
    String userId, {
    String? itemId,
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final List<String> queries = [Query.equal('userId', userId)];

      if (itemId != null) {
        queries.add(Query.equal('itemId', itemId));
      }
      if (type != null) {
        queries.add(Query.equal('type', type == TransactionType.inType ? 'IN' : 'OUT'));
      }
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('date', startDate.toIso8601String()));
      }
      if (endDate != null) {
        queries.add(Query.lessThanEqual('date', endDate.toIso8601String()));
      }

      // Default sort by latest transaction
      queries.add(Query.orderDesc('date'));

      final result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
        queries: queries,
      );
      return result.documents.map((doc) => Transaction.fromDocument(doc)).toList();
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal mengambil data transaksi.';
    }
  }

  /// Memperbarui transaksi yang sudah ada.
  Future<models.Document> updateTransaction(Transaction transaction) async {
    try {
      return await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: transaction.id,
        data: transaction.toJson(),
      );
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal memperbarui transaksi.';
    }
  }

  /// Menghapus transaksi.
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: transactionId,
      );
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal menghapus transaksi.';
    }
  }

  /// Mengambil satu transaksi berdasarkan ID-nya.
  Future<Transaction> getTransactionById(String transactionId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: transactionId,
      );
      return Transaction.fromDocument(doc);
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal mengambil data transaksi.';
    }
  }
}