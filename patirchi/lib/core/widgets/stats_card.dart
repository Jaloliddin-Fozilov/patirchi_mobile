import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class StatsCard extends StatelessWidget {
  final String value;
  final String label;
  final Color backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final String? change;
  final bool isPositive;

  const StatsCard({
    super.key,
    required this.value,
    required this.label,
    required this.backgroundColor,
    this.textColor,
    this.icon,
    this.change,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = textColor ?? Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: fgColor, size: 20),
            ),
          Text(
            value,
            style: TextStyle(
              color: fgColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: fgColor.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 4),
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: fgColor,
                  size: 12,
                ),
                Text(
                  change!,
                  style: TextStyle(color: fgColor, fontSize: 11),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}