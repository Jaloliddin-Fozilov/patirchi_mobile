import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/features/buyer/catalog/data/catalog_data.dart';
import '../widgets/catalog_cards.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final searchBg = isDark ? AppColors.surfaceDark : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ═══ HEADER ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
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
                        child: Icon(Icons.bakery_dining,
                            size: 20, color: AppColors.primary),
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
                    IconButton(
                      icon: Icon(Icons.sync_rounded, color: textColor, size: 24),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Ma'lumotlar yangilanmoqda...")),
                        );
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_none_rounded,
                              color: textColor, size: 24),
                          onPressed: () {
                            Navigator.pushNamed(context, '/notifications');
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
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
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ═══ SEARCH BAR ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: searchBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.dividerDark
                                : const Color(0xFFE8E8E8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Qidirish...',
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Icon(Icons.search, color: secondaryText, size: 22),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                  ],
                ),
              ),
            ),

            // ═══ MAIN FOOD CATEGORIES (3-col grid with images) ═══
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate(
                  mainCategories.map((cat) {
                    return ImageCategoryCard(
                      label: cat['label'] as String,
                      imageUrl: cat['imageUrl'] as String?,
                      fallbackIcon: cat['icon'] as IconData,
                      placeholderColor: cat['color'] as Color,
                      isDark: isDark,
                      textColor: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    );
                  }).toList(),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
              ),
            ),

            // ═══ CUISINE TYPES (horizontal scroll with circular images) ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cuisineTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final cuisine = cuisineTypes[index];
                      return CuisineCircle(
                        label: cuisine['label'] as String,
                        imageUrl: cuisine['imageUrl'] as String?,
                        fallbackIcon: cuisine['icon'] as IconData,
                        fallbackColor: cuisine['color'] as Color,
                        textColor: textColor,
                      );
                    },
                  ),
                ),
              ),
            ),

            // ═══ "Kategoriyalar" HEADER ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Kategoriyalar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ),

            // ═══ KATEGORIYALAR GRID (4-col with images) ═══
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = kategoriyalar[index];
                    return KategoriyaImageCard(
                      label: cat['label'] as String,
                      imageUrl: cat['imageUrl'] as String?,
                      fallbackIcon: cat['icon'] as IconData,
                      placeholderColor: cat['color'] as Color,
                      isDark: isDark,
                      overlay:
                          index == kategoriyalar.length - 1 ? '+25' : null,
                    );
                  },
                  childCount: kategoriyalar.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
              ),
            ),

            // ═══ "Siz uchun maxsus" HEADER ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Siz uchun maxsus',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ),

            // ═══ FEATURED CARDS ═══
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    FeaturedImageCard(
                      badge: 'Mashhur',
                      title: 'Nonushta Set',
                      subtitle: "Barakali va to'yimli",
                      imageUrl: null,
                      fallbackIcon: Icons.bakery_dining,
                      badgeColor: const Color(0xFFE65100),
                      bgGradient: const [
                        Color(0xFFFFF3E0),
                        Color(0xFFFFE0B2),
                      ],
                      placeholderColor: const Color(0xFFD4A574),
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    FeaturedImageCard(
                      badge: 'Yangi',
                      title: "Oilaviy To'plam",
                      subtitle: 'Butun oila uchun',
                      imageUrl: null,
                      fallbackIcon: Icons.restaurant_menu,
                      badgeColor: const Color(0xFF2E7D32),
                      bgGradient: const [
                        Color(0xFFE8F5E9),
                        Color(0xFFC8E6C9),
                      ],
                      placeholderColor: const Color(0xFF8B7E56),
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    FeaturedImageCard(
                      badge: 'Top',
                      title: 'Tandir Noni',
                      subtitle: 'Eng mazali tandir nonlari',
                      imageUrl: null,
                      fallbackIcon: Icons.local_fire_department,
                      badgeColor: const Color(0xFFC62828),
                      bgGradient: const [
                        Color(0xFFFCE4EC),
                        Color(0xFFF8BBD0),
                      ],
                      placeholderColor: const Color(0xFFC67B4F),
                      isDark: isDark,
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
