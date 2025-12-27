import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import 'package:flutter_inventory_app/features/transaction/pages/transaction_form_page.dart';
import 'package:flutter_inventory_app/features/item/pages/item_form_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/features/auth/providers/session_controller.dart';
import 'package:flutter_inventory_app/features/home/home_page.dart';
import 'package:flutter_inventory_app/presentation/pages/activity_log_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/category_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/item_list_page.dart';
import 'package:flutter_inventory_app/presentation/pages/report_page.dart';
import 'package:flutter_inventory_app/features/transaction/pages/transaction_list_page.dart';
import 'package:flutter_inventory_app/features/subscription/pages/subscription_page.dart';
import 'package:flutter_inventory_app/presentation/pages/settings_page.dart';
import 'package:upgrader/upgrader.dart';

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

  Widget build(BuildContext context) {
    // Correctly watch the new session controller for user data
    final userAsync = ref.watch(sessionControllerProvider);
    final user = userAsync.value;

    // Derive premium status and email from the user object, with robust parsing.
    final dynamic premiumValue = user?.prefs.data['isPremium'];
    bool isPremium = false; // Default to false
    if (premiumValue is bool) {
      isPremium = premiumValue;
    } else if (premiumValue is String) {
      isPremium = premiumValue.toLowerCase() == 'true';
    }
    final userEmail = user?.email ?? '';

    const goldColor = Color(0xFFFFD700);
    
    const neubrutalismAccent = Color(0xFFE84A5F);
    const neubrutalismBorder = Colors.black;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true, 
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          // Fix: Explicitly set text style for visibility
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF9F9F9),
        foregroundColor: Colors.black, // This sets icon color
        elevation: 0,
        // Fix: Remove the actions block. AppBar will automatically add a menu icon
        // for the drawer on the left.
        actions: const [],
      ),
      // Fix: Move the Drawer to the 'drawer' property to place it on the left
      drawer: Drawer(
        backgroundColor: const Color(0xFFF9F9F9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            NeuContainer(
              color: const Color(0xFFBDBDBD), // A neutral color
              borderRadius: BorderRadius.zero,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inventarisku',
                        style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (user != null)
                        Text(
                          userEmail,
                          style: const TextStyle(
                                color: Colors.black54,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Menu Items
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildDrawerItem( // This is the premium item
                    icon: Icons.workspace_premium,
                    text: isPremium ? 'Akun Premium' : 'Upgrade ke Premium',
                    buttonColor: isPremium ? goldColor.withAlpha(50) : Colors.white,
                    textColor: isPremium ? goldColor : Colors.black,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.home,
                    text: _pageTitles[0],
                    onTap: () {
                      _onItemTapped(0);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.inventory_2,
                    text: _pageTitles[1],
                    onTap: () {
                      _onItemTapped(1);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.swap_horiz_sharp,
                    text: _pageTitles[2],
                    onTap: () {
                      _onItemTapped(2);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.category,
                    text: _pageTitles[3],
                    onTap: () {
                      _onItemTapped(3);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.assessment,
                    text: _pageTitles[4],
                    onTap: () {
                      _onItemTapped(4);
                      Navigator.pop(context);
                    },
                  ),
                   _buildDrawerItem(
                    icon: Icons.history,
                    text: 'Aktivitas',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ActivityLogListPage()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    text: 'Pengaturan',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: NeuContainer(
                      height: 3,
                      width: double.infinity,
                      color: Colors.black,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    text: 'Logout',
                    buttonColor: neubrutalismAccent.withAlpha(50),
                    textColor: neubrutalismAccent,
                    onTap: () {
                      ref.read(sessionControllerProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: UpgradeAlert(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
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

  // Helper method for Neubrutalism Drawer items
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? buttonColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: NeuContainer(
        color: buttonColor ?? Colors.white,
        borderColor: Colors.black,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(8),
        offset: const Offset(3, 3),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: textColor ?? Colors.black),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor ?? Colors.black,
                    ),
                  ),
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
        return null;
      case 2: // Transaksi
        return null;
      case 3: // Kategori (removed in last working version)
      default:
        return null;
    }
  }
}