import 'package:flutter/material.dart';
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

/// Provider untuk menghitung total nilai stok inventaris.
final totalStockValueProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(itemsProvider).whenData((items) {
    return items.fold<double>(0.0, (sum, item) {
      final price = item.purchasePrice ?? 0.0;
      return sum + (item.quantity * price);
    });
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

/// Data class untuk menampung data agregasi stok per kategori.
class CategoryStock {
  final String categoryName;
  final double totalQuantity;
  final Color color;

  CategoryStock({
    required this.categoryName,
    required this.totalQuantity,
    required this.color,
  });
}

/// Provider untuk mengagregasi data stok per kategori.
final stockByCategoryProvider = Provider<AsyncValue<List<CategoryStock>>>((ref) {
  final itemsAsync = ref.watch(allItemsProvider);
  final categoriesAsync = ref.watch(categoriesProvider);

  if (itemsAsync.isLoading || categoriesAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (itemsAsync.hasError) {
    return AsyncValue.error(itemsAsync.error!, itemsAsync.stackTrace!);
  }
  if (categoriesAsync.hasError) {
    return AsyncValue.error(categoriesAsync.error!, categoriesAsync.stackTrace!);
  }

  final items = itemsAsync.value!;
  final categories = categoriesAsync.value!;

  final Map<String, double> categoryQuantities = {};

  // Inisialisasi map dengan semua kategori yang ada
  for (var category in categories) {
    categoryQuantities[category.id] = 0;
  }

  // Agregasi kuantitas dari setiap item
  for (var item in items) {
    final categoryId = item.categoryId;
    if (categoryId != null && categoryQuantities.containsKey(categoryId)) {
      categoryQuantities[categoryId] = (categoryQuantities[categoryId]!) + item.quantity;
    } else {
      // Handle item tanpa kategori
      categoryQuantities['uncategorized'] = (categoryQuantities['uncategorized'] ?? 0) + item.quantity;
    }
  }

  final List<CategoryStock> result = [];
  final List<Color> colors = Colors.primaries;
  int colorIndex = 0;

  categoryQuantities.forEach((categoryId, totalQuantity) {
    if (totalQuantity > 0) {
      String categoryName;
      if (categoryId == 'uncategorized') {
        categoryName = 'Lainnya';
      } else {
        try {
          categoryName = categories.firstWhere((cat) => cat.id == categoryId).name;
        } catch (e) {
          categoryName = 'Kategori Tidak Dikenal';
        }
      }
      
      result.add(CategoryStock(
        categoryName: categoryName,
        totalQuantity: totalQuantity,
        color: colors[colorIndex % colors.length],
      ));
      colorIndex++;
    }
  });

  return AsyncValue.data(result);
});
