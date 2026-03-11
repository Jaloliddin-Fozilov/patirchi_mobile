import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/widgets/stats_card.dart';
import 'package:patirchi/core/widgets/order_card.dart';
import 'package:patirchi/core/widgets/category_chip.dart';

class BakeryOrdersScreen extends StatefulWidget {
  const BakeryOrdersScreen({super.key});

  @override
  State<BakeryOrdersScreen> createState() => _BakeryOrdersScreenState();
}

class _BakeryOrdersScreenState extends State<BakeryOrdersScreen> {
  int _selectedTab = 0;
  bool _showIncoming = true;

  final _statusFilters = ['Yangi', 'Jarayonda', 'Yetkazilgan', 'Qaytarilgan'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Buyurtmalar Panel',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  value: '3',
                  label: 'SONI',
                  backgroundColor: AppColors.bakeryAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatsCard(
                  value: '60k',
                  label: 'TUSHUM',
                  backgroundColor: AppColors.success.withValues(alpha: 0.15),
                  textColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatsCard(
                  value: '20.0k',
                  label: "O'RTACHA",
                  backgroundColor: AppColors.warning.withValues(alpha: 0.15),
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OrderCard(
                orderNumber: '4',
                date: DateTime(2026, 2, 28, 13, 33),
                summary: 'qoqon patir: 7 x 5,000 = 35,000 so\'m',
                totalPrice: 35000,
                status: OrderStatus.pending,
              ),
              OrderCard(
                orderNumber: '3',
                date: DateTime(2026, 2, 27, 21, 52),
                summary: 'qoqon patir: 4 x 5,000 = 20,000 so\'m',
                totalPrice: 20000,
                status: OrderStatus.pending,
              ),
              OrderCard(
                orderNumber: '2',
                date: DateTime(2026, 2, 26, 14, 2),
                summary: 'tandir non: 3 x 3,000 = 9,000 so\'m',
                totalPrice: 9000,
                status: OrderStatus.delivered,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String text;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn(this.text,
      {required this.isActive, required this.color, required this.onTap});

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
