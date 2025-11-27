import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk menghitung total jenis barang.
final totalItemsCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(itemsProvider).whenData((items) => items.length);
});

/// Provider untuk menghitung total kategori.
final totalCategoriesCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(categoriesProvider).whenData((categories) => categories.length);
});

/// Provider untuk mendapatkan daftar item dengan stok rendah.
final lowStockItemsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  return ref.watch(itemsProvider).whenData((items) {
    return items.where((item) => item.quantity <= item.minQuantity).toList();
  });
});

/// Provider untuk mendapatkan transaksi hari ini.
final transactionsTodayProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  return ref.watch(transactionsProvider).whenData((transactions) {
    final now = DateTime.now();
    return transactions.where((transaction) {
      return transaction.date.year == now.year &&
             transaction.date.month == now.month &&
             transaction.date.day == now.day;
    }).toList();
  });
});

/// Provider untuk mendapatkan transaksi terbaru (misal, 5 transaksi terakhir).
final latestTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  return ref.watch(transactionsProvider).whenData((transactions) {
    // Sort by date descending and take the first 5
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedTransactions.take(5).toList();
  });
});

/// Provider untuk mendapatkan nama kategori berdasarkan ID.
final categoryNameProvider = Provider.family<AsyncValue<String>, String>((ref, categoryId) {
  return ref.watch(categoriesProvider).whenData((categories) {
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(id: categoryId, userId: '', name: 'Tidak Berkategori'),
    );
    return category.name;
  });
});

/// Provider untuk mendapatkan semua item.
final allItemsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  return ref.watch(itemsProvider);
});

/// Provider untuk mendapatkan item berdasarkan ID.
final itemByIdProvider = Provider.family<AsyncValue<Item?>, String>((ref, itemId) {
  return ref.watch(itemsProvider).whenData((items) {
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null; // Return null if item is not found
    }
  });
});
