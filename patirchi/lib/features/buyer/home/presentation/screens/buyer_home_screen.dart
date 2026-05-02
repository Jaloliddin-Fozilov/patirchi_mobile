import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../providers/buyer_home_provider.dart';
import '../widgets/buyer_home_banners.dart';
import '../widgets/buyer_home_services.dart';
import '../widgets/buyer_home_sliver_delegate.dart';
import '../widgets/product_card_dark.dart';
import 'nearby_shops_map_screen.dart';
import 'product_detail_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Pagination: load more when near bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BuyerHomeProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Consumer<BuyerHomeProvider>(
      builder: (context, provider, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
            color: const Color(0xFF1A1A1A),
            child: RefreshIndicator(
              onRefresh: provider.refresh,
              color: AppColors.primary,
              backgroundColor: const Color(0xFF2C2C2C),
              displacement: 80,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ===== CUSTOM HEADER =====
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: BuyerHomeSliverDelegate(
                      statusBarHeight: statusBarHeight,
                      searchBar: _buildSearchBar(provider),
                      middleRow: _buildMiddleRow(),
                      promoBanner: const BuyerHomePromoBanner(),
                    ),
                  ),

                  // ===== AD BANNER CAROUSEL =====
                  const SliverToBoxAdapter(
                    child: ColoredBox(
                      color: Color(0xFF1A1A1A),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: BuyerHomeBanners(),
                      ),
                    ),
                  ),

                  // ===== QUICK SERVICES =====
                  const SliverToBoxAdapter(
                    child: ColoredBox(
                      color: Color(0xFF1A1A1A),
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: BuyerHomeServices(),
                      ),
                    ),
                  ),

                  // ===== PRODUCT GRID =====
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = provider.products[index];
                          return ProductCardDark(
                            product: product,
                            onTap: () => _openProductDetail(product),
                            onFavoriteTap: () =>
                                provider.toggleFavorite(product.id),
                          );
                        },
                        childCount: provider.products.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.56,
                      ),
                    ),
                  ),

                  // ===== LOADING / END INDICATOR =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: provider.isLoadingMore
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              )
                            : provider.hasMore
                                ? const SizedBox.shrink()
                                : const Text(
                                    'Barcha mahsulotlar yuklandi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openProductDetail(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
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
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NearbyShopsMapScreen(),
                ),
              );
            },
            child: const Icon(Icons.map_outlined,
                color: Color(0xFF9E9E9E), size: 22),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ===== MIDDLE ROW =====
  Widget _buildMiddleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Manzil tanlash tez kunda')),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 18, color: Colors.white70),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Chilonzor, 9-kvartal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      size: 20, color: Colors.white70),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bonus tizimi tez kunda')),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
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
                      Icons.monetization_on,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '1 000',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3D00),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '4',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
