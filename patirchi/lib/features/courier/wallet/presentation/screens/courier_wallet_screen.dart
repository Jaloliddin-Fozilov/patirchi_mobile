import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/features/courier/wallet/data/models/earning_model.dart';
import 'package:patirchi/features/courier/wallet/presentation/providers/wallet_provider.dart';

class CourierWalletScreen extends StatelessWidget {
  const CourierWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();
    final transactions = provider.filteredTransactions;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            _BalanceCard(balance: provider.balance),
            const SizedBox(height: 16),
            // Period selector
            Row(
              children: [
                _PeriodChip(
                  label: 'Bugun',
                  isSelected: provider.period == WalletPeriod.today,
                  onTap: () => provider.setPeriod(WalletPeriod.today),
                ),
                const SizedBox(width: 8),
                _PeriodChip(
                  label: 'Hafta',
                  isSelected: provider.period == WalletPeriod.week,
                  onTap: () => provider.setPeriod(WalletPeriod.week),
                ),
                const SizedBox(width: 8),
                _PeriodChip(
                  label: 'Oy',
                  isSelected: provider.period == WalletPeriod.month,
                  onTap: () => provider.setPeriod(WalletPeriod.month),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Earnings stats row
            _EarningsStatsRow(provider: provider),
            const SizedBox(height: 16),
            // Chart
            _EarningsChart(bars: provider.chartBars, period: provider.period),
            const SizedBox(height: 20),
            // Transactions list
            const Text(
              'Tranzaksiyalar',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "Bu davrda tranzaksiyalar yo'q",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...transactions.map((t) => _TransactionRow(earning: t)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Hamyon balansi',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            Formatters.price(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Pul yechish'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white60),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pul yechish tez kunda')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsStatsRow extends StatelessWidget {
  final WalletProvider provider;

  const _EarningsStatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _EarningBox(
          label: 'Bugungi',
          value: Formatters.priceShort(provider.todayEarnings),
          icon: Icons.today,
        ),
        const SizedBox(width: 8),
        _EarningBox(
          label: 'Haftalik',
          value: Formatters.priceShort(provider.weeklyEarnings),
          icon: Icons.date_range,
        ),
        const SizedBox(width: 8),
        _EarningBox(
          label: 'Oylik',
          value: Formatters.priceShort(provider.monthlyEarnings),
          icon: Icons.calendar_month,
        ),
      ],
    );
  }
}

class _EarningBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _EarningBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.warmBg,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsChart extends StatelessWidget {
  final List<double> bars;
  final WalletPeriod period;

  const _EarningsChart({required this.bars, required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Daromad grafigi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                bars.length,
                (i) => _ChartBar(height: bars[i], label: _barLabel(i)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _barLabel(int i) {
    switch (period) {
      case WalletPeriod.today:
        final hours = [0, 3, 6, 9, 12, 15, 18];
        return '${hours[i]}h';
      case WalletPeriod.week:
        final days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
        return days[i];
      case WalletPeriod.month:
        final weeks = ['1h', '2h', '3h', '4h', '5h', '6h', '7h'];
        return weeks[i];
    }
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
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
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
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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

class _TransactionRow extends StatelessWidget {
  final EarningModel earning;

  const _TransactionRow({required this.earning});

  @override
  Widget build(BuildContext context) {
    final isPositive = earning.amount >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(
              Icons.delivery_dining,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yetkazuv #${earning.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "${earning.isPaid ? "To'langan" : "Kutilmoqda"} · ${Formatters.dateTime(earning.createdAt)}",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${Formatters.price(earning.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
              if (earning.commission > 0)
                Text(
                  '-${Formatters.price(earning.commission)} komissiya',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
