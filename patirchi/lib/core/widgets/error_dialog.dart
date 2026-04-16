import 'package:flutter/material.dart';
import 'package:patirchi/core/error/failures.dart';
import 'package:patirchi/core/theme/app_colors.dart';

/// Xato dialog'i — [Failure] xabarini ko'rsatadi.
///
/// Foydalanish:
/// ```dart
/// ErrorDialog.show(
///   context,
///   failure: ServerFailure(message: '...'),
///   onRetry: () => myProvider.reload(),
/// );
/// ```
class ErrorDialog {
  ErrorDialog._();

  /// Xato dialog'ini ko'rsatadi.
  ///
  /// [failure] — ko'rsatiladigan xato.
  /// [onRetry] — "Qayta urinish" tugmasi bosilganda chaqiriladi (ixtiyoriy).
  static Future<void> show(
    BuildContext context, {
    required Failure failure,
    VoidCallback? onRetry,
    String? title,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _ErrorDialogWidget(
        failure: failure,
        onRetry: onRetry,
        title: title,
      ),
    );
  }

  /// Oddiy xato xabari dialog'i (Failure o'rniga string).
  static Future<void> showMessage(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onRetry,
  }) {
    return show(
      context,
      failure: ServerFailure(message: message),
      onRetry: onRetry,
      title: title,
    );
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class _ErrorDialogWidget extends StatelessWidget {
  const _ErrorDialogWidget({
    required this.failure,
    this.onRetry,
    this.title,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Xato ikonkasi
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Sarlavha
          Text(
            title ?? 'Xato yuz berdi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Xabar
          Text(
            failure.toUserMessage(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],
      ),
      actions: [
        // Yopish
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Yopish',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),

        // Qayta urinish (agar callback berilgan bo'lsa)
        if (onRetry != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Qayta urinish'),
          ),
      ],
    );
  }
}
