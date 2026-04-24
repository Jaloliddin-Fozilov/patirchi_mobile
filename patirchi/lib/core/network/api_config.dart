/// API base URL konfiguratsiyasi — runtime'da o'zgartirish mumkin.
///
/// DevMode da turli muhit URL larini almashtirishga imkon beradi.
class ApiConfig {
  ApiConfig._();

  static final ApiConfig instance = ApiConfig._();

  // ---------------------------------------------------------------------------
  // Presetlar
  // ---------------------------------------------------------------------------

  static const Map<String, String> presets = {
    'production': 'https://app.patirchi.uz/api/v1',
    'staging': 'https://staging.patirchi.uz/api/v1',
    'localhost': 'http://localhost:8000/api/v1',
  };

  // ---------------------------------------------------------------------------
  // Joriy URL
  // ---------------------------------------------------------------------------

  String _baseUrl = 'https://app.patirchi.uz/api/v1';

  /// Joriy base URL.
  String get baseUrl => _baseUrl;

  /// Base URL ni o'zgartiradi.
  set baseUrl(String url) => _baseUrl = url;

  // ---------------------------------------------------------------------------
  // Preset detection
  // ---------------------------------------------------------------------------

  /// Joriy URL qaysi presetga mos kelishini qaytaradi.
  /// Hech biriga mos kelmasa — `'custom'`.
  String get currentPreset {
    for (final entry in presets.entries) {
      if (entry.value == _baseUrl) return entry.key;
    }
    return 'custom';
  }

  /// Preset nomi bo'yicha URL o'rnatadi.
  /// [presetName] `presets` da mavjud bo'lmasa — o'zgarmaydi.
  void applyPreset(String presetName) {
    final url = presets[presetName];
    if (url != null) _baseUrl = url;
  }

  /// Production URL ga qaytaradi.
  void resetToProduction() {
    _baseUrl = presets['production']!;
  }
}
