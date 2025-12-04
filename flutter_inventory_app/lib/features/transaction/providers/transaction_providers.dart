import 'package:flutter_inventory_app/domain/services/transaction_service.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/data/repositories/transaction_repository.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dateRangeProvider = StateProvider<({DateTime? start, DateTime? end})>((ref) {
  return (start: null, end: null);
});

final filteredTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  final range = ref.watch(dateRangeProvider);
  return transactionService.getTransactions(
    startDate: range.start,
    endDate: range.end,
    // type: TransactionType.inType, // This was an example. The original code doesn't specify type filter here.
  );
});

/// Provider untuk TransactionService.
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final itemRepository = ref.watch(itemRepositoryProvider);
  final account = ref.watch(appwriteAccountProvider);
  final activityLogService = ref.watch(activityLogServiceProvider);
  return TransactionService(transactionRepository, itemRepository, account, activityLogService);
});

/// AsyncNotifierProvider untuk mengelola daftar transaksi.
final transactionsProvider = AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(() {
  return TransactionsNotifier();
});

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    return _fetchTransactions();
  }

  Future<List<Transaction>> _fetchTransactions() async {
    final transactionService = ref.read(transactionServiceProvider);
    final range = ref.read(dateRangeProvider); // Get the current date range
    return transactionService.getTransactions(
      startDate: range.start,
      endDate: range.end,
    );
  }

  Future<void> refreshTransactions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTransactions());
  }

  Future<void> addTransaction(Transaction transaction) async {
    // Set state to loading
    state = const AsyncValue.loading();
    // Perform the mutation. The UI layer will invalidate the provider to trigger a re-fetch.
    await ref.read(transactionServiceProvider).createTransaction(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    // Perform the mutation. The UI layer will invalidate the provider to trigger a re-fetch.
    await ref.read(transactionServiceProvider).updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => ref.read(transactionServiceProvider).deleteTransaction(transactionId));
    state = await AsyncValue.guard(() => _fetchTransactions());
  }
}