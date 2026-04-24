import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/dev_mode_service.dart';

/// Istalgan widget'ni o'rab, developer mode faollashtirish uchun
/// yashirin tap hisoblagichini qo'shadi.
///
/// 3 soniya ichida 10 ta tap qilsa — developer mode faollashadi.
///
/// Foydalanish:
/// ```dart
/// DevTapDetector(
///   child: Text('App version 1.0.0'),
/// )
/// ```
class DevTapDetector extends StatelessWidget {
  const DevTapDetector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final activated = await DevModeService.instance.registerTap();
        if (activated && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔧 Developer mode faollashtirildi'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      },
      child: child,
    );
  }
}
