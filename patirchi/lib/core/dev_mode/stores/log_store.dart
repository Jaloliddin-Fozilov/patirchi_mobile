import 'package:flutter/foundation.dart';
import 'package:patirchi/core/dev_mode/models/log_entry.dart';

/// App log yozuvlarini saqlaydigan circular-buffer store.
///
/// Singleton — [LogStore.instance] orqali foydalaniladi.
class LogStore extends ChangeNotifier {
  LogStore._();

  static final LogStore instance = LogStore._();

  static const int _maxEntries = 500;

  final List<LogEntry> _entries = [];

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Barcha yozuvlar (so'nggi birinchi) — unmodifiable.
  List<LogEntry> get entries => List.unmodifiable(_entries);

  int get count => _entries.length;

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Log yozuvi qo'shadi.
  void addLog(
    LogLevel level,
    String message, {
    String? tag,
    String? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      stackTrace: stackTrace,
      tag: tag,
    );
    _entries.insert(0, entry);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    notifyListeners();
  }

  /// Barcha yozuvlarni tozalaydi.
  void clear() {
    _entries.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Filter helpers
  // ---------------------------------------------------------------------------

  /// Level bo'yicha filtrlaydi.
  List<LogEntry> byLevel(LogLevel level) =>
      _entries.where((e) => e.level == level).toList();

  /// Matn bo'yicha qidiradi.
  List<LogEntry> search(String query) {
    if (query.isEmpty) return entries;
    final q = query.toLowerCase();
    return _entries
        .where(
          (e) =>
              e.message.toLowerCase().contains(q) ||
              (e.tag?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
}
