import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/product_card.dart';
import 'package:patirchi/core/widgets/category_chip.dart';
import 'package:patirchi/features/buyer/home/presentation/providers/buyer_home_provider.dart';
import 'package:patirchi/features/buyer/home/data/datasources/buyer_home_local_datasource.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BuyerHomeProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                onChanged: provider.search,
                decoration: const InputDecoration(
                  hintText: 'Qidirish...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                ),
              ),
            ),
            // Filter chips
            CategoryChips(
              categories: BuyerHomeLocalDatasource.categories,
              selectedIndex: provider.selectedCategory,
              onSelected: provider.selectCategory,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${provider.products.length} ta mahsulot topildi',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: provider.products.length,
                itemBuilder: (context, index) {
                  final product = provider.products[index];
                  return ProductCard(
                    name: product.name,
                    price: product.price,
                    shopName: product.shopName,
                    isFavorite: product.isFavorite,
                    onTap: () {},
                    onFavoriteTap: () => provider.toggleFavorite(product.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
