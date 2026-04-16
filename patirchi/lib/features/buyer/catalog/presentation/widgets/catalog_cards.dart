import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'food_image.dart';

/// Main category card — 3-col grid item with image + label
class ImageCategoryCard extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color placeholderColor;
  final bool isDark;
  final Color textColor;

  const ImageCategoryCard({
    super.key,
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
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategoriya: $label tez kunda')),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: FoodImage(
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
class CuisineCircle extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final Color textColor;

  const CuisineCircle({
    super.key,
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
            child: FoodImage(
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
class KategoriyaImageCard extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color placeholderColor;
  final bool isDark;
  final String? overlay;

  const KategoriyaImageCard({
    super.key,
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
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategoriya: $label tez kunda')),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FoodImage(
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
class FeaturedImageCard extends StatelessWidget {
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

  const FeaturedImageCard({
    super.key,
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
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maxsus taklif: $title')),
        );
      },
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
                          Icon(Icons.star_rounded, size: 14, color: badgeColor),
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
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
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
                child: FoodImage(
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
