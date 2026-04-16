import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/features/buyer/orders/data/models/order_model.dart';
import 'package:patirchi/features/buyer/orders/presentation/providers/orders_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        final order = provider.orders.where((o) => o.id == orderId).firstOrNull;

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Buyurtma')),
            body: const Center(child: Text('Buyurtma topilmadi')),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F0EB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Buyurtma #${order.orderNumber}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _StatusTimelineCard(order: order),
                    const SizedBox(height: 12),
                    _OrderInfoCard(order: order),
                    const SizedBox(height: 12),
                    _ItemsCard(order: order),
                    if (order.deliveryAddress != null) ...[
                      const SizedBox(height: 12),
                      _DeliveryAddressCard(address: order.deliveryAddress!),
                    ],
                    const SizedBox(height: 12),
                    _PaymentSummaryCard(order: order),
                  ],
                ),
              ),
              _BottomActionBar(order: order),
            ],
          ),
        );
      },
    );
  }
}

// ===== Status Timeline =====
class _StatusTimelineCard extends StatelessWidget {
  final OrderModel order;

  const _StatusTimelineCard({required this.order});

  static const _steps = [
    (OrderStatus.pending, 'Buyurtma berildi', Icons.receipt_outlined),
    (OrderStatus.confirmed, 'Tasdiqlandi', Icons.check_circle_outline),
    (OrderStatus.preparing, 'Tayyorlanmoqda', Icons.bakery_dining_outlined),
    (OrderStatus.delivering, 'Yo\'lda', Icons.delivery_dining_outlined),
    (OrderStatus.delivered, 'Yetkazildi', Icons.home_outlined),
  ];

  int get _currentStepIndex {
    if (order.status == OrderStatus.cancelled) return -1;
    final idx = _steps.indexWhere((s) => s.$1 == order.status);
    return idx;
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final currentIdx = _currentStepIndex;

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Buyurtma holati',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (isCancelled)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Bekor qilindi',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (isCancelled)
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.error,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Buyurtma bekor qilindi',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(_steps.length, (i) {
                final (_, label, icon) = _steps[i];
                final isCompleted = i < currentIdx;
                final isActive = i == currentIdx;
                final isLast = i == _steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: AppConstants.animNormal,
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCompleted || isActive
                                ? (isCompleted
                                    ? AppColors.success
                                    : AppColors.primary)
                                : AppColors.warmBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted || isActive
                                  ? Colors.transparent
                                  : AppColors.divider,
                            ),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : icon,
                            size: 18,
                            color: isCompleted || isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (!isLast)
                          AnimatedContainer(
                            duration: AppConstants.animNormal,
                            width: 2,
                            height: 28,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.divider,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCompleted || isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }
}

// ===== Order Info Card =====
class _OrderInfoCard extends StatelessWidget {
  final OrderModel order;

  const _OrderInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buyurtma ma\'lumotlari',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.receipt_outlined,
            label: 'Buyurtma raqami',
            value: '#${order.orderNumber}',
          ),
          _InfoRow(
            icon: Icons.store_rounded,
            label: 'Do\'kon',
            value: order.shopName,
          ),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Sana',
            value: Formatters.dateTime(order.createdAt),
          ),
          _InfoRow(
            icon: Icons.payment_rounded,
            label: 'To\'lov usuli',
            value: order.paymentMethod,
          ),
          if (order.estimatedDelivery != null)
            _InfoRow(
              icon: Icons.schedule_rounded,
              label: 'Taxminiy yetkazish',
              value: Formatters.dateTime(order.estimatedDelivery!),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Items Card =====
class _ItemsCard extends StatelessWidget {
  final OrderModel order;

  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buyurtma tarkibi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.warmBg,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: const Icon(
                        Icons.bakery_dining,
                        color: AppColors.secondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${item.quantity} x ${Formatters.price(item.unitPrice)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.price(item.totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ===== Delivery Address =====
class _DeliveryAddressCard extends StatelessWidget {
  final String address;

  const _DeliveryAddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yetkazish manzili',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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

// ===== Payment Summary =====
class _PaymentSummaryCard extends StatelessWidget {
  final OrderModel order;

  const _PaymentSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To\'lov xulosasi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _SummaryLine('Mahsulotlar', Formatters.price(order.subtotal)),
          if (order.discount > 0)
            _SummaryLine(
              'Chegirma',
              '-${Formatters.price(order.discount)}',
              valueColor: AppColors.success,
            ),
          _SummaryLine(
            'Yetkazib berish',
            order.deliveryFee > 0
                ? Formatters.price(order.deliveryFee)
                : 'Bepul',
            valueColor: order.deliveryFee == 0 ? AppColors.success : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jami to\'lov',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Text(
                Formatters.price(order.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryLine(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Bottom Action Bar =====
class _BottomActionBar extends StatelessWidget {
  final OrderModel order;

  const _BottomActionBar({required this.order});

  @override
  Widget build(BuildContext context) {
    final canCancel = order.status == OrderStatus.pending;
    final canReorder = order.status == OrderStatus.delivered;

    if (!canCancel && !canReorder) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: canCancel
            ? OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Bekor qilish'),
                      content: const Text(
                          'Buyurtmani bekor qilmoqchimisiz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Yo\'q'),
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<OrdersProvider>()
                                .cancelOrder(order.id);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Ha, bekor qilish'),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Bekor qilish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Qayta buyurtma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ===== Shared Card wrapper =====
class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
