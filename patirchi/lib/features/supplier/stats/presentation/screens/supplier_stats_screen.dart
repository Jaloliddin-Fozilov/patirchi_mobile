import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/core/widgets/stats_card.dart';
import 'package:patirchi/features/supplier/stats/presentation/providers/supplier_stats_provider.dart';

class SupplierStatsScreen extends StatelessWidget {
  const SupplierStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SupplierStatsProvider(),
      child: const _SupplierStatsView(),
    );
  }
}

class _SupplierStatsView extends StatelessWidget {
  const _SupplierStatsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierStatsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          Row(
            children: [
              _PeriodChip(
                label: 'Bugun',
                isSelected: provider.period == StatsPeriod.today,
                onTap: () =>
                    provider.setPeriod(StatsPeriod.today),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: 'Hafta',
                isSelected: provider.period == StatsPeriod.week,
                onTap: () =>
                    provider.setPeriod(StatsPeriod.week),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: 'Oy',
                isSelected: provider.period == StatsPeriod.month,
                onTap: () =>
                    provider.setPeriod(StatsPeriod.month),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Revenue card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.supplierAccent, Color(0xFFAD1457)],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.supplierAccent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Umumiy daromad',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '+${provider.revenueChange}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Formatters.price(provider.totalRevenue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats grid
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  value: provider.orderCount.toString(),
                  label: 'Buyurtmalar',
                  backgroundColor: AppColors.supplierAccent.withValues(alpha: 0.1),
                  textColor: AppColors.supplierAccent,
                  icon: Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  value: Formatters.priceShort(provider.avgOrderValue),
                  label: "O'rtacha buyurtma",
                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  textColor: AppColors.info,
                  icon: Icons.analytics_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  value: provider.activeCustomers.toString(),
                  label: 'Faol mijozlar',
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  textColor: AppColors.success,
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  value: Formatters.priceShort(provider.totalRevenue),
                  label: 'Umumiy sotuvlar',
                  backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                  textColor: AppColors.warning,
                  icon: Icons.monetization_on_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Trend chart
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buyurtmalar trendi',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      provider.chartBars.length,
                      (i) => _ChartBar(
                        height: provider.chartBars[i],
                        label: _barLabel(provider.period, i),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Top selling products
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ko\'p sotiladigan mahsulotlar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 16),
                ...provider.topProducts.map(
                  (stat) => _TopProductRow(stat: stat),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _barLabel(StatsPeriod period, int index) {
    switch (period) {
      case StatsPeriod.today:
        final hours = [8, 10, 12, 14, 16, 18, 20];
        return '${hours[index]}h';
      case StatsPeriod.week:
        final days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
        return days[index];
      case StatsPeriod.month:
        final weeks = ['1h', '2h', '3h', '4h', '5h', '6h', '7h'];
        return weeks[index];
    }
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.supplierAccent : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.supplierAccent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final double height;
  final String label;

  const _ChartBar({required this.height, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 90 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.supplierAccent,
                AppColors.supplierAccent.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final ProductSalesStat stat;

  const _TopProductRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stat.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                Formatters.priceShort(stat.revenue),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.supplierAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.warmBg,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: stat.relativeShare,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.supplierAccent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
