import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/debugger_sheet.dart';

/// Sürüklenable developer FAB — Overlay ichida ishlaydi.
///
/// Tap (qisqa bosish, < 10 px harakat) → [DebuggerSheet] ochiladi.
/// Drag (10 px+ harakat) → FAB ko'chiriladi.
///
/// `Listener` ishlatildi (yuqori darajadagi pointer events) chunki
/// `GestureDetector.onTap + onPan` ba'zi qurilmalarda konflikt qiladi.
class DevFloatingButton extends StatefulWidget {
  const DevFloatingButton({super.key});

  @override
  State<DevFloatingButton> createState() => _DevFloatingButtonState();
}

class _DevFloatingButtonState extends State<DevFloatingButton> {
  // Negatif: o'ng/pastki chekka tomondan offset
  double _dx = -72.0;
  double _dy = -120.0;
  bool _isPressed = false;

  // Tap vs drag detection
  Offset? _pressStart;
  bool _movedEnough = false;
  static const double _tapSlop = 10.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    final double left = _dx < 0 ? size.width + _dx : _dx;
    final double top = _dy < 0 ? size.height + _dy : _dy;

    final double clampedLeft = left.clamp(8.0, size.width - 64.0);
    final double clampedTop = top.clamp(
      padding.top + 8.0,
      size.height - padding.bottom - 64.0,
    );

    return Positioned(
      left: clampedLeft,
      top: clampedTop,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _pressStart = event.position;
          _movedEnough = false;
          setState(() => _isPressed = true);
        },
        onPointerMove: (event) {
          if (_pressStart == null) return;
          final delta = event.position - _pressStart!;
          if (!_movedEnough && delta.distance > _tapSlop) {
            _movedEnough = true;
          }
          if (_movedEnough) {
            setState(() {
              _dx += event.delta.dx;
              _dy += event.delta.dy;
            });
          }
        },
        onPointerUp: (_) {
          final wasMoving = _movedEnough;
          setState(() => _isPressed = false);
          _pressStart = null;
          _movedEnough = false;
          if (!wasMoving) {
            _openDebugger(context);
          }
        },
        onPointerCancel: (_) {
          setState(() => _isPressed = false);
          _pressStart = null;
          _movedEnough = false;
        },
        child: AnimatedScale(
          scale: _isPressed ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DevTheme.accent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
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
            child: const Icon(
              Icons.bug_report,
              color: Colors.white,
              size: 28,
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
