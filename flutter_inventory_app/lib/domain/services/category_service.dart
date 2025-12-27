import 'package:appwrite/models.dart';
import 'package:flutter_inventory_app/data/models/category.dart';
import 'package:flutter_inventory_app/data/repositories/category_repository.dart';

/// Service Layer for managing business logic related to categories.
/// This service is now stateless regarding the user.
class CategoryService {
  final CategoryRepository _categoryRepository;

  CategoryService(this._categoryRepository);

  /// Creates a new category for a specific user.
  Future<Category> createCategory(String userId, String name) async {
    return _categoryRepository.createCategory(userId: userId, name: name);
  }

  /// Fetches all categories belonging to a specific user.
  Future<List<Category>> getCategories(String userId) async {
    return _categoryRepository.getCategories(userId);
  }

  /// Updates an existing category.
  Future<Category> updateCategory(String categoryId, String name) async {
    // No userId needed here as permissions are handled by Appwrite based on the document.
    return _categoryRepository.updateCategory(categoryId: categoryId, name: name);
  }

  /// Deletes an existing category.
  Future<void> deleteCategory(String categoryId) async {
    // No userId needed here as permissions are handled by Appwrite based on the document.
    return _categoryRepository.deleteCategory(categoryId: categoryId);
  }
}
