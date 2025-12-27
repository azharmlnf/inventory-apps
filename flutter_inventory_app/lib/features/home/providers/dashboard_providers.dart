import 'package:flutter/material.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to count total item types.
final totalItemsCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(currentItemsProvider).whenData((items) => items.length);
});

/// Provider to count total categories.
final totalCategoriesCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(currentCategoriesProvider).whenData((categories) => categories.length);
});

/// Provider to get a list of low-stock items.
final lowStockItemsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  return ref.watch(currentItemsProvider).whenData((items) {
    return items.where((item) => item.quantity <= item.minQuantity).toList();
  });
});

/// Provider to calculate the total inventory stock value.
final totalStockValueProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(currentItemsProvider).whenData((items) {
    return items.fold<double>(0.0, (sum, item) {
      final price = item.purchasePrice ?? 0.0;
      return sum + (item.quantity * price);
    });
  });
});

/// Provider to get transactions made today.
final transactionsTodayProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  return ref.watch(currentTransactionsProvider).whenData((transactions) {
    final now = DateTime.now();
    return transactions.where((transaction) {
      return transaction.date.year == now.year &&
             transaction.date.month == now.month &&
             transaction.date.day == now.day;
    }).toList();
  });
});

/// Provider to get the latest transactions (e.g., the last 5).
final latestTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  return ref.watch(currentTransactionsProvider).whenData((transactions) {
    // Sort by date descending and take the first 5
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedTransactions.take(5).toList();
  });
});

/// Provider to get a category name by its ID.
final categoryNameProvider = Provider.family<AsyncValue<String>, String>((ref, categoryId) {
  return ref.watch(currentCategoriesProvider).whenData((categories) {
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(id: categoryId, userId: '', name: 'Tidak Berkategori'),
    );
    return category.name;
  });
});

/// Provider to get all items (an alias for currentItemsProvider).
final allItemsProvider = Provider<AsyncValue<List<Item>>>((ref) {
  return ref.watch(currentItemsProvider);
});

/// Provider to get an item by its ID.
final itemByIdProvider = Provider.family<AsyncValue<Item?>, String>((ref, itemId) {
  return ref.watch(currentItemsProvider).whenData((items) {
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null; // Return null if item is not found
    }
  });
});

/// Data class for aggregated stock data per category.
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

/// Provider to aggregate stock data by category for charting.
final stockByCategoryProvider = Provider<AsyncValue<List<CategoryStock>>>((ref) {
  final itemsAsync = ref.watch(allItemsProvider);
  final categoriesAsync = ref.watch(currentCategoriesProvider);

  // This is a complex provider that depends on two other async providers.
  // A better implementation might use AsyncValue.guard or further composition.
  // For now, we handle loading and error states manually.
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

  // Initialize map with all existing categories
  for (var category in categories) {
    categoryQuantities[category.id] = 0;
  }

  // Aggregate quantities from each item
  for (var item in items) {
    final categoryId = item.categoryId;
    if (categoryId != null && categoryQuantities.containsKey(categoryId)) {
      categoryQuantities[categoryId] = (categoryQuantities[categoryId]!) + item.quantity;
    } else {
      // Handle items without a category
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
