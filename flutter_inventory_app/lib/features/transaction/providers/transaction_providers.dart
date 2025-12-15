import 'package:flutter_inventory_app/domain/services/transaction_service.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/data/repositories/transaction_repository.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/domain/services/ad_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

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

final filteredTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  final range = ref.watch(dateRangeProvider);
  final sortType = ref.watch(transactionSortProvider);

  debugPrint('Filtering transactions by date range: Start=${range.start}, End=${range.end}');

  final transactions = await transactionService.getTransactions(
    startDate: range.start,
    endDate: range.end,
  );

  transactions.sort((a, b) {
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

  return transactions;
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
    state = const AsyncValue.loading();
    await ref.read(transactionServiceProvider).createTransaction(transaction);
    state = await AsyncValue.guard(() => _fetchTransactions());
    // Show interstitial ad if user is not premium
    if (!ref.read(authControllerProvider).isPremium) {
      ref.read(adServiceProvider).createInterstitialAd(onAdLoaded: (ad) => ad.show());
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    await ref.read(transactionServiceProvider).updateTransaction(transaction);
    state = await AsyncValue.guard(() => _fetchTransactions());
    // Show interstitial ad if user is not premium
    if (!ref.read(authControllerProvider).isPremium) {
      ref.read(adServiceProvider).createInterstitialAd(onAdLoaded: (ad) => ad.show());
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => ref.read(transactionServiceProvider).deleteTransaction(transactionId));
    state = await AsyncValue.guard(() => _fetchTransactions());
    // Show interstitial ad if user is not premium
    if (!ref.read(authControllerProvider).isPremium) {
      ref.read(adServiceProvider).createInterstitialAd(onAdLoaded: (ad) => ad.show());
    }
  }
}