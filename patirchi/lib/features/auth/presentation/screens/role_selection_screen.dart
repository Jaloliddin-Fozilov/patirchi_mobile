import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_tap_detector.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _roles = UserRole.values;

  final _roleIcons = {
    UserRole.buyer: Icons.shopping_bag_outlined,
    UserRole.bakery: Icons.local_fire_department,
    UserRole.courier: Icons.delivery_dining,
    UserRole.supplier: Icons.warehouse_outlined,
  };

  final _roleColors = {
    UserRole.buyer: const Color(0xFFFFE0B2),
    UserRole.bakery: const Color(0xFFFFCCBC),
    UserRole.courier: const Color(0xFFC8E6C9),
    UserRole.supplier: const Color(0xFFBBDEFB),
  };

  final _roleFeatures = {
    UserRole.buyer: [
      'Yaqin nonvoyxonalarni toping',
      'Narxlarni solishtiring',
      'Onlayn buyurtma bering',
      'Yetkazishni kuzating',
    ],
    UserRole.bakery: [
      'Buyurtmalarni boshqaring',
      'Menyuni yangilang',
      'Omborni nazorat qiling',
      'Statistika',
    ],
    UserRole.courier: [
      'Buyurtmalarni yetkazing',
      'Marshrutni ko\'ring',
      'Daromadni kuzating',
      'Qabulni tasdiqlang',
    ],
    UserRole.supplier: [
      'Un va xom ashyo soting',
      'Narxlarni belgilang',
      'Buyurtmalarni boshqaring',
      'Analitika',
    ],
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const DevTapDetector(child: Text('Patirchi')),
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.bakery_dining, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                return _RoleCard(
                  role: role,
                  icon: _roleIcons[role]!,
                  bgColor: _roleColors[role]!,
                  features: _roleFeatures[role]!,
                );
              },
            ),
          ),
          // Page indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _roles.length,
                (i) => Container(
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Orqaga'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _roles.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // Onboarding yakunlangach foydalanuvchi har doim
                        // "Xaridor" (ordinary) sifatida tizimga kiradi.
                        // Kerak bo'lsa profil ekranidan rol almashtirishi mumkin.
                        final auth = context.read<AuthProvider>();
                        auth.selectRole('ordinary');
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                    child: Text(
                      _currentPage == _roles.length - 1
                          ? 'Davom etish'
                          : 'Keyingi',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final Color bgColor;
  final List<String> features;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.bgColor,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            role.label,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 100, color: AppColors.primary.withValues(alpha: 0.6)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            role.label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(f, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
