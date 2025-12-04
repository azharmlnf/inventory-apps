import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/home/home_page.dart';
import 'package:flutter_inventory_app/presentation/pages/activity_log_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/category_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/report_page.dart';
import 'package:flutter_inventory_app/features/transaction/pages/transaction_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_form_page.dart'; // Add this import
import 'package:flutter_inventory_app/features/transaction/pages/transaction_form_page.dart'; // Add this import

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ItemListPage(),
    TransactionListPage(),
    CategoryListPage(),
    ReportPage(),
  ];

  static const List<String> _pageTitles = <String>[
    'Dashboard',
    'Manajemen Barang',
    'Daftar Transaksi',
    'Manajemen Kategori',
    'Laporan',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
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
                      currentUser.email!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
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
                // TODO: Navigate to Pengaturan page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.primary),
              title: Text('Premium', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                // The _buyPremium logic is inside HomePage, this needs to be handled globally or moved.
                // For now, just close the drawer.
                Navigator.pop(context);
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            activeIcon: Icon(Icons.swap_horiz_sharp),
            label: 'Transaksi',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Laporan',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Good for 3-5 items
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    switch (_selectedIndex) {
      case 1: // Barang
        return FloatingActionButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ItemFormPage())),
          child: const Icon(Icons.add),
        );
      case 2: // Transaksi
        return FloatingActionButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TransactionFormPage())),
          child: const Icon(Icons.add),
        );
      case 3: // Kategori
        // The dialog logic is inside CategoryListPage, so we can't call it directly.
        // As a simple solution, we don't show a FAB, user can use the one on the page.
        // A better long-term solution would be to refactor the dialog logic.
        return null;
      default:
        return null;
    }
  }
}
