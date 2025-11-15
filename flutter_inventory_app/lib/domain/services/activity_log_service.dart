import 'package:flutter_inventory_app/data/repositories/activity_log_repository.dart';
import 'package:flutter_inventory_app/data/repositories/auth_repository.dart';
import '../models/activity_log.dart' as domain;

class ActivityLogService {
  final ActivityLogRepository _activityLogRepository;
  final AuthRepository _authRepository;

  ActivityLogService(this._activityLogRepository, this._authRepository);

  Future<void> recordActivity({
    required String description,
    String? itemId,
  }) async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw Exception("User not logged in, cannot record activity.");
    }
    await _activityLogRepository.createActivityLog(
      userId: user.$id,
      description: description,
      itemId: itemId,
    );
  }

  Future<List<domain.ActivityLog>> getLogs() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw Exception("User not logged in");
    }

    final dataModels = await _activityLogRepository.getActivityLogs(user.$id);
    
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
