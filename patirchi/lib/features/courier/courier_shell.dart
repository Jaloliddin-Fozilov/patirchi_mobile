import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/empty_state.dart';
import 'package:patirchi/features/profile/presentation/screens/profile_screen.dart';

class CourierShell extends StatefulWidget {
  const CourierShell({super.key});

  @override
  State<CourierShell> createState() => _CourierShellState();
}

class _CourierShellState extends State<CourierShell> {
  int _currentIndex = 0;

  final _screens = const [
    _DeliveriesPlaceholder(),
    _WalletPlaceholder(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yetkazuvchi'),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining), label: 'Buyurtmalar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Hamyon'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

class _DeliveriesPlaceholder extends StatelessWidget {
  const _DeliveriesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.delivery_dining,
      title: 'Hozircha buyurtmalar yo\'q',
      subtitle: 'Yangi buyurtmalar tushganda bu yerda ko\'rinadi',
    );
  }
}

class _WalletPlaceholder extends StatelessWidget {
  const _WalletPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('Bugungi daromad',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('0 so\'m',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
              ],
            ),
            child: const Column(
              children: [
                Text('Oylik daromad',
                    style: TextStyle(color: AppColors.textSecondary)),
                SizedBox(height: 8),
                Text('0 so\'m',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
