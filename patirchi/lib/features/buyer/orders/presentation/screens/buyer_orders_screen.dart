import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/empty_state.dart';
import 'package:patirchi/core/widgets/order_card.dart';
import 'package:patirchi/features/buyer/orders/data/models/order_model.dart';
import 'package:patirchi/features/buyer/orders/presentation/providers/orders_provider.dart';
import 'order_detail_screen.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Buyurtmalar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Faol'),
                Tab(text: 'Tarix'),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _OrdersList(
                orders: provider.getActiveOrders(),
                emptyIcon: Icons.receipt_long_outlined,
                emptyTitle: 'Faol buyurtma yo\'q',
                emptySubtitle: 'Yangi buyurtma bering va u shu yerda ko\'rinadi',
                isLoading: provider.isLoading,
                onRefresh: provider.refresh,
              ),
              _OrdersList(
                orders: provider.getHistoryOrders(),
                emptyIcon: Icons.history_rounded,
                emptyTitle: 'Buyurtmalar tarixi bo\'sh',
                emptySubtitle: 'Tugatilgan buyurtmalar shu yerda ko\'rinadi',
                isLoading: provider.isLoading,
                onRefresh: provider.refresh,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _OrdersList({
    required this.orders,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (orders.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, i) {
          final order = orders[i];
          return OrderCard(
            orderNumber: order.orderNumber,
            date: order.createdAt,
            summary: order.itemsSummary,
            totalPrice: order.totalPrice,
            status: order.status,
            shopName: order.shopName,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: order.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

