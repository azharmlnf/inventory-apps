
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/repositories/category_repository.dart';
import 'package:flutter_inventory_app/domain/services/category_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk CategoryService.
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  final account = ref.watch(appwriteAccountProvider);
  return CategoryService(categoryRepository, account);
});

/// AsyncNotifierProvider untuk mengelola daftar kategori.
final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<Category>>(() {
  return CategoriesNotifier();
});

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    return _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() async {
    final categoryService = ref.read(categoryServiceProvider);
    return categoryService.getCategories();
  }

  Future<void> refreshCategories() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCategories());
  }

  Future<void> addCategory(String name) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => ref.read(categoryServiceProvider).createCategory(name));
    state = await AsyncValue.guard(() => _fetchCategories());
  }

  Future<void> updateCategory(String categoryId, String name) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => ref.read(categoryServiceProvider).updateCategory(categoryId, name));
    state = await AsyncValue.guard(() => _fetchCategories());
  }

  Future<void> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => ref.read(categoryServiceProvider).deleteCategory(categoryId));
    state = await AsyncValue.guard(() => _fetchCategories());
  }
}
