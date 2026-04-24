import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';

/// Debugger uchun tema'd button variantlari.
enum _DevButtonVariant { primary, secondary, danger, ghost }

class DevButton extends StatelessWidget {
  const DevButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _DevButtonVariant.primary;

  const DevButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _DevButtonVariant.secondary;

  const DevButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _DevButtonVariant.danger;

  const DevButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  }) : _variant = _DevButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final _DevButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color border) = switch (_variant) {
      _DevButtonVariant.primary => (
          DevTheme.accentDim,
          DevTheme.textPrimary,
          DevTheme.accent,
        ),
      _DevButtonVariant.secondary => (
          DevTheme.bgTertiary,
          DevTheme.textPrimary,
          DevTheme.borderSubtle,
        ),
      _DevButtonVariant.danger => (
          const Color(0xFF2E1010),
          DevTheme.error,
          DevTheme.error,
        ),
      _DevButtonVariant.ghost => (
          Colors.transparent,
          DevTheme.textSecondary,
          Colors.transparent,
        ),
    };

    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            else if (icon != null)
              Icon(icon, size: 14, color: fg),
            if ((icon != null || loading) && label.isNotEmpty)
              const SizedBox(width: 6),
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
