import 'package:flutter/material.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/features/auth/presentation/providers/auth_provider.dart';

class RoleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final Color bgColor;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const RoleTile({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.bgColor,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? bgColor
                : (isDark ? AppColors.surfaceDark : const Color(0xFFFAF5F0)),
            borderRadius: BorderRadius.circular(14),
            border: isActive ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withValues(alpha: 0.15)
                      : (isDark
                          ? AppColors.cardBgDark
                          : Colors.white.withValues(alpha: 0.8)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sublabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleSwitcher extends StatelessWidget {
  final AuthProvider auth;
  final bool isDark;
  final Color cardColor;
  final void Function(BuildContext, AuthProvider, UserRole) onSwitch;

  const RoleSwitcher({
    super.key,
    required this.auth,
    required this.isDark,
    required this.cardColor,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              RoleTile(
                icon: Icons.person_rounded,
                label: 'Xaridor',
                sublabel: 'Asosiy',
                color: AppColors.primary,
                bgColor: AppColors.primary.withValues(alpha: 0.1),
                isActive: auth.currentUserRole == UserRole.buyer,
                isDark: isDark,
                onTap: () => onSwitch(context, auth, UserRole.buyer),
              ),
              const SizedBox(width: 8),
              RoleTile(
                icon: Icons.storefront_rounded,
                label: "Do'konim",
                sublabel: "Do'kon",
                color: AppColors.bakeryAccent,
                bgColor: AppColors.bakeryAccent.withValues(alpha: 0.1),
                isActive: auth.currentUserRole == UserRole.bakery,
                isDark: isDark,
                onTap: () => onSwitch(context, auth, UserRole.bakery),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              RoleTile(
                icon: Icons.delivery_dining_rounded,
                label: 'Yetkazuvchi',
                sublabel: 'Kuryer',
                color: AppColors.success,
                bgColor: AppColors.success.withValues(alpha: 0.1),
                isActive: auth.currentUserRole == UserRole.courier,
                isDark: isDark,
                onTap: () => onSwitch(context, auth, UserRole.courier),
              ),
              const SizedBox(width: 8),
              RoleTile(
                icon: Icons.local_shipping_rounded,
                label: "Ta'minotchi",
                sublabel: "Ta'minot",
                color: AppColors.supplierAccent,
                bgColor: AppColors.supplierAccent.withValues(alpha: 0.1),
                isActive: auth.currentUserRole == UserRole.supplier,
                isDark: isDark,
                onTap: () => onSwitch(context, auth, UserRole.supplier),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
