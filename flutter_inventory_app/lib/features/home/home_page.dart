import 'package:flutter_inventory_app/presentation/pages/category_list_page.dart';
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
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[800],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventarisku',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (currentUser != null)
                    Text(
                      currentUser.email,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Already on dashboard, no action needed
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Barang'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Barang page
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kategori'),
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
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Transaksi'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Transaksi page
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Laporan'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Laporan page
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Aktivitas'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Riwayat Aktivitas page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Pengaturan page
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
                    'Total Jenis Barang', totalJenisBarang.toString()),
                _buildSummaryCard(
                    'Stok Akan Habis', stokAkanHabis.toString()),
                _buildSummaryCard(
                    'Transaksi Hari Ini', transaksiHariIni.toString()),
              ],
            ),
            const SizedBox(height: 20),

            // Notifikasi Penting
            Text(
              'Notifikasi Penting',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                border: lowStockItems.isNotEmpty
                    ? Border.all(color: Colors.red, width: 2)
                    : Border.all(color: Colors.grey, style: BorderStyle.solid),
                color: lowStockItems.isNotEmpty
                    ? Colors.red.withAlpha((255 * 0.1).round())
                    : Colors.grey[50],
              ),
              child: lowStockItems.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lowStockItems.length} barang memiliki stok rendah:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        ...lowStockItems
                            .map((item) => Text('${item.nama} (${item.kuantitas} ${item.unit})'))
                            .toList(),
                      ],
                    )
                  : const Text('Tidak ada notifikasi stok rendah.'),
            ),
            const SizedBox(height: 20),

            // Transaksi Terbaru
            Text(
              'Transaksi Terbaru',
              style: Theme.of(context).textTheme.headlineSmall,
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
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item?.nama ?? 'Barang Tidak Ditemukan',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('${trx['tanggal']} - ${trx['catatan']}'),
                                ],
                              ),
                              Text(
                                '${isMasuk ? '+' : '-'}${trx['jumlah']}',
                                style: TextStyle(
                                  color: isMasuk ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                      color: Colors.grey[50],
                    ),
                    child: const Text('Belum ada transaksi terbaru.'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
