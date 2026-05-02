import 'package:flutter/material.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/features/buyer/home/data/models/product_model.dart';

class ProductCardDark extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const ProductCardDark({
    super.key,
    required this.product,
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
                  // Product image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                    child: SizedBox(
                      width: double.infinity,
                      child: Hero(
                        tag: 'product_${product.id}',
                        child: product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imagePlaceholder(),
                                loadingBuilder:
                                    (_, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return _imagePlaceholder();
                                },
                              )
                            : _imagePlaceholder(),
                      ),
                    ),
                  ),
                  // Discount badge
                  if (product.discountPercent != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button
                  if (onFavoriteTap != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            product.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: product.isFavorite
                                ? const Color(0xFFFF5252)
                                : Colors.white70,
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
                    product.name,
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
                    Formatters.price(product.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (product.oldPrice != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      Formatters.price(product.oldPrice!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Color(0xFF888888),
                      ),
                    ),
                  ],
                  if (product.shopName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF888888)),
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

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF3A3A3A),
      child: const Center(
        child: Icon(Icons.bakery_dining, size: 50, color: Color(0xFF555555)),
      ),
    );
  }
}
