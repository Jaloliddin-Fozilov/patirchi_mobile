import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/dev_mode_service.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_floating_button.dart';

/// Barcha ekranlar ustida developer FAB ko'rsatuvchi overlay.
///
/// [MaterialApp.builder] da ishlatiladi:
/// ```dart
/// MaterialApp(
///   builder: DevModeOverlay.wrap,
///   ...
/// )
/// ```
///
/// Developer mode o'chiq bo'lsa [child] ni o'zgartirishsiz qaytaradi.
class DevModeOverlay extends StatelessWidget {
  const DevModeOverlay({super.key, required this.child});

  final Widget child;

  /// [MaterialApp.builder] callback sifatida to'g'ridan-to'g'ri ishlatiladi.
  static Widget wrap(BuildContext context, Widget? child) {
    return DevModeOverlay(child: child ?? const SizedBox.shrink());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DevModeService.instance,
      builder: (context, _) {
        if (!DevModeService.instance.isEnabled) return child;
        return Stack(
          children: [
            child,
            const DevFloatingButton(),
          ],
        );
      },
    );
  }
}
