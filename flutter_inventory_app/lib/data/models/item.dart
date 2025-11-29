import 'package:appwrite/models.dart';

/// Model untuk merepresentasikan data sebuah barang (item).
/// Disesuaikan dengan field pada ERD, SRS, dan UI/UX prototype.
class Item {
  final String id;          // ID unik dokumen dari Appwrite ($id)
  final String userId;      // ID pengguna yang memiliki barang ini
  final String name;        // Nama barang
  final String? barcode;     // Barcode produk (opsional)
  final String? brand;      // Merek barang (opsional)
  final String? description; // Deskripsi barang (opsional)
  final int quantity;       // Kuantitas stok saat ini
  final int minQuantity;    // Batas minimum stok untuk notifikasi
  final String unit;        // Satuan barang (Pcs, Box, dll)
  final double? purchasePrice; // Harga beli (opsional)
  final double? salePrice;     // Harga jual (opsional)
  final String? categoryId;   // ID kategori (opsional)
  final String? imageId;      // ID file gambar di Appwrite Storage (opsional)

  Item({
    required this.id,
    required this.userId,
    required this.name,
    this.barcode,
    this.brand,
    this.description,
    required this.quantity,
    required this.minQuantity,
    required this.unit,
    this.purchasePrice,
    this.salePrice,
    this.categoryId,
    this.imageId,
  });

  /// Factory constructor untuk membuat instance Item dari Dokumen Appwrite.
  factory Item.fromDocument(Document document) {
    return Item(
      id: document.$id,
      userId: document.data['userId'],
      name: document.data['name'] ?? '',
      barcode: document.data['barcode'],
      brand: document.data['brand'],
      description: document.data['description'],
      quantity: int.tryParse(document.data['quantity']?.toString() ?? '0') ?? 0,
      minQuantity: int.tryParse(document.data['min_quantity']?.toString() ?? '0') ?? 0,
      unit: document.data['unit'] ?? 'Pcs',
      purchasePrice: double.tryParse(document.data['purchase_price']?.toString() ?? ''),
      salePrice: double.tryParse(document.data['sale_price']?.toString() ?? ''),
      categoryId: document.data['categoryId'],
      imageId: document.data['imageId'],
    );
  }

  /// Mengonversi instance Item menjadi `Map<String, dynamic>` untuk dikirim ke Appwrite.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'userId': userId,
      'name': name,
      'barcode': barcode,
      'brand': brand,
      'description': description,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'unit': unit,
      'categoryId': categoryId,
      'imageId': imageId,
    };
    if (purchasePrice != null) {
      json['purchase_price'] = purchasePrice;
    }
    if (salePrice != null) {
      json['sale_price'] = salePrice;
    }
    return json;
  }

  /// Membuat salinan Item dengan perubahan opsional.
  Item copyWith({
    String? id,
    String? userId,
    String? name,
    String? barcode,
    String? brand,
    String? description,
    int? quantity,
    int? minQuantity,
    String? unit,
    double? purchasePrice,
    double? salePrice,
    String? categoryId,
    String? imageId,
  }) {
    return Item(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      categoryId: categoryId ?? this.categoryId,
      imageId: imageId ?? this.imageId,
    );
  }
}
