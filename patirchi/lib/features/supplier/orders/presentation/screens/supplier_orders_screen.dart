import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/core/widgets/category_chip.dart';
import 'package:patirchi/core/widgets/empty_state.dart';
import 'package:patirchi/core/widgets/stats_card.dart';
import 'package:patirchi/core/widgets/status_badge.dart';
import 'package:patirchi/features/supplier/orders/data/models/supplier_order_model.dart';
import 'package:patirchi/features/supplier/orders/presentation/providers/supplier_orders_provider.dart';
import 'package:patirchi/features/supplier/orders/presentation/screens/supplier_order_detail_screen.dart';

class SupplierOrdersScreen extends StatefulWidget {
  const SupplierOrdersScreen({super.key});

  @override
  State<SupplierOrdersScreen> createState() => _SupplierOrdersScreenState();
}

class _SupplierOrdersScreenState extends State<SupplierOrdersScreen> {
  int _tabIndex = 0;

  static const _tabs = ['Yangi', 'Jarayonda', 'Yetkazilgan', 'Bekor'];

  static const _tabStatuses = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierOrdersProvider(),
      child: _SupplierOrdersView(
        tabIndex: _tabIndex,
        onTabChanged: (i) => setState(() => _tabIndex = i),
        tabs: _tabs,
        tabStatuses: _tabStatuses,
      ),
    );
  }
}

class _SupplierOrdersView extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final List<String> tabs;
  final List<OrderStatus> tabStatuses;

  const _SupplierOrdersView({
    required this.tabIndex,
    required this.onTabChanged,
    required this.tabs,
    required this.tabStatuses,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierOrdersProvider>();
    final filtered = provider.ordersByStatus(tabStatuses[tabIndex]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header stats
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: StatsCard(
                  value: provider.todayOrderCount.toString(),
                  label: 'BUGUN',
                  backgroundColor: AppColors.supplierAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatsCard(
                  value: Formatters.priceShort(provider.totalRevenue),
                  label: 'DAROMAD',
                  backgroundColor:
                      AppColors.success.withValues(alpha: 0.15),
                  textColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatsCard(
                  value: provider.pendingOrders.length.toString(),
                  label: 'YANGI',
                  backgroundColor:
                      AppColors.warning.withValues(alpha: 0.15),
                  textColor: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatsCard(
                  value: provider.allOrders.length.toString(),
                  label: 'JAMI',
                  backgroundColor: AppColors.info.withValues(alpha: 0.15),
                  textColor: AppColors.info,
                ),
              ),
            ],
          ),
        ),
        // Tab filter chips
        CategoryChips(
          categories: tabs,
          selectedIndex: tabIndex,
          onSelected: onTabChanged,
          activeColor: AppColors.supplierAccent,
        ),
        const SizedBox(height: 8),
        // Orders list
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Bu yerda buyurtmalar yo\'q',
                  subtitle: '${tabs[tabIndex]} buyurtmalar hozircha mavjud emas',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _SupplierOrderCard(
                    order: filtered[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: context.read<SupplierOrdersProvider>(),
                          child: SupplierOrderDetailScreen(
                            orderId: filtered[index].id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SupplierOrderCard extends StatelessWidget {
  final SupplierOrderModel order;
  final VoidCallback onTap;

  const _SupplierOrderCard({required this.order, required this.onTap});

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
                    color: AppColors.supplierAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.store_outlined,
                    color: AppColors.supplierAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.bakeryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '#${order.orderNumber} · ${Formatters.dateTime(order.createdAt)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  text: order.status.label,
                  color: AppColors.orderStatusColor(order.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warmBg,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.items.length} ta mahsulot:  '
                    '${order.items.take(2).map((i) => i.productName).join(', ')}'
                    '${order.items.length > 2 ? '...' : ''}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jami: ${Formatters.price(order.total)}',
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
