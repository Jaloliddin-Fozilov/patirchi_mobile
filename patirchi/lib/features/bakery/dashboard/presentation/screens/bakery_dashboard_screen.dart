import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/stats_card.dart';

class BakeryDashboardScreen extends StatelessWidget {
  const BakeryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bakeryAccent, Color(0xFF448AFF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2,501,000 so\'m',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ochiq buyurtmalar summasi',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '1,500,500 qabul qilindi - 65% oldindan to\'lov',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Statistics chart placeholder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                      child: const Icon(Icons.bar_chart,
                          color: AppColors.bakeryAccent),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Statistika',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('O\'sish  2.11%',
                            style: TextStyle(
                                color: AppColors.success, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Simple bar chart placeholder
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Bar(0.5, 0.3, '1/9'),
                      _Bar(0.7, 0.5, '2/9'),
                      _Bar(0.4, 0.6, '3/9'),
                      _Bar(0.8, 0.4, '4/9'),
                      _Bar(0.6, 0.7, '5/9'),
                      _Bar(0.9, 0.5, '6/9'),
                      _Bar(0.7, 0.8, '7/9'),
                    ],
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
                  value: '5,560,500',
                  label: 'Daromad',
                  backgroundColor: AppColors.bakeryAccent,
                  change: '11.5%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  value: '5,560,500',
                  label: 'Xarajat',
                  backgroundColor: Colors.grey.shade100,
                  textColor: AppColors.textPrimary,
                  change: '11.5%',
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  value: '15.41 M',
                  label: 'Sarmoya',
                  backgroundColor: Colors.white,
                  textColor: AppColors.textPrimary,
                  icon: Icons.account_balance,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  value: '1.50 M',
                  label: 'Foyda',
                  backgroundColor: Colors.white,
                  textColor: AppColors.textPrimary,
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double h1;
  final double h2;
  final String label;
  const _Bar(this.h1, this.h2, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 12,
              height: 100 * h1,
              decoration: BoxDecoration(
                color: AppColors.bakeryAccent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 12,
              height: 100 * h2,
              decoration: BoxDecoration(
                color: AppColors.supplierAccent.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
