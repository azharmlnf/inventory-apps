import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/domain/services/item_service.dart';
import 'package:flutter_inventory_app/features/item/providers/item_filter_provider.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/main.dart'; // For notificationServiceProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the stateless ItemService.
final itemServiceProvider = Provider<ItemService>((ref) {
  final itemRepository = ref.watch(itemRepositoryProvider);
  final activityLogService = ref.watch(activityLogServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  // No longer depends on the Account provider directly.
  return ItemService(itemRepository, activityLogService, notificationService);
});

/// A provider that fetches items for a *specific user ID*.
///
/// This uses the `.family` modifier, creating a separate provider for each user.
/// This is the core of the solution to prevent stale data.
final itemsProvider = FutureProvider.autoDispose.family<List<Item>, String>((ref, userId) async {
  final sortType = ref.watch(itemSortProvider);
  final categoryId = ref.watch(itemCategoryFilterProvider);
  final itemService = ref.read(itemServiceProvider);

  return itemService.getItems(
    userId,
    categoryId: categoryId,
    sortType: sortType,
  );
});

/// A "bridge" provider that the UI will watch.
///
/// It watches the current user session. When the user changes, it automatically
/// re-evaluates and watches the `itemsProvider` with the new user's ID.
final currentItemsProvider = FutureProvider.autoDispose<List<Item>>((ref) async {
  final session = await ref.watch(sessionControllerProvider.future);

  // If there's no user, return an empty list.
  if (session == null) {
    return [];
  }

  // Watch the family provider with the current user's ID.
  return ref.watch(itemsProvider(session.$id).future);
});
