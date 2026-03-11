import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import '../../data/datasources/buyer_home_local_datasource.dart';
import '../providers/buyer_home_provider.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Consumer<BuyerHomeProvider>(
      builder: (context, provider, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
            color: const Color(0xFF1A1A1A),
            child: CustomScrollView(
              slivers: [
                // ===== PINK GRADIENT TOP + PINNED SEARCH =====
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 340 + statusBarHeight,
                  toolbarHeight: 62,
                  backgroundColor: const Color(0xFF2A2A2A),
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  // Pinned search bar
                  title: _buildSearchBar(provider),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: _buildTopSection(statusBarHeight),
                  ),
                ),

                // ===== DARK SECTION =====
                // Quick services
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: BuyerHomeLocalDatasource.quickServices.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final service = BuyerHomeLocalDatasource.quickServices[index];
                          final iconData = _getServiceIcon(service['icon'] as String);
                          final bgColors = [
                            const Color(0xFF2979FF),
                            const Color(0xFF43A047),
                            const Color(0xFFE53935),
                            const Color(0xFFFF8F00),
                            const Color(0xFF7B1FA2),
                          ];
                          return SizedBox(
                            width: 76,
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: bgColors[index % bgColors.length],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (service['label'] as String).replaceAll('\n', ' '),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFCCCCCC),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Product grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = provider.products[index];
                        return _ProductCardDark(
                          name: product.name,
                          price: product.price,
                          oldPrice: product.oldPrice,
                          discountPercent: product.discountPercent,
                          shopName: product.shopName,
                          isFavorite: product.isFavorite,
                          onTap: () {},
                          onFavoriteTap: () => provider.toggleFavorite(product.id),
                        );
                      },
                      childCount: provider.products.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.56,
                    ),
                  ),
                ),

                // Page indicator dots
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (i) {
                        return Container(
                          width: i == 0 ? 8 : 6,
                          height: i == 0 ? 8 : 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0
                                ? const Color(0xFF2979FF)
                                : const Color(0xFF555555),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== PINNED SEARCH BAR =====
  Widget _buildSearchBar(BuyerHomeProvider provider) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: provider.search,
              style: const TextStyle(fontSize: 15, color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Patirchi qidirish',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const Icon(Icons.graphic_eq, color: Color(0xFF9E9E9E), size: 22),
          const SizedBox(width: 8),
          Container(width: 1, height: 22, color: const Color(0xFF555555)),
          const SizedBox(width: 8),
          const Icon(Icons.camera_alt_outlined, color: Color(0xFF9E9E9E), size: 22),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ===== PINK GRADIENT TOP SECTION =====
  Widget _buildTopSection(double statusBarHeight) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE91E90), Color(0xFFFF4D8D), Color(0xFFFF6B9D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: statusBarHeight),

          // -- Header: Pickup point + balance + menu --
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Patirchi Punkti: Chilonzor, 9-kv',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Balance pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '1 000',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Menu button with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6B4EFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '4',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // -- Search bar (on pink bg - visible in expanded state) --
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 14),
                  Icon(Icons.search, color: Color(0xFFAAAAAA), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Patirchi qidirish',
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(Icons.graphic_eq, color: Color(0xFFAAAAAA), size: 24),
                  SizedBox(width: 10),
                  SizedBox(width: 1, height: 24),
                  SizedBox(width: 10),
                  Icon(Icons.camera_alt_outlined, color: Color(0xFFAAAAAA), size: 24),
                  SizedBox(width: 14),
                ],
              ),
            ),
          ),

          // -- Promo banner (continues pink gradient feel) --
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD81B60).withValues(alpha: 0.8),
                    const Color(0xFFAD1457).withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 110, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PATIRCHI AKSIYASI\nMAXSUS PROMOKOD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '2 kunler oxirigacha',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.chevron_right, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // -20% metallic badge
                  Positioned(
                    right: 10,
                    top: 12,
                    bottom: 12,
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD0D0D0), Color(0xFFA8A8A8), Color(0xFFE0E0E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '-20%',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3C3C3C),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -- Ad / Reklama banner --
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4A76A), Color(0xFFF5DEB3), Color(0xFFEED9B6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Eng mazali nonlar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3C2415),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'TANDIR NONI 3=2',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF5C3A1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Maxsus taklif',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF3C2415).withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Reklama',
                        style: TextStyle(fontSize: 10, color: Color(0xFF888888)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Icon(
                      Icons.bakery_dining,
                      size: 50,
                      color: const Color(0xFF5C3A1E).withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String name) {
    switch (name) {
      case 'storefront':
        return Icons.grid_view_rounded;
      case 'local_offer':
        return Icons.account_balance_wallet;
      case 'delivery_dining':
        return Icons.flight;
      case 'work_outline':
        return Icons.work;
      case 'star_outline':
        return Icons.local_shipping;
      default:
        return Icons.circle;
    }
  }
}

// Dark-themed product card
class _ProductCardDark extends StatelessWidget {
  final String name;
  final int price;
  final int? oldPrice;
  final int? discountPercent;
  final String? shopName;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const _ProductCardDark({
    required this.name,
    required this.price,
    this.oldPrice,
    this.discountPercent,
    this.shopName,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: const Center(
                      child: Icon(Icons.bakery_dining, size: 60, color: Color(0xFF666666)),
                    ),
                  ),
                  if (onFavoriteTap != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isFavorite
                                ? const Color(0xFF2979FF)
                                : const Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.price(price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (oldPrice != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          Formatters.price(oldPrice!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Color(0xFF888888),
                          ),
                        ),
                        if (discountPercent != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '-$discountPercent%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (shopName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      shopName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}