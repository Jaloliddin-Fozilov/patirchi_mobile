import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/core/widgets/status_badge.dart';
import '../providers/bakery_orders_provider.dart';

class BakeryOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const BakeryOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BakeryOrdersProvider>(
      builder: (context, provider, _) {
        final order = provider.getOrderById(orderId);
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Buyurtma')),
            body: const Center(child: Text('Buyurtma topilmadi')),
          );
        }
        return _OrderDetailView(order: order, provider: provider);
      },
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final BakeryOrder order;
  final BakeryOrdersProvider provider;

  const _OrderDetailView({required this.order, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bakeryAccent,
        foregroundColor: Colors.white,
        title: Text('#${order.orderNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Qo\'ng\'iroq: ${order.customerPhone}')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(order: order),
            const SizedBox(height: 16),
            _ItemsTable(order: order),
            const SizedBox(height: 16),
            _DeliveryCard(order: order),
            const SizedBox(height: 16),
            _PaymentCard(order: order),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _ActionBar(order: order, provider: provider),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final BakeryOrder order;
  const _HeaderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bakeryAccent, Color(0xFF448AFF)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Buyurtma #${order.orderNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusBadge(
                text: order.status.label,
                color: AppColors.orderStatusColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.dateTime(order.date),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                order.customerName,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                Formatters.phone(order.customerPhone),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  final BakeryOrder order;
  const _ItemsTable({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bakeryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long,
                      color: AppColors.bakeryAccent, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Buyurtma tarkibi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Mahsulot',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    'Soni',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Narx',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Jami',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...order.items.map((item) => _ItemRow(item: item)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Umumiy:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Formatters.price(order.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.bakeryAccent,
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

class _ItemRow extends StatelessWidget {
  final BakeryOrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.productName,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${item.qty}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.priceShort(item.unitPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.priceShort(item.total),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final BakeryOrder order;
  const _DeliveryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.local_shipping_outlined,
      title: 'Yetkazib berish',
      children: [
        _InfoRow(
          label: 'Usul',
          value: order.deliveryMethod.label,
        ),
        if (order.deliveryMethod == DeliveryMethod.courier &&
            order.deliveryAddress != null)
          _InfoRow(
            label: 'Manzil',
            value: order.deliveryAddress!,
          ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final BakeryOrder order;
  const _PaymentCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.payment_outlined,
      title: "To'lov",
      children: [
        _InfoRow(label: 'Usul', value: order.paymentMethod),
        _InfoRow(
          label: 'Holat',
          value: order.isPaid ? "To'langan" : "To'lanmagan",
          valueColor: order.isPaid ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bakeryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.bakeryAccent, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final BakeryOrder order;
  final BakeryOrdersProvider provider;

  const _ActionBar({required this.order, required this.provider});

  @override
  Widget build(BuildContext context) {
    final buttons = _buildButtons(context);
    if (buttons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: buttons
            .map(
              (btn) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: buttons.indexOf(btn) > 0 ? 8 : 0,
                  ),
                  child: btn,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          ElevatedButton.icon(
            onPressed: () {
              provider.confirmOrder(order.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Qabul qilish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              provider.rejectOrder(order.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Rad etish'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
          ),
        ];
      case OrderStatus.confirmed:
        return [
          ElevatedButton.icon(
            onPressed: () {
              provider.startPreparing(order.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.soup_kitchen_outlined),
            label: const Text('Tayyorlashni boshlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bakeryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
          ),
        ];
      case OrderStatus.preparing:
        return [
          ElevatedButton.icon(
            onPressed: () {
              provider.markReady(order.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.done_all),
            label: const Text('Tayyor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
          ),
        ];
      case OrderStatus.delivering:
        return [
          ElevatedButton.icon(
            onPressed: () {
              _showConfirmDelivery(context);
            },
            icon: const Icon(Icons.local_shipping),
            label: const Text('Yetkazildi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  void _showConfirmDelivery(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tasdiqlash'),
        content: const Text(
          'Buyurtma yetkazilganligini tasdiqlaysizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.markDelivered(order.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }
}
