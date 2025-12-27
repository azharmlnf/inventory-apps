import 'package:flutter_inventory_app/data/repositories/activity_log_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_log.dart' as domain;

final activityLogServiceProvider = Provider<ActivityLogService>((ref) {
  final activityLogRepository = ref.watch(activityLogRepositoryProvider);
  return ActivityLogService(activityLogRepository);
});

class ActivityLogService {
  final ActivityLogRepository _activityLogRepository;

  ActivityLogService(this._activityLogRepository);

  Future<void> recordActivity({
    required String userId,
    required String description,
    String? itemId,
  }) async {
    await _activityLogRepository.createActivityLog(
      userId: userId,
      description: description,
      itemId: itemId,
    );
  }

  Future<List<domain.ActivityLog>> getLogs(String userId) async {
    final dataModels = await _activityLogRepository.getActivityLogs(userId);
    
    return dataModels
        .map((e) => domain.ActivityLog(
                  id: e.id,
                  timestamp: e.timestamp,
                  description: e.description,
                  itemId: e.itemId,
                ))
            .toList();
      }
    }
