import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/repositories/activity_log_repository.dart';
import 'package:flutter_inventory_app/data/repositories/auth_repository.dart';
import 'package:flutter_inventory_app/domain/models/activity_log.dart';
import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';

// Repository Provider
final activityLogRepositoryProvider = Provider<ActivityLogRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  return ActivityLogRepository(databases);
});

// Service Provider
final activityLogServiceProvider = Provider<ActivityLogService>((ref) {
  final activityLogRepository = ref.watch(activityLogRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return ActivityLogService(activityLogRepository, authRepository);
});

// FutureProvider to get all activity logs
final activityLogsProvider = FutureProvider<List<ActivityLog>>((ref) async {
  final activityLogService = ref.watch(activityLogServiceProvider);
  return activityLogService.getLogs();
});
