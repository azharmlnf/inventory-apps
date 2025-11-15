import 'package:appwrite/models.dart';

class ActivityLog {
  final String? id;
  final String userId;
  final DateTime timestamp;
  final String description;
  final String? itemId;

  ActivityLog({
    this.id,
    required this.userId,
    required this.timestamp,
    required this.description,
    this.itemId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'itemId': itemId,
    };
  }

  factory ActivityLog.fromDocument(Document doc) {
    return ActivityLog.fromMap(doc.data, doc.$id);
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map, [String? id]) {
    return ActivityLog(
      id: id,
      userId: map['userId'],
      timestamp: DateTime.parse(map['timestamp']),
      description: map['description'],
      itemId: map['itemId'],
    );
  }
}
