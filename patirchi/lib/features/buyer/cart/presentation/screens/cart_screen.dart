import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/core/widgets/empty_state.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.items.isEmpty) {
          return const EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Savat bo\'sh',
            subtitle: 'Mahsulotlarni savatga qo\'shing',
          );
        }

        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Savat',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Savatda ${cart.itemCount} ta mahsulot',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Cart items
                  ...cart.items.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusL),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.warmBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.bakery_dining,
                                  color: AppColors.secondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${Formatters.price(item.product.price)} / dona',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.price(item.totalPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _QtyButton(
                                      icon: Icons.remove,
                                      onTap: () => cart.updateQuantity(
                                          item.product.id,
                                          item.quantity - 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text('${item.quantity}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    _QtyButton(
                                      icon: Icons.add,
                                      onTap: () => cart.updateQuantity(
                                          item.product.id,
                                          item.quantity + 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),

                  // Coupon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kupon kodi',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: cart.applyCoupon,
                                decoration: const InputDecoration(
                                  hintText: 'BEDR2658',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Qo\'llash'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'To\'lov xulosasi',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        _SummaryRow('Jami', Formatters.price(cart.subtotal)),
                        _SummaryRow(
                          'Chegirma',
                          cart.discount > 0
                              ? '-${Formatters.price(cart.discount)}'
                              : '0 so\'m',
                        ),
                        _SummaryRow(
                          'Yetkazib berish narxi',
                          cart.deliveryFee > 0
                              ? Formatters.price(cart.deliveryFee)
                              : 'BEPUL',
                          valueColor: cart.deliveryFee > 0
                              ? null
                              : AppColors.success,
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Umumiy to\'lov:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              Formatters.price(cart.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.price(cart.total),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/checkout'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Buyurtma Berish'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
