// Autentifikatsiya so'rovlari uchun model sinflari.
//
// Barcha modellar snake_case kalitlari bilan `toJson()` qaytaradi
// (Django REST Framework standartiga mos).

// ---------------------------------------------------------------------------
// Login (OTP yuborish)
// ---------------------------------------------------------------------------

/// `POST /auth/login/` uchun so'rov modeli.
///
/// Backend javobi: `{phone_number, role, secret}`
class LoginRequest {
  const LoginRequest({
    required this.phoneNumber,
    required this.role,
  });

  /// Telefon raqami: `+998XXXXXXXXX` formatida.
  final String phoneNumber;

  /// Foydalanuvchi roli: `ordinary` yoki `business`.
  final String role;

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'role': role,
      };

  @override
  String toString() => 'LoginRequest(phone: $phoneNumber, role: $role)';
}

// ---------------------------------------------------------------------------
// OTP tasdiqlash
// ---------------------------------------------------------------------------

/// `POST /auth/login/confirm/` uchun so'rov modeli.
///
/// Backend javobi: `{id, phone_number, access, refresh}`
class LoginConfirmRequest {
  const LoginConfirmRequest({
    required this.secret,
    required this.otp,
  });

  /// Login javobidan kelgan maxfiy kalit.
  final String secret;

  /// Foydalanuvchi kiritgan 4 raqamli OTP kod.
  final String otp;

  Map<String, dynamic> toJson() => {
        'secret': secret,
        'otp': otp,
      };

  @override
  String toString() => 'LoginConfirmRequest(otp: $otp)';
}

// ---------------------------------------------------------------------------
// Ro'yxatdan o'tish
// ---------------------------------------------------------------------------

/// `POST /auth/signup/` uchun so'rov modeli.
///
/// Backend javobi: `{detail: "..."}`
class SignupRequest {
  const SignupRequest({
    required this.phoneNumber,
    required this.password,
    required this.passwordConfirm,
  });

  /// Telefon raqami: `+998XXXXXXXXX` formatida.
  final String phoneNumber;

  /// Parol.
  final String password;

  /// Parolni tasdiqlash.
  final String passwordConfirm;

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'password': password,
        'password_confirm': passwordConfirm,
      };

  @override
  String toString() => 'SignupRequest(phone: $phoneNumber)';
}

// ---------------------------------------------------------------------------
// Eski mos kelish (legacy aliases)
// ---------------------------------------------------------------------------

/// Eski [LoginRequest] — parol asosidagi kirish uchun saqlangan.
/// OTP asosidagi tizimda ishlatilmaydi.
@Deprecated('Use LoginRequest (OTP-based) instead')
class PasswordLoginRequest {
  const PasswordLoginRequest({
    required this.phone,
    required this.password,
  });

  final String phone;
  final String password;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
      };
}

/// Eski [RegisterRequest] — eski API bilan mos kelish uchun.
@Deprecated('Use SignupRequest instead')
class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.phone,
    required this.password,
  });

  final String name;
  final String phone;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'password': password,
      };
}
