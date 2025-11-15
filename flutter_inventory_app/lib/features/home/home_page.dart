import 'package:flutter_inventory_app/features/transaction/pages/transaction_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/activity_log_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/category_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';

class _PlaceholderItem {
  final String nama;
  final int kuantitas;
  final String unit;

  _PlaceholderItem({required this.nama, required this.kuantitas, required this.unit});
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // Placeholder functions for data that will come from Appwrite
  String getKategoriNama(String id) {
    return 'Tidak Berkategori'; // Placeholder
  }

  _PlaceholderItem? getBarangById(String id) {
    // In a real app, this would fetch data
    return null; // Placeholder
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.user;

    final totalJenisBarang = 0;
    final stokAkanHabis = 0;
    final transaksiHariIni = 0;

    final lowStockItems = <_PlaceholderItem>[];

    final latestTransactions = <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventarisku',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (currentUser != null)
                    Text(
                      currentUser.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Theme.of(context).colorScheme.primary),
              title: Text('Dashboard', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Already on dashboard, no action needed
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: Theme.of(context).colorScheme.primary),
              title: Text('Barang', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ItemListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
              title: Text('Kategori', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoryListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
              title: Text('Transaksi', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TransactionListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.primary),
              title: Text('Laporan', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Laporan page
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
              title: Text('Aktivitas', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityLogListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
              title: Text('Pengaturan', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Pengaturan page
              },
            ),
                        ListTile(
              leading: Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.primary),
              title: Text('Premium', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to premium page
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
              title: Text('Logout', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildSummaryCard(
                    'Total Jenis Barang', totalJenisBarang.toString(), Icons.category, Colors.blue.shade700),
                _buildSummaryCard(
                    'Stok Akan Habis', stokAkanHabis.toString(), Icons.warning_amber, Colors.orange.shade700),
                _buildSummaryCard(
                    'Transaksi Hari Ini', transaksiHariIni.toString(), Icons.swap_horiz, Colors.green.shade700),
              ],
            ),
            const SizedBox(height: 20),

            // Notifikasi Penting
            Text(
              'Notifikasi Penting',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: lowStockItems.isNotEmpty
                      ? Colors.red.shade50
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: lowStockItems.isNotEmpty
                      ? Border.all(color: Colors.red.shade200, width: 1)
                      : null,
                ),
                child: lowStockItems.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${lowStockItems.length} barang memiliki stok rendah:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          ...lowStockItems
                              .map((item) => Text(
                                    '${item.nama} (${item.kuantitas} ${item.unit})',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ))
                              .toList(),
                        ],
                      )
                    : Text(
                        'Tidak ada notifikasi stok rendah.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Transaksi Terbaru
            Text(
              'Transaksi Terbaru',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            latestTransactions.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: latestTransactions.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> trx = latestTransactions[index];
                      final _PlaceholderItem? item = getBarangById(trx['barangId'] as String);
                      final bool isMasuk = trx['tipe'] == 'masuk';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item?.nama ?? 'Barang Tidak Ditemukan',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${trx['tanggal']} - ${trx['catatan']}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Text(
                                '${isMasuk ? '+' : '-'}${trx['jumlah']}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isMasuk ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Belum ada transaksi terbaru.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
