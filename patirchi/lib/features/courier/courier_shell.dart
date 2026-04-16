import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/features/courier/deliveries/presentation/providers/courier_provider.dart';
import 'package:patirchi/features/courier/deliveries/presentation/screens/courier_deliveries_screen.dart';
import 'package:patirchi/features/courier/wallet/presentation/providers/wallet_provider.dart';
import 'package:patirchi/features/courier/wallet/presentation/screens/courier_wallet_screen.dart';
import 'package:patirchi/features/profile/presentation/screens/profile_screen.dart';

class CourierShell extends StatefulWidget {
  const CourierShell({super.key});

  @override
  State<CourierShell> createState() => _CourierShellState();
}

class _CourierShellState extends State<CourierShell> {
  int _currentIndex = 0;

  static const _titles = ['Yetkazuvlar', 'Hamyon', 'Profil'];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourierProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: _CourierShellContent(
        currentIndex: _currentIndex,
        onTabChanged: (i) => setState(() => _currentIndex = i),
        titles: _titles,
      ),
    );
  }
}

class _CourierShellContent extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<String> titles;

  const _CourierShellContent({
    required this.currentIndex,
    required this.onTabChanged,
    required this.titles,
  });

  @override
  State<_CourierShellContent> createState() => _CourierShellContentState();
}

class _CourierShellContentState extends State<_CourierShellContent> {
  @override
  void initState() {
    super.initState();
    // Init both providers after the first frame so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CourierProvider>().init();
      context.read<WalletProvider>().init();
    });
  }

  static const _screens = [
    CourierDeliveriesScreen(),
    CourierWalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final courierProvider = context.watch<CourierProvider>();
    final isOnline = courierProvider.isOnline;
    final isLoading = courierProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(widget.titles[widget.currentIndex]),
        actions: [
          if (widget.currentIndex == 0) ...[
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: courierProvider.toggleOnline,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              isOnline ? Colors.greenAccent : Colors.white38,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? 'Onlayn' : 'Oflayn',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: widget.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabChanged,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Yetkazuvlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Hamyon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
