import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/widgets/stats_card.dart';
import 'package:patirchi/core/widgets/order_card.dart';
import 'package:patirchi/core/widgets/category_chip.dart';
import 'package:patirchi/core/utils/formatters.dart';
import '../providers/bakery_orders_provider.dart';
import 'bakery_order_detail_screen.dart';

class BakeryOrdersScreen extends StatefulWidget {
  const BakeryOrdersScreen({super.key});

  @override
  State<BakeryOrdersScreen> createState() => _BakeryOrdersScreenState();
}

class _BakeryOrdersScreenState extends State<BakeryOrdersScreen> {
  int _selectedTab = 0;
  bool _showIncoming = true;

  static const _statusFilters = [
    'Barchasi',
    'Yangi',
    'Jarayonda',
    'Yetkazilgan',
    'Qaytarilgan',
  ];

  static const _tabStatuses = <List<OrderStatus>>[
    [],
    [OrderStatus.pending],
    [OrderStatus.confirmed, OrderStatus.preparing, OrderStatus.delivering],
    [OrderStatus.delivered],
    [OrderStatus.cancelled],
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BakeryOrdersProvider>(
      builder: (context, provider, _) {
        final allOrders = provider.orders;
        final displayOrders = _selectedTab == 0
            ? allOrders
            : allOrders
                .where((o) => _tabStatuses[_selectedTab].contains(o.status))
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Buyurtmalar Panel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.filter_list, color: AppColors.textSecondary),
                ],
              ),
            ),
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      value: '${provider.todayOrderCount}',
                      label: 'SONI',
                      backgroundColor: AppColors.bakeryAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatsCard(
                      value: Formatters.priceShort(provider.todayRevenue),
                      label: 'TUSHUM',
                      backgroundColor:
                          AppColors.success.withValues(alpha: 0.15),
                      textColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatsCard(
                      value: Formatters.priceShort(provider.averageOrderValue),
                      label: "O'RTACHA",
                      backgroundColor:
                          AppColors.warning.withValues(alpha: 0.15),
                      textColor: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatsCard(
                      value: 'AI',
                      label: 'TAHLIL',
                      backgroundColor: AppColors.info.withValues(alpha: 0.15),
                      textColor: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _ToggleBtn(
                    'Kiruvchi buyurtma',
                    isActive: _showIncoming,
                    color: AppColors.bakeryAccent,
                    onTap: () => setState(() => _showIncoming = true),
                  ),
                  const SizedBox(width: 8),
                  _ToggleBtn(
                    'Buyurtmalarim',
                    isActive: !_showIncoming,
                    color: AppColors.bakeryAccent,
                    onTap: () => setState(() => _showIncoming = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Filter chips
            CategoryChips(
              categories: _statusFilters,
              selectedIndex: _selectedTab,
              onSelected: (i) => setState(() => _selectedTab = i),
              activeColor: AppColors.bakeryAccent,
            ),
            const SizedBox(height: 8),
            // Orders list
            Expanded(
              child: displayOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Buyurtma topilmadi",
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayOrders.length,
                      itemBuilder: (context, i) {
                        final order = displayOrders[i];
                        final summary = order.items
                            .map((item) => '${item.productName}: ${item.qty}')
                            .join(', ');
                        return OrderCard(
                          orderNumber: order.orderNumber,
                          date: order.date,
                          summary: summary,
                          totalPrice: order.totalPrice,
                          status: order.status,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BakeryOrderDetailScreen(
                                  orderId: order.id,
                                ),
                              ),
                            );
                          },
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

class _ToggleBtn extends StatelessWidget {
  final String text;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn(
    this.text, {
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          border: Border.all(color: isActive ? color : AppColors.border),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
