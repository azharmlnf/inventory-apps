import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/repositories/item_repository.dart';
import 'package:flutter_inventory_app/domain/services/item_service.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_providers.dart';

/// Provider untuk ItemRepository.
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  return ItemRepository(databases);
});

/// Provider untuk ItemService.
final itemServiceProvider = Provider<ItemService>((ref) {
  final itemRepository = ref.watch(itemRepositoryProvider);
  final account = ref.watch(appwriteAccountProvider);
  final activityLogService = ref.watch(activityLogServiceProvider);
  return ItemService(itemRepository, account, activityLogService);
});
