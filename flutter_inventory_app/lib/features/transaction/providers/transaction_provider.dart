import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/data/repositories/transaction_repository.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart'; // Import appwrite_provider
import 'package:flutter_inventory_app/data/repositories/activity_log_repository.dart'; // Import for ActivityLogRepository
import 'package:flutter_inventory_app/data/repositories/auth_repository.dart'; // Import for AuthRepository // Import for AuthRepository
import 'package:appwrite/appwrite.dart'; // Import Account from appwrite

import 'package:flutter_inventory_app/domain/services/transaction_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_provider.dart'; // Import item provider

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.read(appwriteDatabaseProvider));
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(ref.read(appwriteDatabaseProvider));
});

final activityLogRepositoryProvider = Provider<ActivityLogRepository>((ref) {
  return ActivityLogRepository(ref.read(appwriteDatabaseProvider));
});

final activityLogServiceProvider = Provider<ActivityLogService>((ref) {
  return ActivityLogService(ref.read(activityLogRepositoryProvider), ref.read(authRepositoryProvider));
});

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(
    ref.read(transactionRepositoryProvider),
    ref.read(itemRepositoryProvider),
    ref.read(appwriteAccountProvider), // Assuming appwriteAccountProvider is defined in appwrite_provider.dart
    ref.read(activityLogServiceProvider),
  );
});

/// AsyncNotifierProvider untuk state management transaksi.
/// Otomatis akan re-fetch data ketika user berubah.
final transactionProvider = AsyncNotifierProvider<TransactionNotifier, List<Transaction>>(TransactionNotifier.new);

class TransactionNotifier extends AsyncNotifier<List<Transaction>> {
  
  /// Metode `build` akan dipanggil otomatis untuk mengambil data awal.
  /// Ia juga akan dipanggil ulang jika dependensi (seperti auth state) berubah.
  @override
  FutureOr<List<Transaction>> build() {
    final authState = ref.watch(authControllerProvider);

    if (authState.status != AuthStatus.authenticated) {
      return []; // Kembalikan list kosong jika tidak ada user yang login
    }
    
    return ref.read(transactionServiceProvider).getTransactions();
  }

  /// Menambahkan transaksi baru.
  Future<void> addTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionServiceProvider).createTransaction(transaction);
      
      ref.invalidateSelf();
      ref.invalidate(itemProvider); // Invalidate item provider to refresh item list
      return ref.read(transactionServiceProvider).getTransactions();
    });
  }

  /// Memperbarui transaksi yang ada.
  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionServiceProvider).updateTransaction(transaction);
      ref.invalidateSelf();
      return ref.read(transactionServiceProvider).getTransactions();
    });
  }

  /// Menghapus transaksi.
  Future<void> deleteTransaction(String transactionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Fetch the transaction details before deleting to revert item quantity
      final currentTransactions = state.value ?? [];
      final transactionToDelete = currentTransactions.firstWhere((t) => t.id == transactionId);

      await ref.read(transactionServiceProvider).deleteTransaction(transactionId);
      
      // Revert item quantity
      if (transactionToDelete.itemId != null) {
        final quantityChange = transactionToDelete.type == TransactionType.inType
            ? -transactionToDelete.quantity
            : transactionToDelete.quantity;
        await ref.read(itemProvider.notifier).updateItemQuantity(transactionToDelete.itemId!, quantityChange);
      }

      ref.invalidateSelf();
      ref.invalidate(itemProvider); // Invalidate item provider to refresh item list
      return ref.read(transactionServiceProvider).getTransactions();
    });
  }
}