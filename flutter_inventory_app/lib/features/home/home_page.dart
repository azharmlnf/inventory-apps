import 'package:flutter_inventory_app/features/transaction/pages/transaction_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/activity_log_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/category_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/home/providers/dashboard_providers.dart';
import 'package:flutter_inventory_app/data/models/transaction.dart';
import 'package:intl/intl.dart'; // For date formatting

// Import providers yang diperlukan untuk refresh
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_log_providers.dart';


class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.user;

    // Watch dashboard providers
    final totalJenisBarangAsync = ref.watch(totalItemsCountProvider);
    final lowStockItemsAsync = ref.watch(lowStockItemsProvider);
    final transactionsTodayAsync = ref.watch(transactionsTodayProvider);
    final latestTransactionsAsync = ref.watch(latestTransactionsProvider);

    // Listen for auth state changes to refresh data
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.user == null && next.user != null) {
        // User logged in, refresh all data
        ref.invalidate(itemsProvider);
        ref.invalidate(categoriesProvider);
        ref.invalidate(transactionsProvider);
        ref.invalidate(activityLogsProvider);
      } else if (previous?.user != null && next.user == null) {
        // User logged out, clear data (optional, providers will handle this)
      }
    });

    // Initial data refresh when the widget is first built or dependencies change
    // This ensures data is fresh when navigating back to the dashboard
    ref.watch(itemsProvider.notifier).refreshItems();
    ref.watch(categoriesProvider.notifier).refreshCategories();
    ref.watch(transactionsProvider.notifier).refreshTransactions();
    ref.watch(activityLogsProvider.notifier).refreshActivityLogs();


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
                // Already on dashboard, no action needed, data is refreshed by ref.watch above
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: Theme.of(context).colorScheme.primary),
              title: Text('Barang', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ref.invalidate(itemsProvider); // Invalidate to force refresh on next access
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
                ref.invalidate(categoriesProvider); // Invalidate to force refresh on next access
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
                ref.invalidate(transactionsProvider); // Invalidate to force refresh on next access
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
                ref.invalidate(activityLogsProvider); // Invalidate to force refresh on next access
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
                totalJenisBarangAsync.when(
                  data: (count) => _buildSummaryCard(
                      'Total Jenis Barang', count.toString(), Icons.category, Colors.blue.shade700),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                ),
                lowStockItemsAsync.when(
                  data: (items) => _buildSummaryCard(
                      'Stok Akan Habis', items.length.toString(), Icons.warning_amber, Colors.orange.shade700),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                ),
                transactionsTodayAsync.when(
                  data: (transactions) => _buildSummaryCard(
                      'Transaksi Hari Ini', transactions.length.toString(), Icons.swap_horiz, Colors.green.shade700),
                  loading: () => _buildLoadingCard(),
                  error: (err, stack) => _buildErrorCard('Error: ${err.toString()}'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notifikasi Penting (Stok Rendah)
            Text(
              'Notifikasi Penting',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            lowStockItemsAsync.when(
              data: (lowStockItems) {
                return Card(
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
                                        '${item.name} (${item.quantity} ${item.unit})',
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
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: ${err.toString()}'),
            ),
            const SizedBox(height: 20),

            // Transaksi Terbaru
            Text(
              'Transaksi Terbaru',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            latestTransactionsAsync.when(
              data: (latestTransactions) {
                return latestTransactions.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: latestTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = latestTransactions[index];
                          final isMasuk = transaction.type == TransactionType.IN;

                          // Watch item details for the transaction
                          final itemAsync = ref.watch(itemByIdProvider(transaction.itemId));

                          return itemAsync.when(
                            data: (item) {
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
                                            item?.name ?? 'Barang Tidak Ditemukan',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)} - ${transaction.note}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${isMasuk ? '+' : '-'}${transaction.quantity}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: isMasuk ? Colors.green.shade700 : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, stack) => Text('Error: ${err.toString()}'),
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
                      );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: ${err.toString()}'),
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

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
