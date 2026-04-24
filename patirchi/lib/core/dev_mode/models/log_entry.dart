import 'package:flutter/material.dart';

/// Log darajasi.
enum LogLevel { debug, info, warn, error }

/// Bitta log yozuvining immutable modeli.
class LogEntry {
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.stackTrace,
    this.tag,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? stackTrace;

  /// Manba tegi (masalan, 'AuthProvider', 'ApiClient').
  final String? tag;

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  /// UI uchun rang.
  Color get color => switch (level) {
        LogLevel.debug => const Color(0xFF9E9E9E),
        LogLevel.info => const Color(0xFF2196F3),
        LogLevel.warn => const Color(0xFFFFC107),
        LogLevel.error => const Color(0xFFEF5350),
      };

  /// HH:mm:ss.SSS formatida vaqt.
  String get formattedTimestamp {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  /// Qisqa level nomi (D/I/W/E).
  String get levelShort => switch (level) {
        LogLevel.debug => 'D',
        LogLevel.info => 'I',
        LogLevel.warn => 'W',
        LogLevel.error => 'E',
      };
}
