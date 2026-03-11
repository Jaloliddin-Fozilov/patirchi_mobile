import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/enums.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final String orderNumber;
  final DateTime date;
  final String summary;
  final int totalPrice;
  final OrderStatus status;
  final String? shopName;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.date,
    required this.summary,
    required this.totalPrice,
    required this.status,
    this.shopName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warmBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bakery_dining,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#$orderNumber',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        Formatters.dateTime(date),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  text: status.label,
                  color: AppColors.orderStatusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warmBgLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jami: ${Formatters.price(totalPrice)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}