import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/features/auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/role_switcher.dart';
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
                        ProfileHeaderIcon(
                          icon: Icons.sync_rounded,
                          color: textColor,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Ma'lumotlar yangilandi")),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        // Notification bell with badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ProfileHeaderIcon(
                              icon: Icons.notifications_none_rounded,
                              color: textColor,
                              onTap: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
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
                        user?.fullName ?? 'Demo User',
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
                        ProfileStatItem(
                          value: '0',
                          label: 'Obunachilar',
                          textColor: textColor,
                          secondaryColor: secondaryText,
                        ),
                        ProfileStatItem(
                          value: '0',
                          label: 'Obunalar',
                          textColor: textColor,
                          secondaryColor: secondaryText,
                        ),
                        ProfileStatItem(
                          value: '10',
                          label: 'Qarashlar',
                          textColor: textColor,
                          secondaryColor: secondaryText,
                        ),
                        ProfileStatItemWithIcon(
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
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Nashr qilish tez kunda')),
                                );
                              },
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
                        ProfileActionIconButton(
                          icon: Icons.share_outlined,
                          isDark: isDark,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profilni ulashish tez kunda')),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        // Settings button
                        ProfileActionIconButton(
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
                    child: RoleSwitcher(
                      auth: auth,
                      isDark: isDark,
                      cardColor: cardColor,
                      onSwitch: _switchRole,
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
                          ProfileInfoTile(
                            icon: Icons.phone_outlined,
                            text: user?.phoneNumber ?? '+998951112233',
                            textColor: textColor,
                            iconColor: secondaryText,
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.dividerDark
                                : const Color(0xFFF0F0F0),
                            height: 20,
                          ),
                          ProfileInfoTile(
                            icon: Icons.person_outline_rounded,
                            text: user?.fullName ?? 'demo',
                            textColor: textColor,
                            iconColor: secondaryText,
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.dividerDark
                                : const Color(0xFFF0F0F0),
                            height: 20,
                          ),
                          ProfileInfoTile(
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
                          ProfileInfoTile(
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
