import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';

/// HTTP method va status kodi uchun kichik rangli pill widget.
///
/// Foydalanish:
/// ```dart
/// StatusChip.method('GET')
/// StatusChip.status(200)
/// StatusChip.status(null) // pending
/// ```
class StatusChip extends StatelessWidget {
  const StatusChip.method(
    String method, {
    super.key,
  }) : _isMethod = true,
       _methodOrStatus = method,
       _statusCode = null;

  const StatusChip.status(
    int? code, {
    super.key,
  }) : _isMethod = false,
       _methodOrStatus = null,
       _statusCode = code;

  final bool _isMethod;
  final String? _methodOrStatus;
  final int? _statusCode;

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color fg) = _isMethod
        ? _methodStyle(_methodOrStatus ?? '')
        : _statusStyle(_statusCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: DevTheme.mono.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static (String, Color, Color) _methodStyle(String method) {
    final upper = method.toUpperCase();
    final fg = DevTheme.methodColor(upper);
    final bg = DevTheme.methodBgColor(upper);
    return (upper, bg, fg);
  }

  static (String, Color, Color) _statusStyle(int? code) {
    if (code == null) {
      return ('---', const Color(0xFF1C1C24), const Color(0xFF9E9E9E));
    }

    final fg = DevTheme.statusColor(code);
    final Color bg;

    if (code >= 200 && code < 300) {
      bg = const Color(0xFF1A3028);
    } else if (code >= 300 && code < 400) {
      bg = const Color(0xFF162035);
    } else if (code >= 400 && code < 500) {
      bg = const Color(0xFF2E2010);
    } else if (code >= 500) {
      bg = const Color(0xFF2E1010);
    } else {
      bg = const Color(0xFF1C1C24);
    }

    return (code.toString(), bg, fg);
  }
}
