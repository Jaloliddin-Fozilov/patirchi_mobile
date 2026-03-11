import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color? activeColor;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}