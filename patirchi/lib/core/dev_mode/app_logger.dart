import 'package:flutter/foundation.dart';
import 'package:patirchi/core/dev_mode/models/log_entry.dart';
import 'package:patirchi/core/dev_mode/stores/log_store.dart';

/// Markaziy logger — `debugPrint` ni ushlab oladi va structured log qo'shadi.
///
/// Foydalanish:
/// ```dart
/// AppLogger.install(LogStore.instance);
/// AppLogger.i('Foydalanuvchi tizimga kirdi', tag: 'Auth');
/// AppLogger.e('Xato yuz berdi', stackTrace: e.toString());
/// ```
class AppLogger {
  AppLogger._();

  static LogStore? _store;
  static DebugPrintCallback? _originalDebugPrint;

  // ---------------------------------------------------------------------------
  // Install / uninstall
  // ---------------------------------------------------------------------------

  /// `debugPrint` ni ushlab oladi va [store] ga yozuvlarni qo'shadi.
  static void install(LogStore store) {
    _store = store;
    _originalDebugPrint = debugPrint;
    debugPrint = _captured;
  }

  /// Asl `debugPrint` ni tiklaydi.
  static void uninstall() {
    if (_originalDebugPrint != null) {
      debugPrint = _originalDebugPrint!;
    }
    _store = null;
    _originalDebugPrint = null;
  }

  // ---------------------------------------------------------------------------
  // Captured debugPrint
  // ---------------------------------------------------------------------------

  static void _captured(String? message, {int? wrapWidth}) {
    // Avval asl debugPrint ga uzatamiz
    _originalDebugPrint?.call(message, wrapWidth: wrapWidth);
    if (message != null && message.isNotEmpty) {
      _store?.addLog(LogLevel.debug, message, tag: 'debugPrint');
    }
  }

  // ---------------------------------------------------------------------------
  // Structured log methods
  // ---------------------------------------------------------------------------

  static void d(String message, {String? tag}) {
    debugPrint('[D${tag != null ? "/$tag" : ""}] $message');
    _store?.addLog(LogLevel.debug, message, tag: tag);
  }

  static void i(String message, {String? tag}) {
    debugPrint('[I${tag != null ? "/$tag" : ""}] $message');
    _store?.addLog(LogLevel.info, message, tag: tag);
  }

  static void w(String message, {String? tag}) {
    debugPrint('[W${tag != null ? "/$tag" : ""}] $message');
    _store?.addLog(LogLevel.warn, message, tag: tag);
  }

  static void e(
    String message, {
    String? tag,
    String? stackTrace,
  }) {
    debugPrint('[E${tag != null ? "/$tag" : ""}] $message');
    if (stackTrace != null) debugPrint(stackTrace);
    _store?.addLog(
      LogLevel.error,
      message,
      tag: tag,
      stackTrace: stackTrace,
    );
  }
}
