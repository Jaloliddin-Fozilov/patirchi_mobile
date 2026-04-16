import 'package:flutter/material.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/features/auth/data/models/user_model.dart';
import 'package:patirchi/features/auth/data/repositories/auth_repository.dart';

/// Autentifikatsiya holati va operatsiyalarini boshqaruvchi Provider.
///
/// OTP asosidagi auth oqimi:
/// 1. [selectRole] — rol tanlash (`ordinary` / `business`)
/// 2. [login] — telefon yuborish → backend OTP yuboradi → [otpSecret] saqlanadi
/// 3. [confirmOtp] — OTP kiritish → tokenlar saqlanadi → /home ga o'tish
///
/// Ilovani qayta ishga tushirganda:
/// - [tryAutoLogin] — token bormi tekshiradi → getMe() → muvaffaqiyatli bo'lsa /home
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  // ---------------------------------------------------------------------------
  // Holat
  // ---------------------------------------------------------------------------

  bool _isLoading = false;
  UserModel? _currentUser;
  String _selectedRole = 'ordinary';

  /// Login 1-qadam javobidan kelgan maxfiy kalit.
  String? _otpSecret;

  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // Getter'lar
  // ---------------------------------------------------------------------------

  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && _repository.isLoggedIn;
  String get selectedRole => _selectedRole;

  /// OTP ekraniga o'tganda ishlatiladi.
  String? get otpSecret => _otpSecret;

  String? get errorMessage => _errorMessage;

  /// Navigatsiya uchun UserRole enum qiymati.
  ///
  /// Backend roli (`ordinary`, `business`, `hybrid`, `delivery`, `admin`)
  /// ni ilovaning UserRole enum ga moslashtiradi.
  UserRole get currentUserRole {
    final role = _currentUser?.role ?? _selectedRole;
    return switch (role) {
      'delivery' => UserRole.courier,
      'business' || 'hybrid' => UserRole.bakery,
      _ => UserRole.buyer,
    };
  }

  // ---------------------------------------------------------------------------
  // Rol tanlash
  // ---------------------------------------------------------------------------

  /// Kirish uchun rol tanlaydi: `ordinary` yoki `business`.
  void selectRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  /// Profil ekranidan rol almashtirish (enum asosida).
  ///
  /// Eski kod bilan orqaga mos kelish uchun saqlanadi.
  void switchRole(UserRole role) {
    _selectedRole = switch (role) {
      UserRole.buyer => 'ordinary',
      UserRole.bakery || UserRole.supplier => 'business',
      UserRole.courier => 'delivery',
    };
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Login (OTP yuborish — 1-qadam)
  // ---------------------------------------------------------------------------

  /// Telefon raqamiga OTP yuboradi.
  ///
  /// Muvaffaqiyatli bo'lsa `true` qaytaradi va [otpSecret] saqlanadi.
  /// Caller OTP ekraniga navigate qilishi kerak.
  Future<bool> login(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    final result = await _repository.login(phoneNumber, _selectedRole);

    return result.fold(
      onSuccess: (response) {
        _otpSecret = response.secret;
        _setLoading(false);
        return true;
      },
      onError: (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // OTP tasdiqlash (2-qadam)
  // ---------------------------------------------------------------------------

  /// OTP kodni tasdiqlaydi va foydalanuvchini tizimga kiritadi.
  ///
  /// Muvaffaqiyatli bo'lsa `true` qaytaradi.
  /// Caller `/home` ga navigate qilishi kerak.
  Future<bool> confirmOtp(String otp) async {
    if (_otpSecret == null) {
      _setError('OTP secret topilmadi. Iltimos, qaytadan urinib ko\'ring.');
      return false;
    }

    _setLoading(true);
    _clearError();

    final result = await _repository.confirmOtp(_otpSecret!, otp);

    return result.fold(
      onSuccess: (user) {
        _currentUser = user;
        _otpSecret = null;
        _setLoading(false);
        return true;
      },
      onError: (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // OTP qayta yuborish
  // ---------------------------------------------------------------------------

  /// OTP ni qayta yuboradi (timer tugaganda).
  Future<bool> resendOtp(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    final result = await _repository.login(phoneNumber, _selectedRole);

    return result.fold(
      onSuccess: (response) {
        _otpSecret = response.secret;
        _setLoading(false);
        return true;
      },
      onError: (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Ro'yxatdan o'tish
  // ---------------------------------------------------------------------------

  /// Yangi hisob yaratadi.
  ///
  /// Muvaffaqiyatli bo'lsa `true` qaytaradi.
  /// Caller login ekraniga navigate qilishi kerak.
  Future<bool> signup(
    String phoneNumber,
    String password,
    String passwordConfirm,
  ) async {
    _setLoading(true);
    _clearError();

    final result =
        await _repository.signup(phoneNumber, password, passwordConfirm);

    return result.fold(
      onSuccess: (_) {
        _setLoading(false);
        return true;
      },
      onError: (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Auto login (splash ekranda)
  // ---------------------------------------------------------------------------

  /// Token bormi tekshiradi, agar bor bo'lsa profil oladi.
  ///
  /// `/splash` ekranda chaqiriladi.
  /// `true` — /home ga o'tish, `false` — /role-selection ga o'tish.
  Future<bool> tryAutoLogin() async {
    if (!_repository.isLoggedIn) {
      // Avval cache'dan tekshir
      final stored = await _repository.getStoredUser();
      if (stored == null) return false;
    }

    _setLoading(true);

    final result = await _repository.getMe();

    return result.fold(
      onSuccess: (user) {
        _currentUser = user;
        _setLoading(false);
        return true;
      },
      onError: (_) {
        _setLoading(false);
        return false;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tizimdan chiqish
  // ---------------------------------------------------------------------------

  /// Foydalanuvchini tizimdan chiqaradi.
  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _otpSecret = null;
    _clearError();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Profil yangilash
  // ---------------------------------------------------------------------------

  /// Lokal profil ma'lumotlarini yangilaydi.
  void updateProfile({
    String? firstName,
    String? lastName,
    String? profilePicture,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      firstName: firstName,
      lastName: lastName,
      profilePicture: profilePicture,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Yordamchi metodlar
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
