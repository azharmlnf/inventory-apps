import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:flutter_inventory_app/features/transaction/pages/transaction_form_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_form_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/auth_state_provider.dart';
import 'package:flutter_inventory_app/features/home/home_page.dart';
import 'package:flutter_inventory_app/presentation/pages/activity_log_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/category_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/report_page.dart';
import 'package:flutter_inventory_app/features/transaction/pages/transaction_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/premium_page.dart'; // New import for PremiumPage

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
    final authState = ref.watch(authControllerProvider);
    final isPremium = authState.isPremium;
    const goldColor = Color(0xFFFFD700);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    const neubrutalismAccent = Color(0xFFE84A5F);
    const neubrutalismBorder = Colors.black;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true, 
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Inventarisku',
                    style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (authState.user != null && authState.user!.email != null)
                    Text(
                      authState.user!.email!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.history, color: colorScheme.secondary),
              title: Text('Aktivitas', style: theme.textTheme.titleMedium),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityLogListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: colorScheme.secondary),
              title: Text('Pengaturan', style: theme.textTheme.titleMedium),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.workspace_premium,
                color: isPremium ? goldColor : colorScheme.secondary,
              ),
              title: Text(
                isPremium ? 'Akun Premium' : 'Upgrade ke Premium',
                style: theme.textTheme.titleMedium?.copyWith(
                      color: isPremium ? goldColor : null,
                      fontWeight: isPremium ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (!isPremium) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PremiumPage()),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text('Logout', style: theme.textTheme.titleMedium),
              onTap: () {
                Navigator.pop(context);
                ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: NeuContainer(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNeuNavItem(
                  selectedIcon: Icons.home,
                  unselectedIcon: Icons.home_outlined,
                  index: 0,
                  accentColor: neubrutalismAccent,
                  borderColor: neubrutalismBorder,
                ),
                _buildNeuNavItem(
                  selectedIcon: Icons.inventory_2,
                  unselectedIcon: Icons.inventory_2_outlined,
                  index: 1,
                  accentColor: neubrutalismAccent,
                  borderColor: neubrutalismBorder,
                ),
                _buildNeuNavItem(
                  selectedIcon: Icons.swap_horiz_sharp,
                  unselectedIcon: Icons.swap_horiz,
                  index: 2,
                  accentColor: neubrutalismAccent,
                  borderColor: neubrutalismBorder,
                ),
                _buildNeuNavItem(
                  selectedIcon: Icons.category,
                  unselectedIcon: Icons.category_outlined,
                  index: 3,
                  accentColor: neubrutalismAccent,
                  borderColor: neubrutalismBorder,
                ),
                _buildNeuNavItem(
                  selectedIcon: Icons.assessment,
                  unselectedIcon: Icons.assessment_outlined,
                  index: 4,
                  accentColor: neubrutalismAccent,
                  borderColor: neubrutalismBorder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeuNavItem({
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required int index,
    required Color accentColor,
    required Color borderColor,
  }) {
    final bool isSelected = _selectedIndex == index;
    return NeuIconButton(
      enableAnimation: true,
      onPressed: () => _onItemTapped(index),
      buttonColor: isSelected ? accentColor : Colors.white,
      shadowColor: borderColor,
      borderColor: borderColor,
      buttonHeight: 60,
      buttonWidth: 60,
      icon: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        color: isSelected ? Colors.white : borderColor,
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
        return null;
      default:
        return null;
    }
  }
}
