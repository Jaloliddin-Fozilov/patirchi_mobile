import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';

/// SnackBar ko'rsatish uchun statik yordamchi.
///
/// Foydalanish:
/// ```dart
/// SnackBarHelper.showSuccess(context, 'Buyurtma berildi!');
/// SnackBarHelper.showError(context, 'Xato yuz berdi.');
/// ```
class SnackBarHelper {
  SnackBarHelper._();

  // ---------------------------------------------------------------------------
  // Muvaffaqiyat
  // ---------------------------------------------------------------------------

  /// Yashil muvaffaqiyat xabari.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  // ---------------------------------------------------------------------------
  // Xato
  // ---------------------------------------------------------------------------

  /// Qizil xato xabari.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  // ---------------------------------------------------------------------------
  // Ogohlantirish
  // ---------------------------------------------------------------------------

  /// Sariq ogohlantirish xabari.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      textColor: Colors.black87,
      iconColor: Colors.black87,
    );
  }

  // ---------------------------------------------------------------------------
  // Ma'lumot
  // ---------------------------------------------------------------------------

  /// Ko'k ma'lumot xabari.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline_rounded,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  // ---------------------------------------------------------------------------
  // Ichki amalga oshirish
  // ---------------------------------------------------------------------------

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    // Mavjud SnackBar'ni yashirish
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor.withValues(alpha: 0.9),
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
