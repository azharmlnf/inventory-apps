import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/models/activity_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activityLogRepositoryProvider = Provider<ActivityLogRepository>((ref) {
  final databases = ref.watch(appwriteDatabaseProvider);
  return ActivityLogRepository(databases);
});

class ActivityLogRepository {
  final Databases _databases;
  final String _databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  final String _collectionId = dotenv.env['APPWRITE_ACTIVITY_LOGS_COLLECTION_ID']!;

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
        databaseId: _databaseId,
        collectionId: _collectionId,
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
        databaseId: _databaseId,
        collectionId: _collectionId,
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
