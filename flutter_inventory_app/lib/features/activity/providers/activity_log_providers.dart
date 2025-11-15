import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/domain/models/activity_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/repositories/activity_log_repository.dart'; // Added
import 'package:flutter_inventory_app/data/repositories/auth_repository.dart'; // Added

/// Provider untuk ActivityLogService.
final activityLogServiceProvider = Provider<ActivityLogService>((ref) {
  final activityLogRepository = ref.watch(activityLogRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return ActivityLogService(activityLogRepository, authRepository);
});

/// AsyncNotifierProvider untuk mengelola daftar activity logs.
final activityLogsProvider = AsyncNotifierProvider<ActivityLogsNotifier, List<ActivityLog>>(() {
  return ActivityLogsNotifier();
});

class ActivityLogsNotifier extends AsyncNotifier<List<ActivityLog>> {
  @override
  Future<List<ActivityLog>> build() async {
    return _fetchActivityLogs();
  }

  Future<List<ActivityLog>> _fetchActivityLogs() async {
    final activityLogService = ref.read(activityLogServiceProvider);
    return activityLogService.getLogs();
  }

  Future<void> refreshActivityLogs() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchActivityLogs());
  }
}