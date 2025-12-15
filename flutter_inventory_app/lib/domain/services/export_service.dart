import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_inventory_app/data/models/item.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

class ExportService {
  Future<void> exportItemsToCsv(List<Item> items) async {
    final List<List<dynamic>> rows = [];
    rows.add([
      'ID',
      'Name',
      'Brand',
      'Description',
      'Quantity',
      'Min Quantity',
      'Unit',
      'Purchase Price',
      'Sale Price',
      'Category ID',
    ]);
    for (final item in items) {
      rows.add([
        item.id,
        item.name,
        item.brand,
        item.description,
        item.quantity,
        item.minQuantity,
        item.unit,
        item.purchasePrice,
        item.salePrice,
        item.categoryId,
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    await _shareCsv('items.csv', csv);
  }

  Future<void> exportTransactionsToCsv(List<Transaction> transactions, Map<String, String> itemNames) async {
    final List<List<dynamic>> rows = [];
    rows.add([
      'ID',
      'Item Name',
      'Type',
      'Quantity',
      'Date',
      'Note',
    ]);
    for (final transaction in transactions) {
      rows.add([
        transaction.id,
        itemNames[transaction.itemId] ?? transaction.itemId,
        transaction.type.name,
        transaction.quantity,
        transaction.date.toIso8601String(),
        transaction.note,
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    await _shareCsv('transactions.csv', csv);
  }

  Future<void> _shareCsv(String fileName, String csvData) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(path)], text: 'Berikut adalah data ekspor dari Inventarisku');
  }
}
