import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import '../providers/inventory_provider.dart';
import '../../data/models/inventory_item_model.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Ombor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SummaryCard(provider: provider),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _InventoryCard(
                  item: provider.items[i],
                  provider: provider,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final InventoryProvider provider;
  const _SummaryCard({required this.provider});

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
      child: Row(
        children: [
          _SummaryItem(
            label: 'Jami',
            value: '${provider.totalCount}',
            icon: Icons.inventory_2_outlined,
          ),
          _Divider(),
          _SummaryItem(
            label: 'Kam',
            value: '${provider.lowCount}',
            icon: Icons.warning_amber_outlined,
            color: Colors.amber.shade200,
          ),
          _Divider(),
          _SummaryItem(
            label: 'Kritik',
            value: '${provider.criticalCount}',
            icon: Icons.error_outline,
            color: Colors.red.shade200,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: c, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: c,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: c.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white.withValues(alpha: 0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItemModel item;
  final InventoryProvider provider;

  const _InventoryCard({required this.item, required this.provider});

  Color get _statusColor {
    switch (item.stockStatus) {
      case StockStatus.sufficient:
        return AppColors.success;
      case StockStatus.low:
        return AppColors.warning;
      case StockStatus.critical:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (item.stockStatus) {
      case StockStatus.sufficient:
        return 'Yetarli';
      case StockStatus.low:
        return 'Kam';
      case StockStatus.critical:
        return 'Kritik';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fillRatio = (item.currentStock / (item.minStock * 2)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
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
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.inventory_2, color: _statusColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Oxirgi to'ldirish: ${Formatters.date(item.lastRestocked)}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${Formatters.weight(item.currentStock, item.unit)} / min ${Formatters.weight(item.minStock, item.unit)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fillRatio,
              backgroundColor: _statusColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              minHeight: 6,
            ),
          ),
          if (item.stockStatus != StockStatus.sufficient) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showOrderDialog(context),
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: const Text("Xomashyo buyurtma"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.bakeryAccent,
                  side: const BorderSide(color: AppColors.bakeryAccent),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buyurtma tasdiqlash'),
        content: Text(
          '${item.name} uchun ta\'minotchiga buyurtma yuborilsinmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.orderSupply(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${item.name} uchun buyurtma yuborildi"),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bakeryAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buyurtma berish'),
          ),
        ],
      ),
    );
  }
}
