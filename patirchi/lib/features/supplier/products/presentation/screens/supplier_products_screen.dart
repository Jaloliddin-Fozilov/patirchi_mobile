import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/core/widgets/category_chip.dart';
import 'package:patirchi/core/widgets/empty_state.dart';
import 'package:patirchi/features/supplier/products/data/models/supplier_product_model.dart';
import 'package:patirchi/features/supplier/products/presentation/providers/supplier_products_provider.dart';
import 'package:patirchi/features/supplier/products/presentation/screens/supplier_product_form_screen.dart';

class SupplierProductsScreen extends StatefulWidget {
  const SupplierProductsScreen({super.key});

  @override
  State<SupplierProductsScreen> createState() => _SupplierProductsScreenState();
}

class _SupplierProductsScreenState extends State<SupplierProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierProductsProvider(),
      child: _SupplierProductsView(searchController: _searchController),
    );
  }
}

class _SupplierProductsView extends StatelessWidget {
  final TextEditingController searchController;

  const _SupplierProductsView({required this.searchController});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProductsProvider>();
    final products = provider.filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.supplierAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Mahsulot qo'shish"),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupplierProductFormScreen()),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: context.read<SupplierProductsProvider>().setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Mahsulot qidirish...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          context
                              .read<SupplierProductsProvider>()
                              .setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.warmBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Category chips
          CategoryChips(
            categories: SupplierProductsProvider.categories,
            selectedIndex: provider.selectedCategoryIndex,
            onSelected: provider.setCategory,
            activeColor: AppColors.supplierAccent,
          ),
          const SizedBox(height: 12),
          // Product grid
          Expanded(
            child: products.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Mahsulotlar topilmadi',
                    subtitle: "Qidiruv so'rovini o'zgartiring yoki yangi mahsulot qo'shing",
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) =>
                        _ProductCard(product: products[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final SupplierProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusL),
            ),
            child: Container(
              height: 110,
              width: double.infinity,
              color: AppColors.supplierAccent.withValues(alpha: 0.08),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _categoryIcon(product.category?.name ?? ''),
                      size: 48,
                      color: AppColors.supplierAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  if (!product.isActive)
                    Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: const Center(
                        child: Text(
                          'Nofaol',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => context
                          .read<SupplierProductsProvider>()
                          .toggleActive(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          product.isActive
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 14,
                          color: product.isActive
                              ? AppColors.supplierAccent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${Formatters.price(product.price)} / ${product.units}',
                        style: const TextStyle(
                          color: AppColors.supplierAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.weight != null
                          ? 'Og\'irlik: ${product.weight} ${product.units}'
                          : product.units,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SupplierProductFormScreen(product: product),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.supplierAccent,
                      side: const BorderSide(color: AppColors.supplierAccent),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                      ),
                    ),
                    child: const Text(
                      'Tahrirlash',
                      style: TextStyle(fontSize: 12),
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Un':
        return Icons.grain;
      case "Yog'":
        return Icons.water_drop;
      case 'Shakar':
        return Icons.cookie;
      case 'Tuxum':
        return Icons.egg_outlined;
      case 'Sut':
        return Icons.local_drink;
      default:
        return Icons.category;
    }
  }
}
