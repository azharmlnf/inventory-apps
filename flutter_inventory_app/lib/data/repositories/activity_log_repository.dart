import 'package:appwrite/appwrite.dart';
import 'package:flutter_inventory_app/core/app_constants.dart';
import 'package:flutter_inventory_app/data/models/activity_log.dart';

class ActivityLogRepository {
  final Databases _databases;

  ActivityLogRepository(this._databases);

  Future<void> createActivityLog({
    required String userId,
    required String description,
    String? itemId,
  }) async {
    try {
      final log = ActivityLog(
        userId: userId,
        timestamp: DateTime.now(),
        description: description,
        itemId: itemId,
      );

      await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.activityLogsCollectionId,
        documentId: ID.unique(),
        data: log.toMap(),
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );
    } on AppwriteException catch (e) {
      // Handle exception, maybe rethrow as a custom exception
      throw Exception('Failed to create activity log: ${e.message}');
    }
  }

  Future<List<ActivityLog>> getActivityLogs(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.activityLogsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('timestamp'), // Show newest first
        ],
      );
      return response.documents.map((doc) => ActivityLog.fromDocument(doc)).toList();
    } on AppwriteException catch (e) {
      throw Exception('Failed to fetch activity logs: ${e.message}');
    }
  }
}
