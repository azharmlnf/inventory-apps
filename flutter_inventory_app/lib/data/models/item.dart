import 'package:appwrite/models.dart';

/// Model untuk merepresentasikan data sebuah barang (item).
/// Disesuaikan dengan field pada ERD, SRS, dan UI/UX prototype.
class Item {
  final String id;          // ID unik dokumen dari Appwrite ($id)
  final String userId;      // ID pengguna yang memiliki barang ini
  final String name;        // Nama barang
  final String? description; // Deskripsi barang (opsional)
  final int quantity;       // Kuantitas stok saat ini
  final int minQuantity;    // Batas minimum stok untuk notifikasi
  final String unit;        // Satuan barang (Pcs, Box, dll)
  final double purchasePrice; // Harga beli
  final double salePrice;     // Harga jual
  final String? categoryId;   // ID kategori (opsional)
  final String? imageId;      // ID file gambar di Appwrite Storage (opsional)

  Item({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    required this.purchasePrice,
    required this.salePrice,
    this.categoryId,
    this.imageId,
  });

  /// Factory constructor untuk membuat instance Item dari Dokumen Appwrite.
  factory Item.fromDocument(Document document) {
    return Item(
      id: document.$id,
      userId: document.data['userId'],
      name: document.data['name'] ?? '',
      description: document.data['description'],
      quantity: int.tryParse(document.data['quantity']?.toString() ?? '0') ?? 0,
      minQuantity: int.tryParse(document.data['min_quantity']?.toString() ?? '0') ?? 0,
      unit: document.data['unit'] ?? 'Pcs',
      purchasePrice: double.tryParse(document.data['purchase_price']?.toString() ?? '0.0') ?? 0.0,
      salePrice: double.tryParse(document.data['sale_price']?.toString() ?? '0.0') ?? 0.0,
      categoryId: document.data['categoryId'],
      imageId: document.data['imageId'],
    );
  }

  /// Mengonversi instance Item menjadi Map<String, dynamic> untuk dikirim ke Appwrite.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'unit': unit,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'categoryId': categoryId,
      'imageId': imageId,
    };
  }
}
