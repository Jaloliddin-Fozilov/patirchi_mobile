import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/debugger_sheet.dart';

/// Sürüklenable developer FAB — Overlay ichida ishlaydi.
///
/// Ekranning istalgan joyiga sudrab olib borish mumkin.
/// Bosish bilan [DebuggerSheet] ochiladi.
class DevFloatingButton extends StatefulWidget {
  const DevFloatingButton({super.key});

  @override
  State<DevFloatingButton> createState() => _DevFloatingButtonState();
}

class _DevFloatingButtonState extends State<DevFloatingButton> {
  // Offset: negatif qiymatlar o'ng-pastga hisob qilinadi
  // dx < 0 => o'ng chekkadan, dy < 0 => pastki chekkadan
  double _dx = -72.0; // o'ng chekkadan 72px
  double _dy = -120.0; // pastki chekkadan 120px
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Haqiqiy pozitsiyani hisoblash
    final double left = _dx < 0 ? size.width + _dx : _dx;
    final double top = _dy < 0 ? size.height + _dy : _dy;

    // Xavfsiz chegaralarga qamal qilish
    final double clampedLeft = left.clamp(8.0, size.width - 64.0);
    final double clampedTop = top.clamp(
      padding.top + 8.0,
      size.height - padding.bottom - 64.0,
    );

    return Positioned(
      left: clampedLeft,
      top: clampedTop,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            _dx += details.delta.dx;
            _dy += details.delta.dy;
          });
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        onTap: () => _openDebugger(context),
        child: AnimatedScale(
          scale: _isDragging ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            elevation: 8,
            shape: const CircleBorder(),
            color: DevTheme.accent,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DevTheme.accent,
              ),
              child: const Icon(
                Icons.bug_report,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDebugger(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DevTheme.bgPrimary,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const DebuggerSheet(),
    );
  }
}
