import 'package:flutter/foundation.dart';
import 'package:patirchi/core/storage/secure_storage_service.dart';

/// Developer mode'ni boshqaruvchi singleton servis.
///
/// Faollashtirish: 3 soniya ichida 10 ta tap.
/// Holat [SecureStorageService] da saqlanadi.
class DevModeService extends ChangeNotifier {
  DevModeService._();

  static final DevModeService instance = DevModeService._();

  // ---------------------------------------------------------------------------
  // Konfiguratsiya
  // ---------------------------------------------------------------------------

  static const int _requiredTaps = 10;
  static const Duration _tapWindow = Duration(seconds: 3);

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _enabled = false;
  int _tapCount = 0;
  DateTime? _firstTapAt;

  /// Developer mode yoqilganmi?
  bool get isEnabled => _enabled;

  /// Joriy tap hisobi (debug uchun).
  int get tapCount => _tapCount;

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  /// Saqlangan dev mode holatini yuklaydi.
  /// [main()] da `runApp` dan oldin chaqirilishi kerak.
  Future<void> init() async {
    _enabled = await SecureStorageService.instance.getDevMode();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Activation
  // ---------------------------------------------------------------------------

  /// Har bir tap da chaqiriladi.
  ///
  /// Agar [_requiredTaps] ta tap [_tapWindow] ichida bo'lsa — faollashtiradi.
  /// Qaytaradi: `true` — hozir faollashdi, `false` — hali emas.
  Future<bool> registerTap() async {
    if (_enabled) return false;

    final now = DateTime.now();

    if (_firstTapAt == null ||
        now.difference(_firstTapAt!) > _tapWindow) {
      // Yangi seriya boshlaydi
      _firstTapAt = now;
      _tapCount = 1;
      return false;
    }

    _tapCount++;

    if (_tapCount >= _requiredTaps) {
      _enabled = true;
      _tapCount = 0;
      _firstTapAt = null;
      await SecureStorageService.instance.setDevMode(true);
      notifyListeners();
      return true;
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // Disable
  // ---------------------------------------------------------------------------

  /// Developer mode ni o'chiradi va storage dan tozalaydi.
  Future<void> disable() async {
    _enabled = false;
    _tapCount = 0;
    _firstTapAt = null;
    await SecureStorageService.instance.setDevMode(false);
    notifyListeners();
  }
}
