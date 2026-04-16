import 'dart:convert';

/// Token va foydalanuvchi ma'lumotlarini xavfsiz saqlash xizmati.
///
/// Hozir xotirada saqlanadi (in-memory) — production'da
/// `flutter_secure_storage` yoki `flutter_keychain` bilan almashtiriladi.
/// Interfeys barqaror qoladi, faqat bu fayl o'zgaradi.
///
/// Foydalanish:
/// ```dart
/// final storage = SecureStorageService.instance;
/// await storage.saveToken('eyJ...');
/// final token = await storage.getToken();
/// ```
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  // ---------------------------------------------------------------------------
  // Kalit konstantalar
  // ---------------------------------------------------------------------------

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'current_user';

  // ---------------------------------------------------------------------------
  // In-memory saqlash (placeholder)
  // ---------------------------------------------------------------------------

  final Map<String, String> _store = {};

  // ---------------------------------------------------------------------------
  // Token operatsiyalari
  // ---------------------------------------------------------------------------

  /// Access tokenni saqlaydi.
  Future<void> saveToken(String token) async {
    _store[_keyAccessToken] = token;
  }

  /// Saqlangan access tokenni qaytaradi. Mavjud bo'lmasa `null`.
  Future<String?> getToken() async {
    return _store[_keyAccessToken];
  }

  /// Refresh tokenni saqlaydi.
  Future<void> saveRefreshToken(String token) async {
    _store[_keyRefreshToken] = token;
  }

  /// Saqlangan refresh tokenni qaytaradi. Mavjud bo'lmasa `null`.
  Future<String?> getRefreshToken() async {
    return _store[_keyRefreshToken];
  }

  /// Tokenlarni o'chiradi.
  Future<void> deleteToken() async {
    _store.remove(_keyAccessToken);
    _store.remove(_keyRefreshToken);
  }

  // ---------------------------------------------------------------------------
  // Foydalanuvchi ma'lumotlari
  // ---------------------------------------------------------------------------

  /// Foydalanuvchi ma'lumotlarini JSON string sifatida saqlaydi.
  Future<void> saveUser(Map<String, dynamic> userJson) async {
    _store[_keyUser] = jsonEncode(userJson);
  }

  /// [saveUser] bilan bir xil — API integratsiyasida qulaylik uchun alias.
  Future<void> saveUserJson(Map<String, dynamic> userJson) => saveUser(userJson);

  /// Saqlangan foydalanuvchi ma'lumotlarini qaytaradi. Mavjud bo'lmasa `null`.
  Future<Map<String, dynamic>?> getUser() async {
    final raw = _store[_keyUser];
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null;
    }
  }

  /// [getUser] bilan bir xil — API integratsiyasida qulaylik uchun alias.
  Future<Map<String, dynamic>?> getUserJson() => getUser();

  /// Foydalanuvchi ma'lumotlarini o'chiradi.
  Future<void> deleteUser() async {
    _store.remove(_keyUser);
  }

  // ---------------------------------------------------------------------------
  // Umumiy operatsiyalar
  // ---------------------------------------------------------------------------

  /// Boshqa (custom) qiymatni saqlaydi.
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  /// Saqlangan qiymatni o'qiydi. Mavjud bo'lmasa `null`.
  Future<String?> read(String key) async {
    return _store[key];
  }

  /// Bitta yozuvni o'chiradi.
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  /// Barcha ma'lumotlarni tozalaydi (logout).
  Future<void> clear() async {
    _store.clear();
  }

  // ---------------------------------------------------------------------------
  // Login holati
  // ---------------------------------------------------------------------------

  /// Sinxron: hozirgi vaqtda token bormi?
  ///
  /// In-memory saqlashda sinxron tekshirish mumkin.
  /// flutter_secure_storage ga o'tganda async versiya ishlating.
  bool get isLoggedIn {
    final token = _store[_keyAccessToken];
    return token != null && token.isNotEmpty;
  }

  /// Async versiya — eski kod bilan moslik uchun.
  Future<bool> get isLoggedInAsync async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
