
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/repositories/category_repository.dart';
import 'package:flutter_inventory_app/domain/services/category_service.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';

/// Provider for the stateless CategoryService.
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  // No longer depends on the Account provider directly.
  return CategoryService(categoryRepository);
});

/// A provider that fetches categories for a *specific user ID*.
final categoriesProvider = FutureProvider.autoDispose.family<List<Category>, String>((ref, userId) async {
  final categoryService = ref.read(categoryServiceProvider);
  return categoryService.getCategories(userId);
});

/// A "bridge" provider that the UI will watch.
final currentCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final session = await ref.watch(sessionControllerProvider.future);

  if (session == null) {
    return [];
  }
  
  return ref.watch(categoriesProvider(session.$id).future);
});

