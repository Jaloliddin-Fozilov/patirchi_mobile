import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/theme/theme_provider.dart';
import 'package:patirchi/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardBgDark : Colors.white;
    final bgColor = isDark ? AppColors.scaffoldBgDark : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.dividerDark : const Color(0xFFEEEEEE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Sozlamalar',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.currentUser;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // User info card
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                      child: Text(
                        (user?.name ?? 'P')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF7C4DFF),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      user?.name ?? 'Foydalanuvchi',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '@Patirchi',
                      style: TextStyle(color: secondaryText, fontSize: 13),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: secondaryText,
                    ),
                    onTap: () {},
                  ),
                ),

                const SizedBox(height: 24),

                // Section header
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'BOSHQA SOZLAMALAR',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                // Settings list
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: "Profil ma'lumotlari",
                        textColor: textColor,
                        iconColor: secondaryText,
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, indent: 56, color: dividerColor),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Parol',
                        textColor: textColor,
                        iconColor: secondaryText,
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, indent: 56, color: dividerColor),
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Bildirishnomalar',
                        textColor: textColor,
                        iconColor: secondaryText,
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, indent: 56, color: dividerColor),
                      // Dark mode toggle
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Tungi rejim',
                            textColor: textColor,
                            iconColor: secondaryText,
                            trailing: Switch.adaptive(
                              value: themeProvider.isDarkMode,
                              onChanged: (_) => themeProvider.toggleTheme(),
                              activeColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // About section
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Ilova haqida',
                        textColor: textColor,
                        iconColor: secondaryText,
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, indent: 56, color: dividerColor),
                      _SettingsTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Yordam / FAQ',
                        textColor: textColor,
                        iconColor: secondaryText,
                        onTap: () {},
                      ),
                      Divider(
                          height: 1, indent: 56, color: dividerColor),
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Tizimdan chiqish',
                        textColor: AppColors.error,
                        iconColor: AppColors.error,
                        showChevron: false,
                        onTap: () {
                          auth.logout();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/role-selection',
                            (_) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color textColor;
  final Color iconColor;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.textColor,
    required this.iconColor,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          (showChevron
              ? Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  size: 22,
                )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
