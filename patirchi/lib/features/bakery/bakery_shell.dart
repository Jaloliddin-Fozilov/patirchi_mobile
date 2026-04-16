import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/app_sidebar.dart';
import 'package:patirchi/features/bakery/menu/presentation/providers/menu_provider.dart';
import 'package:patirchi/features/bakery/orders/presentation/providers/bakery_orders_provider.dart';
import 'package:patirchi/features/profile/presentation/screens/profile_screen.dart';
import 'package:patirchi/features/profile/presentation/screens/settings_screen.dart';
import 'package:patirchi/features/chat/presentation/providers/chat_provider.dart';
import 'package:patirchi/features/chat/presentation/screens/chat_list_screen.dart';
import 'dashboard/presentation/screens/bakery_dashboard_screen.dart';
import 'orders/presentation/screens/bakery_orders_screen.dart';
import 'menu/presentation/screens/menu_list_screen.dart';
import 'inventory/presentation/screens/inventory_screen.dart';
import 'finance/presentation/screens/finance_screen.dart';
import 'marketplace/presentation/screens/bakery_marketplace_screen.dart';
import 'menu/presentation/screens/menu_item_form_screen.dart';

class BakeryShell extends StatefulWidget {
  const BakeryShell({super.key});

  @override
  State<BakeryShell> createState() => _BakeryShellState();
}

class _BakeryShellState extends State<BakeryShell> {
  int _currentIndex = 1; // Start on orders

  @override
  void initState() {
    super.initState();
    // Ilk yuklanishda API dan ma'lumotlarni olish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BakeryOrdersProvider>().loadOrders();
      context.read<MenuProvider>().init();
    });
  }

  static final _screens = [
    const BakeryMarketplaceScreen(),
    const BakeryOrdersScreen(),
    const BakeryDashboardScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bakeryAccent,
        title: const Text('Nonvoy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Do'konni ulashish tez kunda")),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppSidebar(
        title: 'Nonvoy',
        gradientColor: AppColors.bakeryAccent,
        items: [
          SidebarMenuItem(
            icon: Icons.storefront,
            title: "Do'konlar",
            children: [
              SidebarMenuItem(
                icon: Icons.list,
                title: "Do'konlar ro'yxati",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Do'konlar ro'yxati tez kunda")),
                  );
                },
              ),
              SidebarMenuItem(
                icon: Icons.add,
                title: "Do'kon qo'shish",
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Do'kon qo'shish tez kunda")),
                  );
                },
              ),
            ],
          ),
          SidebarMenuItem(
            icon: Icons.receipt_long,
            title: 'Buyurtmalar',
            children: [
              SidebarMenuItem(
                icon: Icons.inbox,
                title: 'Kiruvchi',
                onTap: () => _navigateTo(1),
              ),
              SidebarMenuItem(
                icon: Icons.outbox,
                title: 'Chiquvchi',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Chiquvchi buyurtmalar tez kunda')),
                  );
                },
              ),
            ],
          ),
          SidebarMenuItem(
            icon: Icons.restaurant_menu,
            title: 'Menyu',
            children: [
              SidebarMenuItem(
                icon: Icons.list_alt,
                title: 'Mahsulotlar',
                onTap: () => _showMenuScreen(),
              ),
              SidebarMenuItem(
                icon: Icons.add_circle_outline,
                title: "Yangi mahsulot",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MenuItemFormScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          SidebarMenuItem(
            icon: Icons.warehouse,
            title: 'Ombor',
            children: [
              SidebarMenuItem(
                icon: Icons.inventory,
                title: 'Mahsulotlar',
                onTap: () => _showInventoryScreen(),
              ),
              SidebarMenuItem(
                icon: Icons.shopping_cart,
                title: 'Xomashyo buyurtma',
                onTap: () => _navigateTo(0),
              ),
            ],
          ),
          SidebarMenuItem(
            icon: Icons.account_balance_wallet,
            title: 'Moliya',
            children: [
              SidebarMenuItem(
                icon: Icons.trending_up,
                title: 'Daromad',
                onTap: () => _showFinanceScreen(),
              ),
              SidebarMenuItem(
                icon: Icons.trending_down,
                title: 'Xarajat',
                onTap: () => _showFinanceScreen(),
              ),
            ],
          ),
          SidebarMenuItem(
            icon: Icons.work_outline,
            title: 'Vakansiya',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vakansiyalar tez kunda')),
              );
            },
          ),
          SidebarMenuItem(
            icon: Icons.bar_chart,
            title: 'Statistika',
            onTap: () => _navigateTo(2),
          ),
          SidebarMenuItem(
            icon: Icons.people_outline,
            title: 'Referal',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referal tizimi tez kunda')),
              );
            },
          ),
          SidebarMenuItem(
            icon: Icons.settings,
            title: 'Sozlamalar',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            selectedItemColor: AppColors.bakeryAccent,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.storefront),
                label: 'Bozor',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: 'Buyurtma',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Statistika',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: chatProvider.totalUnreadCount > 0,
                  label: Text('${chatProvider.totalUnreadCount}'),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateTo(int index) {
    Navigator.pop(context); // close drawer
    setState(() => _currentIndex = index);
  }

  void _showMenuScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.bakeryAccent,
            foregroundColor: Colors.white,
            title: const Text('Menyu'),
          ),
          body: const MenuListScreen(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MenuItemFormScreen(),
                ),
              );
            },
            backgroundColor: AppColors.bakeryAccent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text("Mahsulot qo'shish"),
          ),
        ),
      ),
    );
  }

  void _showInventoryScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.bakeryAccent,
            foregroundColor: Colors.white,
            title: const Text('Ombor'),
          ),
          body: const InventoryScreen(),
        ),
      ),
    );
  }

  void _showFinanceScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.bakeryAccent,
            foregroundColor: Colors.white,
            title: const Text('Moliya'),
          ),
          body: const FinanceScreen(),
        ),
      ),
    );
  }
}

