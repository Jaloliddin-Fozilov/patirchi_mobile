import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Demo User',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem('0', 'Obunachilar'),
                  _StatItem('0', 'Obunalar'),
                  _StatItem('10', 'Qarashlar'),
                  _StatItem('2/13', 'Erishmalar'),
                ],
              ),
              const SizedBox(height: 20),
              // Role switcher
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _RoleTile(
                          role: UserRole.buyer,
                          icon: Icons.shopping_bag,
                          label: 'Xaridor',
                          sublabel: 'Asosiy',
                          color: AppColors.primary,
                          isActive: auth.selectedRole == UserRole.buyer,
                          onTap: () => _switchRole(context, auth, UserRole.buyer),
                        ),
                        _RoleTile(
                          role: UserRole.bakery,
                          icon: Icons.storefront,
                          label: "Do'konim",
                          sublabel: "Do'kon",
                          color: AppColors.bakeryAccent,
                          isActive: auth.selectedRole == UserRole.bakery,
                          onTap: () => _switchRole(context, auth, UserRole.bakery),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _RoleTile(
                          role: UserRole.courier,
                          icon: Icons.delivery_dining,
                          label: 'Yetkazuvchi',
                          sublabel: 'Kuryer',
                          color: AppColors.success,
                          isActive: auth.selectedRole == UserRole.courier,
                          onTap: () => _switchRole(context, auth, UserRole.courier),
                        ),
                        _RoleTile(
                          role: UserRole.supplier,
                          icon: Icons.local_shipping,
                          label: "Ta'minotchi",
                          sublabel: "Ta'minot",
                          color: AppColors.supplierAccent,
                          isActive: auth.selectedRole == UserRole.supplier,
                          onTap: () => _switchRole(context, auth, UserRole.supplier),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Info
              _InfoTile(Icons.phone, user?.phone ?? '+998951112233'),
              _InfoTile(Icons.person_outline, user?.name ?? 'demo'),
              _InfoTile(Icons.calendar_today, '24 Fev 2026 dan beri a\'zo'),
              const SizedBox(height: 16),
              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    auth.logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/role-selection', (_) => false);
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Chiqish',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _switchRole(BuildContext context, AuthProvider auth, UserRole role) {
    auth.switchRole(role);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _RoleTile({
    required this.role,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.1) : AppColors.warmBgLight,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTile(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
