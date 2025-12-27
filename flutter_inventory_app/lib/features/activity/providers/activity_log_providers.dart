import 'package:flutter_inventory_app/domain/services/activity_log_service.dart';
import 'package:flutter_inventory_app/domain/models/activity_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';

/// A provider that fetches activity logs for a *specific user ID*.
final activityLogsProvider = FutureProvider.autoDispose.family<List<ActivityLog>, String>((ref, userId) async {
  final activityLogService = ref.read(activityLogServiceProvider);
  return activityLogService.getLogs(userId);
});

/// A "bridge" provider that the UI will watch.
final currentActivityLogsProvider = FutureProvider.autoDispose<List<ActivityLog>>((ref) async {
  final session = await ref.watch(sessionControllerProvider.future);

  if (session == null) {
    return [];
  }
  
  return ref.watch(activityLogsProvider(session.$id).future);
});