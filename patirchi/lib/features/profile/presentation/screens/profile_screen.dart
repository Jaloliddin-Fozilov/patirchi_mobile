import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/features/auth/presentation/providers/auth_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final cardColor = isDark ? AppColors.cardBgDark : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- TOP HEADER ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        // Logo
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.bakery_dining,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Patirchi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        _HeaderIcon(
                          icon: Icons.sync_rounded,
                          color: textColor,
                          onTap: () {},
                        ),
                        const SizedBox(width: 4),
                        // Notification bell with badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _HeaderIcon(
                              icon: Icons.notifications_none_rounded,
                              color: textColor,
                              onTap: () {},
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- AVATAR + BADGES ROW ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        // Badge icons
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              // Coffee / bakery badge
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.coffee_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Progress badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: CircularProgressIndicator(
                                      value: 0.72,
                                      strokeWidth: 5,
                                      backgroundColor: isDark
                                          ? AppColors.surfaceDark
                                          : Colors.grey.shade200,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppColors.info,
                                      ),
                                    ),
                                  ),
                                  const Positioned.fill(
                                    child: Center(
                                      child: Icon(
                                        Icons.circle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.info,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Text(
                                        '1',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --- NAME ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        user?.name ?? 'Demo User',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- STATS ROW ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          value: '0',
                          label: 'Obunachilar',
                          textColor: textColor,
                          secondaryColor: secondaryText,
                        ),
                        _StatItem(
                          value: '0',
                          label: 'Obunalar',
                          textColor: textColor,
                          secondaryColor: secondaryText,
                        ),
                        _StatItem(
                          value: '10',
                          label: 'Qarashlar',
                          textColor: textColor,
                          secondaryColor: secondaryText,
                        ),
                        _StatItemWithIcon(
                          value: '2/13',
                          label: 'Erishmalar',
                          icon: Icons.emoji_events_rounded,
                          iconColor: AppColors.warning,
                          textColor: textColor,
                          secondaryColor: secondaryText,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- ACTION BUTTONS ROW ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Nashr qilish button
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textColor,
                                side: BorderSide(
                                  color: isDark
                                      ? AppColors.dividerDark
                                      : AppColors.divider,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Nashr qilish',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Share button
                        _ActionIconButton(
                          icon: Icons.share_outlined,
                          isDark: isDark,
                          onTap: () {},
                        ),
                        const SizedBox(width: 10),
                        // Settings button
                        _ActionIconButton(
                          icon: Icons.settings_outlined,
                          isDark: isDark,
                          onTap: () {
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
                  ),

                  const SizedBox(height: 20),

                  // --- ROLE SWITCHER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
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
                              _RoleTile(
                                icon: Icons.person_rounded,
                                label: 'Xaridor',
                                sublabel: 'Asosiy',
                                color: AppColors.primary,
                                bgColor: AppColors.primary.withValues(alpha: 0.1),
                                isActive:
                                    auth.selectedRole == UserRole.buyer,
                                isDark: isDark,
                                onTap: () =>
                                    _switchRole(context, auth, UserRole.buyer),
                              ),
                              const SizedBox(width: 8),
                              _RoleTile(
                                icon: Icons.storefront_rounded,
                                label: "Do'konim",
                                sublabel: "Do'kon",
                                color: AppColors.bakeryAccent,
                                bgColor: AppColors.bakeryAccent.withValues(alpha: 0.1),
                                isActive:
                                    auth.selectedRole == UserRole.bakery,
                                isDark: isDark,
                                onTap: () =>
                                    _switchRole(context, auth, UserRole.bakery),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _RoleTile(
                                icon: Icons.delivery_dining_rounded,
                                label: 'Yetkazuvchi',
                                sublabel: 'Kuryer',
                                color: AppColors.success,
                                bgColor: AppColors.success.withValues(alpha: 0.1),
                                isActive:
                                    auth.selectedRole == UserRole.courier,
                                isDark: isDark,
                                onTap: () => _switchRole(
                                    context, auth, UserRole.courier),
                              ),
                              const SizedBox(width: 8),
                              _RoleTile(
                                icon: Icons.local_shipping_rounded,
                                label: "Ta'minotchi",
                                sublabel: "Ta'minot",
                                color: AppColors.supplierAccent,
                                bgColor:
                                    AppColors.supplierAccent.withValues(alpha: 0.1),
                                isActive:
                                    auth.selectedRole == UserRole.supplier,
                                isDark: isDark,
                                onTap: () => _switchRole(
                                    context, auth, UserRole.supplier),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- USER INFO TILES ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
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
                          _InfoTile(
                            icon: Icons.phone_outlined,
                            text: user?.phone ?? '+998951112233',
                            textColor: textColor,
                            iconColor: secondaryText,
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.dividerDark
                                : const Color(0xFFF0F0F0),
                            height: 20,
                          ),
                          _InfoTile(
                            icon: Icons.person_outline_rounded,
                            text: user?.name ?? 'demo',
                            textColor: textColor,
                            iconColor: secondaryText,
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.dividerDark
                                : const Color(0xFFF0F0F0),
                            height: 20,
                          ),
                          _InfoTile(
                            icon: Icons.groups_outlined,
                            text: 'Oddiy foydalanuvchi',
                            textColor: textColor,
                            iconColor: secondaryText,
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.dividerDark
                                : const Color(0xFFF0F0F0),
                            height: 20,
                          ),
                          _InfoTile(
                            icon: Icons.calendar_today_outlined,
                            text: "24 Fev 2026 dan beri a'zo",
                            textColor: textColor,
                            iconColor: secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- DELIVERY ADDRESS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yetkazib berish manzili',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Test data 103909 Witamer CR, Niagara Falls, NY 14305 USA',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryText,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
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

// --- PRIVATE WIDGETS ---

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 24),
      onPressed: onTap,
      splashRadius: 20,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color textColor;
  final Color secondaryColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatItemWithIcon extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color secondaryColor;

  const _StatItemWithIcon({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final Color bgColor;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleTile({
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
            border: isActive
                ? Border.all(color: color, width: 1.5)
                : null,
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textColor;
  final Color iconColor;

  const _InfoTile({
    required this.icon,
    required this.text,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}