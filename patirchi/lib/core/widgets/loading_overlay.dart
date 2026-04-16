import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';

/// To'liq ekranli yuklash overlay'i.
///
/// Statik metodlar orqali ko'rsatiladi va yashiriladi:
/// ```dart
/// LoadingOverlay.show(context);
/// await someAsyncCall();
/// LoadingOverlay.hide(context);
/// ```
///
/// Yoki [LoadingOverlay.run] yordamida:
/// ```dart
/// final result = await LoadingOverlay.run(context, () => apiCall());
/// ```
class LoadingOverlay {
  LoadingOverlay._();

  static OverlayEntry? _entry;

  // ---------------------------------------------------------------------------
  // Statik metodlar
  // ---------------------------------------------------------------------------

  /// Overlay'ni ko'rsatadi.
  ///
  /// [message] — ixtiyoriy matn (masalan: "Yuborilmoqda...").
  static void show(BuildContext context, {String? message}) {
    if (_entry != null) return; // allaqachon ko'rsatilgan

    _entry = OverlayEntry(
      builder: (_) => _LoadingOverlayWidget(message: message),
    );

    Overlay.of(context).insert(_entry!);
  }

  /// Overlay'ni yashiradi.
  static void hide(BuildContext context) {
    _entry?.remove();
    _entry = null;
  }

  /// Async operatsiyani overlay bilan bajaradi.
  ///
  /// Operatsiya tugaganidan keyin overlay avtomatik yashiriladi.
  static Future<T> run<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? message,
  }) async {
    show(context, message: message);
    try {
      return await operation();
    } finally {
      hide(context);
    }
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class _LoadingOverlayWidget extends StatelessWidget {
  const _LoadingOverlayWidget({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent qora fon
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  strokeWidth: 3,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
