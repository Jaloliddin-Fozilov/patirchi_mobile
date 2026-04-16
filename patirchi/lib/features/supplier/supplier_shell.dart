import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/app_sidebar.dart';
import 'package:patirchi/features/profile/presentation/screens/profile_screen.dart';
import 'package:patirchi/features/profile/presentation/screens/settings_screen.dart';
import 'package:patirchi/features/supplier/orders/presentation/providers/supplier_orders_provider.dart';
import 'package:patirchi/features/supplier/products/presentation/providers/supplier_products_provider.dart';
import 'package:patirchi/features/supplier/products/presentation/screens/supplier_products_screen.dart';
import 'package:patirchi/features/supplier/orders/presentation/screens/supplier_orders_screen.dart';
import 'package:patirchi/features/supplier/stats/presentation/screens/supplier_stats_screen.dart';
import 'package:patirchi/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:provider/provider.dart';

class SupplierShell extends StatefulWidget {
  const SupplierShell({super.key});

  @override
  State<SupplierShell> createState() => _SupplierShellState();
}

class _SupplierShellState extends State<SupplierShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ilk yuklanishda API dan ma'lumotlarni olish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProductsProvider>().init();
      context.read<SupplierOrdersProvider>().loadOrders();
    });
  }

  String _appBarTitle(int index) {
    const titles = ["Mahsulotlar", "Buyurtmalar", "Statistika", "Chat", "Profil"];
    return titles[index];
  }

  final _screens = const [
    SupplierProductsScreen(),
    SupplierOrdersScreen(),
    SupplierStatsScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.supplierAccent,
        foregroundColor: Colors.white,
        title: Text(_appBarTitle(_currentIndex)),
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
                  }),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                  child: const Text('2',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppSidebar(
        title: "Ta'minotchi",
        gradientColor: AppColors.supplierAccent,
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
            icon: Icons.account_balance_wallet,
            title: 'Moliya',
            children: [
              SidebarMenuItem(
                icon: Icons.trending_up,
                title: 'Daromad',
                onTap: () => _navigateTo(2),
              ),
              SidebarMenuItem(
                icon: Icons.trending_down,
                title: 'Xarajat',
                onTap: () => _navigateTo(2),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.supplierAccent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Bozor'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Buyurtma'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Statistika'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: true,
              smallSize: 8,
              child: Icon(Icons.chat_bubble_outline),
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  void _navigateTo(int index) {
    Navigator.pop(context);
    setState(() => _currentIndex = index);
  }
}
