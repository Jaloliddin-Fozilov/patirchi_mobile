import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/widgets/product_card.dart';
import 'package:patirchi/core/widgets/empty_state.dart';
import 'package:patirchi/features/buyer/home/presentation/providers/buyer_home_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerHomeProvider>(
      builder: (context, provider, _) {
        final favorites = provider.products.where((p) => p.isFavorite).toList();

        if (favorites.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border,
            title: 'Sevimlilar bo\'sh',
            subtitle: 'Mahsulotlardagi yurakchani bosib qo\'shing',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final product = favorites[index];
            return ProductCard(
              name: product.name,
              price: product.price,
              shopName: product.shopName,
              isFavorite: true,
              onTap: () {},
              onFavoriteTap: () => provider.toggleFavorite(product.id),
            );
          },
        );
      },
    );
  }
}
