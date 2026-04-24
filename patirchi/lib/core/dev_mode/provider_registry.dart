/// Provider snapshot uchun ma'lumot qaytaruvchi funksiya turi.
typedef SnapshotBuilder = Map<String, dynamic> Function();

/// Bitta provider'ning snapshot spesifikatsiyasi.
class ProviderSnapshot {
  const ProviderSnapshot({
    required this.name,
    required this.builder,
  });

  final String name;
  final SnapshotBuilder builder;
}

/// Debug panelining State tab uchun provider registr.
///
/// Provider'larni ro'yxatdan o'tkazib, ularning joriy holatini
/// debugger'da ko'rsatish mumkin.
///
/// Foydalanish:
/// ```dart
/// ProviderRegistry.register(
///   'AuthProvider',
///   () => {'isLoggedIn': auth.isLoggedIn, 'role': auth.role?.name},
/// );
/// ```
class ProviderRegistry {
  ProviderRegistry._();

  static final List<ProviderSnapshot> _items = [];

  /// Ro'yxatdagi barcha snapshotlar — unmodifiable.
  static List<ProviderSnapshot> get items => List.unmodifiable(_items);

  /// Provider'ni ro'yxatdan o'tkazadi.
  /// Bir xil nom bilan qo'shilsa — eski o'chiriladi.
  static void register(String name, SnapshotBuilder builder) {
    _items.removeWhere((i) => i.name == name);
    _items.add(ProviderSnapshot(name: name, builder: builder));
  }

  /// Barcha provider'larning joriy snapshotlarini qaytaradi.
  static List<({String name, Map<String, dynamic> data})> snapshotAll() {
    return _items
        .map((i) => (name: i.name, data: _safeBuild(i.builder)))
        .toList();
  }

  /// Builder xato berib yuborsa, xato matnini qaytaradi.
  static Map<String, dynamic> _safeBuild(SnapshotBuilder b) {
    try {
      return b();
    } on Object catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Test va reload uchun — barcha registratsiyalarni tozalaydi.
  static void clear() => _items.clear();
}
