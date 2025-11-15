import 'package:appwrite/models.dart';
import 'package:appwrite/models.dart' as appwrite_models;

enum TransactionType {
  IN, // IN
  OUT, // OUT
}

/// Model untuk merepresentasikan data sebuah transaksi.
class Transaction {
  final String id;
  final String userId;
  final String? itemId; // Changed to nullable
  final TransactionType type;
  final int quantity;
  final DateTime date;
  final String? note;

  Transaction({
    required this.id,
    required this.userId,
    this.itemId, // Changed to nullable
    required this.type,
    required this.quantity,
    required this.date,
    this.note,
  });

  /// Factory constructor untuk membuat instance Transaction dari Dokumen Appwrite.
  factory Transaction.fromDocument(appwrite_models.Document document) {
    String? extractedItemId;
    final itemIdData = document.data['itemId'];
    
    if (itemIdData is List && itemIdData.isNotEmpty) {
      // If it's a list (e.g., from a relationship attribute), try to get the first item's ID
      final firstItem = itemIdData.first;
      if (firstItem is String && firstItem.isNotEmpty) {
        extractedItemId = firstItem;
      } else if (firstItem is Map<String, dynamic> && firstItem.containsKey('\$id')) {
        extractedItemId = firstItem['\$id'] as String;
      }
    } else if (itemIdData is String && itemIdData.isNotEmpty) {
      // If it's a direct string ID
      extractedItemId = itemIdData;
    } else if (itemIdData is Map<String, dynamic> && itemIdData.containsKey('\$id')) {
      // If it's a direct map (e.g., populated relationship)
      extractedItemId = itemIdData['\$id'] as String;
    }

    return Transaction(
      id: document.$id,
      userId: document.data['userId'],
      itemId: extractedItemId,
      type: (document.data['type'] == 'IN') ? TransactionType.IN : TransactionType.OUT,
      quantity: int.tryParse(document.data['quantity']?.toString() ?? '0') ?? 0,
      date: DateTime.parse(document.data['date']),
      note: document.data['note'],
    );
  }

  /// Mengonversi instance Transaction menjadi Map<String, dynamic> untuk dikirim ke Appwrite.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'userId': userId,
      'type': type == TransactionType.IN ? 'IN' : 'OUT',
      'quantity': quantity,
      'date': date.toIso8601String(),
      'note': note,
    };
    if (itemId != null && itemId!.isNotEmpty) {
      print('Transaction toJson - itemId: $itemId'); // Debug print
      json['itemId'] = itemId; // Send itemId as a plain string
    }
    return json;
  }
}