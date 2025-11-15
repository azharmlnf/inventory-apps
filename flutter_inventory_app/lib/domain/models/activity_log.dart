class ActivityLog {
  final String? id;
  final DateTime timestamp;
  final String description;
  final String? itemId;

  ActivityLog({
    this.id,
    required this.timestamp,
    required this.description,
    this.itemId,
  });
}
