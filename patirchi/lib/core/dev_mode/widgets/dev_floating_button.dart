import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/app_navigator_key.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/debugger_sheet.dart';

/// Developer FAB — barcha ekranlar ustida ko'rinadigan tugma.
///
/// Dizayn qarorlari:
/// - **Fixed position** (bottom-right, safe-area + padding): drag yo'q.
///   DevTools, Android Profiler kabi professional asboblar drag qilmaydi.
/// - **Material InkWell**: Flutter'ning standart va eng ishonchli tap
///   handler. Ripple effect + tap state Material Design'ga mos.
/// - **`rootNavigator: true`**: modal eng yuqori Navigator'da ochiladi —
///   overlay/builder context muammolari yo'q.
/// - **Try/catch logging**: agar modal ochilmasa, debug log'da aniq xato.
class DevFloatingButton extends StatelessWidget {
  const DevFloatingButton({super.key});

  static const double _size = 56.0;
  static const double _bottomPadding = 100.0; // Bottom nav ustida turish uchun
  static const double _rightPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Positioned(
      right: _rightPadding,
      bottom: padding.bottom + _bottomPadding,
      child: _DevFab(onTap: () => _openDebugger(context)),
    );
  }

  void _openDebugger(BuildContext fallbackContext) {
    debugPrint('[DevFAB] Opening debugger...');

    // MUHIM: `MaterialApp.builder` ABOVE Navigator deb chaqiriladi, shu sababli
    // FAB build context'ida `Navigator.of(context)` ancestor topa olmaydi va
    // release rejimda "Null check operator used on a null value" xatosi
    // chiqaradi. Buning oldini olish uchun global [appNavigatorKey] orqali
    // overlay context'ini olamiz — u Navigator BELOW da joylashgan.
    final navigator = appNavigatorKey.currentState;
    final overlayContext = navigator?.overlay?.context;

    if (overlayContext == null) {
      debugPrint('[DevFAB] ERROR: appNavigatorKey not attached');
      if (fallbackContext.mounted) {
        ScaffoldMessenger.of(fallbackContext).showSnackBar(
          const SnackBar(
            content: Text('Debugger tayyor emas (navigator topilmadi)'),
            backgroundColor: DevTheme.error,
          ),
        );
      }
      return;
    }

    try {
      showModalBottomSheet<void>(
        context: overlayContext,
        isScrollControlled: true,
        // useRootNavigator: false — overlayContext allaqachon root Navigator
        // ostidagi context'dir; true qilsak yana bir bor yuqoriga walk qiladi
        // va xato qaytishi mumkin.
        useRootNavigator: false,
        backgroundColor: DevTheme.bgPrimary,
        barrierColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const DebuggerSheet(),
      ).then((_) {
        debugPrint('[DevFAB] Debugger closed');
      });
      debugPrint('[DevFAB] Modal opened successfully');
    } on Object catch (e, stack) {
      debugPrint('[DevFAB] ERROR opening debugger: $e');
      debugPrintStack(stackTrace: stack, label: 'DevFAB');
      if (fallbackContext.mounted) {
        ScaffoldMessenger.of(fallbackContext).showSnackBar(
          SnackBar(
            content: Text('Debugger ochilmadi: $e'),
            backgroundColor: DevTheme.error,
          ),
        );
      }
    }
  }
}

/// Material InkWell-based FAB widget — standart Flutter pattern.
class _DevFab extends StatelessWidget {
  const _DevFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      // SafeArea uchun shadow Material'da ishlamaydi, BoxDecoration'da
      child: Container(
        width: DevFloatingButton._size,
        height: DevFloatingButton._size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: DevTheme.accent.withValues(alpha: 0.4),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Material(
          color: DevTheme.accent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withValues(alpha: 0.3),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: const SizedBox(
              width: DevFloatingButton._size,
              height: DevFloatingButton._size,
              child: Icon(
                Icons.bug_report_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
