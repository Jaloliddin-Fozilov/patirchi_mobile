import 'package:flutter/material.dart';
import 'package:patirchi/features/buyer/home/data/datasources/buyer_home_local_datasource.dart';

class BuyerHomeServices extends StatelessWidget {
  const BuyerHomeServices({super.key});

  static const List<Color> _bgColors = [
    Color(0xFF2979FF),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Color(0xFFFF8F00),
    Color(0xFF7B1FA2),
  ];

  IconData _getServiceIcon(String name) {
    switch (name) {
      case 'storefront':
        return Icons.grid_view_rounded;
      case 'local_offer':
        return Icons.account_balance_wallet;
      case 'delivery_dining':
        return Icons.flight;
      case 'work_outline':
        return Icons.work;
      case 'star_outline':
        return Icons.local_shipping;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: BuyerHomeLocalDatasource.quickServices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final service = BuyerHomeLocalDatasource.quickServices[index];
          final iconData = _getServiceIcon(service['icon'] as String);
          return SizedBox(
            width: 76,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _bgColors[index % _bgColors.length],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    iconData,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (service['label'] as String).replaceAll('\n', ' '),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFCCCCCC),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
