import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/features/buyer/cart/presentation/providers/cart_provider.dart';
import 'home/presentation/screens/buyer_home_screen.dart';
import 'catalog/presentation/screens/catalog_screen.dart';
import 'cart/presentation/screens/cart_screen.dart';
import 'wishlist/presentation/screens/wishlist_screen.dart';
import 'package:patirchi/features/profile/presentation/screens/profile_screen.dart';

class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int _currentIndex = 0;

  final _screens = const [
    BuyerHomeScreen(),
    CatalogScreen(),
    CartScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return Container(
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Bozor',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.phone_in_talk_rounded,
                  label: 'Aloqa',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Savat',
                  index: 2,
                  badgeCount: cart.itemCount,
                ),
                _buildNavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Sevimli',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  index: 4,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF808080),
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFF808080),
              ),
            ),
          ],
        ),
      ),
    );
  }
}