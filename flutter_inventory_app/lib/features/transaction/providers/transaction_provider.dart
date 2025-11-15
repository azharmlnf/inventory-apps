import 'dart:async';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/domain/services/transaction_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/item/providers/item_provider.dart'; // Import item provider

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
      
      // Update item quantity
      if (transaction.itemId != null) {
        final quantityChange = transaction.type == TransactionType.IN
            ? transaction.quantity
            : -transaction.quantity;
        await ref.read(itemProvider.notifier).updateItemQuantity(transaction.itemId!, quantityChange);
      }

      ref.invalidateSelf();
      ref.invalidate(itemProvider); // Invalidate item provider to refresh item list
      return future;
    });
  }

  /// Memperbarui transaksi yang ada.
  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionServiceProvider).updateTransaction(transaction);
      ref.invalidateSelf();
      return future;
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
        final quantityChange = transactionToDelete.type == TransactionType.IN
            ? -transactionToDelete.quantity
            : transactionToDelete.quantity;
        await ref.read(itemProvider.notifier).updateItemQuantity(transactionToDelete.itemId!, quantityChange);
      }

      ref.invalidateSelf();
      ref.invalidate(itemProvider); // Invalidate item provider to refresh item list
      return future;
    });
  }
}