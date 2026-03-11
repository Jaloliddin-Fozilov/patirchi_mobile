import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        border: outlined ? Border.all(color: color) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: outlined ? color : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}