// # FILE: category.dart
// # LOKASI: flutter_inventory_app/lib/data/models/category.dart

import 'package:appwrite/models.dart';

/// Model untuk merepresentasikan data sebuah kategori.
class Category {
  final String id;      // ID unik dokumen dari Appwrite ($id)
  final String userId;  // ID pengguna yang memiliki kategori ini
  final String name;    // Nama kategori

  Category({
    required this.id,
    required this.userId,
    required this.name,
  });

  /// Factory constructor untuk membuat instance Category dari Dokumen Appwrite.
  factory Category.fromDocument(Document document) {
    return Category(
      id: document.$id,
      userId: document.data['userId'],
      name: document.data['name'],
    );
  }

  /// Mengonversi instance Category menjadi `Map<String, dynamic>` untuk dikirim ke Appwrite.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
    };
  }
}
