import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/data/repositories/transaction_repository.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/domain/services/transaction_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';


final dateRangeProvider = StateProvider<({DateTime? start, DateTime? end})>((ref) {
  return (start: null, end: null);
});

enum TransactionSortType {
  dateAsc('Tanggal (Terlama > Terbaru)'),
  dateDesc('Tanggal (Terbaru > Terlama)'),
  quantityAsc('Jumlah (Kecil > Besar)'),
  quantityDesc('Jumlah (Besar > Kecil)');

  const TransactionSortType(this.label);
  final String label;
}

final transactionSortProvider = StateProvider<TransactionSortType>((ref) {
  return TransactionSortType.dateDesc; // Default sort
});

/// Provider for the stateless TransactionService.
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final itemRepository = ref.watch(itemRepositoryProvider);
  final activityLogService = ref.watch(activityLogServiceProvider);
  // No longer depends on Account.
  return TransactionService(transactionRepository, itemRepository, activityLogService);
});

/// A provider that fetches transactions for a *specific user ID*.
final transactionsProvider = FutureProvider.autoDispose.family<List<Transaction>, String>((ref, userId) async {
  final transactionService = ref.read(transactionServiceProvider);
  final range = ref.watch(dateRangeProvider);
  return transactionService.getTransactions(
    userId,
    startDate: range.start,
    endDate: range.end,
  );
});

/// A "bridge" provider that the UI will watch.
final currentTransactionsProvider = FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final session = await ref.watch(sessionControllerProvider.future);
  if (session == null) {
    return [];
  }
  return ref.watch(transactionsProvider(session.$id).future);
});


/// This provider now depends on the reactive `currentTransactionsProvider`
/// and will filter its results.
final filteredTransactionsProvider = Provider.autoDispose<List<Transaction>>((ref) {
  final transactionsAsync = ref.watch(currentTransactionsProvider);
  final sortType = ref.watch(transactionSortProvider);

  // Use .when to safely access the data, providing a default empty list for loading/error states.
  final transactions = transactionsAsync.when(
    data: (data) => data,
    loading: () => [],
    error: (e, s) => [],
  );

  // Sort the already fetched and filtered-by-date data.
  final sortedTransactions = List<Transaction>.from(transactions);
  sortedTransactions.sort((a, b) {
    switch (sortType) {
      case TransactionSortType.dateAsc:
        return a.date.compareTo(b.date);
      case TransactionSortType.dateDesc:
        return b.date.compareTo(a.date);
      case TransactionSortType.quantityAsc:
        return a.quantity.compareTo(b.quantity);
      case TransactionSortType.quantityDesc:
        return b.quantity.compareTo(a.quantity);
    }
  });

  return sortedTransactions;
});