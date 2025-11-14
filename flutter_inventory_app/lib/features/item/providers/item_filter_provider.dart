import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Enum untuk menentukan tipe pengurutan yang tersedia.
enum ItemSortType {
  byNameAsc('Nama (A-Z)'),
  byNameDesc('Nama (Z-A)'),
  byQuantityAsc('Stok (Sedikit > Banyak)'),
  byQuantityDesc('Stok (Banyak > Sedikit)');

  const ItemSortType(this.label);
  final String label;
}

/// Provider untuk menampung tipe sortir yang sedang aktif.
final itemSortProvider = StateProvider<ItemSortType>((ref) {
  return ItemSortType.byNameAsc; // Default sort
});

/// Provider untuk menampung ID kategori yang dipilih untuk filter.
/// Null berarti tidak ada filter (tampilkan semua).
final itemCategoryFilterProvider = StateProvider<String?>((ref) {
  return null;
});
