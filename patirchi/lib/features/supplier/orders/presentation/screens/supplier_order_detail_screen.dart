import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/core/widgets/status_badge.dart';
import 'package:patirchi/features/supplier/orders/data/models/supplier_order_model.dart';
import 'package:patirchi/features/supplier/orders/presentation/providers/supplier_orders_provider.dart';

class SupplierOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const SupplierOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierOrdersProvider>();
    final order = provider.allOrders.firstWhere((o) => o.id == orderId);

    return Scaffold(
      appBar: AppBar(
        title: Text('#${order.orderNumber}'),
        backgroundColor: AppColors.supplierAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status row
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.supplierAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(
                  color: AppColors.supplierAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Holat',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(
                          text: order.status.label,
                          color: AppColors.orderStatusColor(order.status),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Sana',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.dateTime(order.createdAt),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bakery info
            _SectionCard(
              title: 'Nonvoyxona ma\'lumotlari',
              icon: Icons.store_outlined,
              child: Column(
                children: [
                  _InfoRow(label: 'Nomi', value: order.bakeryName),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Manzil', value: order.bakeryAddress),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Telefon',
                    value: Formatters.phone(order.bakeryPhone),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.call,
                        color: AppColors.supplierAccent,
                        size: 20,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Qo'ng'iroq: ${order.bakeryPhone}")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Items table
            _SectionCard(
              title: 'Buyurtma tarkibi',
              icon: Icons.inventory_2_outlined,
              child: Column(
                children: [
                  // Header
                  Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Mahsulot',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Miqdor',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Narx',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Jami',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  ...order.items.map((item) => _ItemRow(item: item)),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'JAMI:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        Formatters.price(order.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.supplierAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (order.note != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Izoh',
                icon: Icons.notes,
                child: Text(order.note!),
              ),
            ],
            const SizedBox(height: 24),
            // Action buttons
            _ActionButtons(order: order),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final SupplierOrderModel order;

  const _ActionButtons({required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SupplierOrdersProvider>();

    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Rad etish'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                onPressed: () {
                  provider.updateStatus(order.id, OrderStatus.cancelled);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Qabul qilish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.supplierAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  provider.updateStatus(order.id, OrderStatus.confirmed);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );

      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.local_shipping_outlined),
            label: const Text('Yetkazishni boshlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.supplierAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              elevation: 0,
            ),
            onPressed: () {
              provider.updateStatus(order.id, OrderStatus.delivering);
              Navigator.pop(context);
            },
          ),
        );

      case OrderStatus.delivering:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.done_all),
            label: const Text('Yetkazildi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              elevation: 0,
            ),
            onPressed: () {
              provider.updateStatus(order.id, OrderStatus.delivered);
              Navigator.pop(context);
            },
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.supplierAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(icon, size: 16, color: AppColors.supplierAccent),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final SupplierOrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item.productName, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.quantity.toStringAsFixed(0)} ${item.unit}',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              Formatters.priceShort(item.unitPrice),
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              Formatters.priceShort(item.total),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
