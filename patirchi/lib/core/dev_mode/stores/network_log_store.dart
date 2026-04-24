import 'package:flutter/foundation.dart';
import 'package:patirchi/core/dev_mode/models/network_log_entry.dart';

/// Network so'rovlarini saqlaydigan circular-buffer store.
///
/// Singleton — [NetworkLogStore.instance] orqali foydalaniladi.
/// [ChangeNotifier] extends qiladi, shu sababli Provider bilan ishlaydi.
class NetworkLogStore extends ChangeNotifier {
  NetworkLogStore._();

  static final NetworkLogStore instance = NetworkLogStore._();

  static const int _maxEntries = 500;

  final List<NetworkLogEntry> _entries = [];

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Barcha yozuvlar (so'nggi birinchi) — unmodifiable.
  List<NetworkLogEntry> get entries => List.unmodifiable(_entries);

  int get count => _entries.length;

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Yangi entry qo'shadi (oxiriga emas — boshiga, yangi birinchi).
  void add(NetworkLogEntry entry) {
    _entries.insert(0, entry);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    notifyListeners();
  }

  /// ID bo'yicha in-flight entry'ni yangilaydi.
  void update(
    String id,
    NetworkLogEntry Function(NetworkLogEntry) updater,
  ) {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _entries[idx] = updater(_entries[idx]);
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

  /// Status kategoriyasi bo'yicha filtrlaydi.
  List<NetworkLogEntry> byStatusCategory(String category) =>
      _entries.where((e) => e.statusCategory == category).toList();

  /// HTTP metodi bo'yicha filtrlaydi (GET/POST/...).
  List<NetworkLogEntry> byMethod(String method) =>
      _entries
          .where((e) => e.method.toUpperCase() == method.toUpperCase())
          .toList();

  /// URL yoki path bo'yicha qidiradi (case-insensitive).
  List<NetworkLogEntry> search(String query) {
    if (query.isEmpty) return entries;
    final q = query.toLowerCase();
    return _entries
        .where(
          (e) =>
              e.url.toLowerCase().contains(q) ||
              e.path.toLowerCase().contains(q),
        )
        .toList();
  }
}
