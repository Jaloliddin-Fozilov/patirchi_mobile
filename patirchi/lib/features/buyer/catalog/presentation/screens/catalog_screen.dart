import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';

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
                      onPressed: () {},
                      visualDensity: VisualDensity.compact,
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_none_rounded,
                              color: textColor, size: 24),
                          onPressed: () {},
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
                  _mainCategories.map((cat) {
                    return _ImageCategoryCard(
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
                    itemCount: _cuisineTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final cuisine = _cuisineTypes[index];
                      return _CuisineCircle(
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
                    final cat = _kategoriyalar[index];
                    return _KategoriyaImageCard(
                      label: cat['label'] as String,
                      imageUrl: cat['imageUrl'] as String?,
                      fallbackIcon: cat['icon'] as IconData,
                      placeholderColor: cat['color'] as Color,
                      isDark: isDark,
                      overlay:
                          index == _kategoriyalar.length - 1 ? '+25' : null,
                    );
                  },
                  childCount: _kategoriyalar.length,
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
                    _FeaturedImageCard(
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
                    _FeaturedImageCard(
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
                    _FeaturedImageCard(
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

// ═══════════════════════════════════════════════════════
//  DATA
// ═══════════════════════════════════════════════════════

final _mainCategories = [
  {
    'label': 'Nonushta',
    'icon': Icons.free_breakfast_rounded,
    'color': const Color(0xFFD4A574),
    'imageUrl': null, // TODO: Replace with API image URL
  },
  {
    'label': 'Ikkinchi kurslar',
    'icon': Icons.restaurant_rounded,
    'color': const Color(0xFFB8860B),
    'imageUrl': null,
  },
  {
    'label': "Ko'cha ovqatlari",
    'icon': Icons.fastfood_rounded,
    'color': const Color(0xFFC67B4F),
    'imageUrl': null,
  },
  {
    'label': "Sho'rvalar",
    'icon': Icons.soup_kitchen_rounded,
    'color': const Color(0xFF8B7E56),
    'imageUrl': null,
  },
  {
    'label': 'Yengil taomlar',
    'icon': Icons.lunch_dining_rounded,
    'color': const Color(0xFFD4B483),
    'imageUrl': null,
  },
  {
    'label': 'Desertlar',
    'icon': Icons.cake_rounded,
    'color': const Color(0xFFAD8B6E),
    'imageUrl': null,
  },
];

final _cuisineTypes = [
  {
    'label': "Sog'lom o...",
    'icon': Icons.eco_rounded,
    'color': const Color(0xFFA0826D),
    'imageUrl': null,
  },
  {
    'label': 'Osiyo osh...',
    'icon': Icons.ramen_dining_rounded,
    'color': const Color(0xFFBE8C63),
    'imageUrl': null,
  },
  {
    'label': 'Rus oshx...',
    'icon': Icons.dining_rounded,
    'color': const Color(0xFF9C7A5B),
    'imageUrl': null,
  },
  {
    'label': 'Kavkaz os...',
    'icon': Icons.outdoor_grill_rounded,
    'color': const Color(0xFFC49A6C),
    'imageUrl': null,
  },
  {
    'label': "Yevropa o...",
    'icon': Icons.brunch_dining_rounded,
    'color': const Color(0xFFD4B896),
    'imageUrl': null,
  },
];

final _kategoriyalar = [
  {
    'label': 'Shirinliklar',
    'icon': Icons.cookie_rounded,
    'color': const Color(0xFFBE8C63),
    'imageUrl': null,
  },
  {
    'label': 'Ichimliklar',
    'icon': Icons.local_cafe_rounded,
    'color': const Color(0xFF9C7A5B),
    'imageUrl': null,
  },
  {
    'label': 'Salatlar',
    'icon': Icons.grass_rounded,
    'color': const Color(0xFF8B7E56),
    'imageUrl': null,
  },
  {
    'label': 'Nonushta',
    'icon': Icons.free_breakfast_rounded,
    'color': const Color(0xFFD4A574),
    'imageUrl': null,
  },
  {
    'label': 'Tushlik',
    'icon': Icons.restaurant_rounded,
    'color': const Color(0xFFC67B4F),
    'imageUrl': null,
  },
  {
    'label': 'Kechki',
    'icon': Icons.dinner_dining_rounded,
    'color': const Color(0xFFB8860B),
    'imageUrl': null,
  },
  {
    'label': 'Fast Food',
    'icon': Icons.fastfood_rounded,
    'color': const Color(0xFFD4B483),
    'imageUrl': null,
  },
  {
    'label': 'Barchasi',
    'icon': Icons.grid_view_rounded,
    'color': const Color(0xFFAD8B6E),
    'imageUrl': null,
  },
];

// ═══════════════════════════════════════════════════════
//  SHARED — Food Image Placeholder
// ═══════════════════════════════════════════════════════

class _FoodImage extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color placeholderColor;
  final double borderRadius;
  final BoxShape shape;

  const _FoodImage({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.placeholderColor,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (shape == BoxShape.circle) {
        return ClipOval(
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: _loadingBuilder,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: _loadingBuilder,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _loadingBuilder(
      BuildContext ctx, Widget child, ImageChunkEvent? progress) {
    if (progress == null) return child;
    return _placeholder(showLoading: true);
  }

  Widget _placeholder({bool showLoading = false}) {
    final hsl = HSLColor.fromColor(placeholderColor);
    final darkTone = hsl
        .withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    final decoration = shape == BoxShape.circle
        ? BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [placeholderColor, darkTone],
              center: Alignment.topLeft,
              radius: 1.2,
            ),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: [placeholderColor, darkTone],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          );

    return Container(
      decoration: decoration,
      child: Center(
        child: showLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              )
            : Icon(
                fallbackIcon,
                size: shape == BoxShape.circle ? 24 : 36,
                color: Colors.white.withValues(alpha: 0.7),
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  WIDGETS
// ═══════════════════════════════════════════════════════

/// Main category card — 3-col grid item with image + label
class _ImageCategoryCard extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color placeholderColor;
  final bool isDark;
  final Color textColor;

  const _ImageCategoryCard({
    required this.label,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.placeholderColor,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Expanded(
            child: _FoodImage(
              imageUrl: imageUrl,
              fallbackIcon: fallbackIcon,
              placeholderColor:
                  isDark ? placeholderColor.withValues(alpha: 0.6) : placeholderColor,
              borderRadius: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuisine type circle — horizontal scroll item
class _CuisineCircle extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final Color textColor;

  const _CuisineCircle({
    required this.label,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.fallbackColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: _FoodImage(
              imageUrl: imageUrl,
              fallbackIcon: fallbackIcon,
              placeholderColor: fallbackColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kategoriya card — 4-col grid item with image + label + optional overlay
class _KategoriyaImageCard extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color placeholderColor;
  final bool isDark;
  final String? overlay;

  const _KategoriyaImageCard({
    required this.label,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.placeholderColor,
    required this.isDark,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _FoodImage(
                  imageUrl: imageUrl,
                  fallbackIcon: fallbackIcon,
                  placeholderColor: isDark
                      ? placeholderColor.withValues(alpha: 0.6)
                      : placeholderColor,
                  borderRadius: 12,
                ),
                if (overlay != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      child: Center(
                        child: Text(
                          overlay!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Featured card — full-width with text left + image right
class _FeaturedImageCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color badgeColor;
  final List<Color> bgGradient;
  final Color placeholderColor;
  final bool isDark;
  final Color textColor;

  const _FeaturedImageCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.badgeColor,
    required this.bgGradient,
    required this.placeholderColor,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    bgGradient[0].withValues(alpha: 0.2),
                    bgGradient[1].withValues(alpha: 0.3),
                  ]
                : bgGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Text side
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: 14, color: badgeColor),
                          const SizedBox(width: 4),
                          Text(
                            badge,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color:
                            isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Image side
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _FoodImage(
                  imageUrl: imageUrl,
                  fallbackIcon: fallbackIcon,
                  placeholderColor: placeholderColor,
                  borderRadius: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}