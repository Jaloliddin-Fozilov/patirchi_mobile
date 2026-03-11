import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/app_sidebar.dart';
import 'package:patirchi/features/profile/presentation/screens/profile_screen.dart';
import 'dashboard/presentation/screens/bakery_dashboard_screen.dart';
import 'orders/presentation/screens/bakery_orders_screen.dart';

class BakeryShell extends StatefulWidget {
  const BakeryShell({super.key});

  @override
  State<BakeryShell> createState() => _BakeryShellState();
}

class _BakeryShellState extends State<BakeryShell> {
  int _currentIndex = 1; // Start on orders

  final _screens = [
    const Center(child: Text('Bozor - Ta\'minotchi mahsulotlari')),
    const BakeryOrdersScreen(),
    const BakeryDashboardScreen(),
    const Center(child: Text('Chat')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bakeryAccent,
        title: const Text('Nonvoy'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          Stack(
            children: [
              IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {}),
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
        title: 'Nonvoy',
        gradientColor: AppColors.bakeryAccent,
        items: [
          SidebarMenuItem(
            icon: Icons.storefront,
            title: "Do'konlar",
            children: [
              SidebarMenuItem(
                  icon: Icons.list, title: "Do'konlar ro'yxati", onTap: () {}),
              SidebarMenuItem(
                  icon: Icons.add, title: "Do'kon qo'shish", onTap: () {}),
            ],
          ),
          SidebarMenuItem(
            icon: Icons.receipt_long,
            title: 'Buyurtmalar',
            children: [
              SidebarMenuItem(
                  icon: Icons.inbox, title: 'Kiruvchi', onTap: () {}),
              SidebarMenuItem(
                  icon: Icons.outbox, title: 'Chiquvchi', onTap: () {}),
            ],
          ),
          SidebarMenuItem(
            icon: Icons.warehouse,
            title: 'Ombor',
            children: [
              SidebarMenuItem(
                  icon: Icons.inventory, title: 'Mahsulotlar', onTap: () {}),
              SidebarMenuItem(
                  icon: Icons.shopping_cart,
                  title: 'Xomashyo buyurtma',
                  onTap: () {}),
            ],
          ),
          SidebarMenuItem(
            icon: Icons.account_balance_wallet,
            title: 'Moliya',
            children: [
              SidebarMenuItem(
                  icon: Icons.trending_up, title: 'Daromad', onTap: () {}),
              SidebarMenuItem(
                  icon: Icons.trending_down, title: 'Xarajat', onTap: () {}),
            ],
          ),
          SidebarMenuItem(
              icon: Icons.work_outline, title: 'Vakansiya', onTap: () {}),
          SidebarMenuItem(
              icon: Icons.bar_chart, title: 'Statistika', onTap: () {}),
          SidebarMenuItem(
              icon: Icons.people_outline, title: 'Referal', onTap: () {}),
          SidebarMenuItem(
              icon: Icons.settings, title: 'Sozlamalar', onTap: () {}),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.bakeryAccent,
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
}
