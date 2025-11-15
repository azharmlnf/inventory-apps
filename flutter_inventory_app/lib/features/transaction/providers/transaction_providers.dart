import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/repositories/transaction_repository.dart';
import 'package:flutter_inventory_app/domain/services/transaction_service.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_providers.dart';
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';

/// Provider untuk TransactionRepository.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  return TransactionRepository(databases);
});

/// Provider untuk TransactionService.
final transactionServiceProvider = Provider<TransactionService>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final itemRepository = ref.watch(itemRepositoryProvider);
  final account = ref.watch(appwriteAccountProvider);
  final activityLogService = ref.watch(activityLogServiceProvider);
  return TransactionService(
    transactionRepository,
    itemRepository,
    account,
    activityLogService,
  );
});
