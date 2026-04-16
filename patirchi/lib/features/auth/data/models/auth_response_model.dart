import 'package:patirchi/features/auth/data/models/user_model.dart';

/// Autentifikatsiya javoblari uchun model sinflari.
///
/// Barcha modellar snake_case kalitlardan `fromJson()` orqali yaratiladi
/// (Django REST Framework standartiga mos).

// ---------------------------------------------------------------------------
// Login javobi (OTP yuborish)
// ---------------------------------------------------------------------------

/// `POST /auth/login/` javobi.
///
/// ```json
/// {"phone_number": "+998...", "role": "ordinary", "secret": "abc123"}
/// ```
class LoginResponse {
  const LoginResponse({
    required this.phoneNumber,
    required this.role,
    required this.secret,
  });

  final String phoneNumber;
  final String role;

  /// OTP tasdiqlashda ishlatilishi kerak bo'lgan maxfiy kalit.
  final String secret;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      phoneNumber: json['phone_number'] as String? ?? '',
      role: json['role'] as String? ?? 'ordinary',
      secret: json['secret'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'LoginResponse(phone: $phoneNumber, role: $role)';
}

// ---------------------------------------------------------------------------
// OTP tasdiqlash javobi
// ---------------------------------------------------------------------------

/// `POST /auth/login/confirm/` javobi.
///
/// ```json
/// {"id": 1, "phone_number": "+998...", "access": "eyJ...", "refresh": "eyJ..."}
/// ```
class LoginConfirmResponse {
  const LoginConfirmResponse({
    required this.id,
    required this.phoneNumber,
    required this.access,
    required this.refresh,
  });

  final int id;
  final String phoneNumber;

  /// JWT access token.
  final String access;

  /// JWT refresh token.
  final String refresh;

  factory LoginConfirmResponse.fromJson(Map<String, dynamic> json) {
    return LoginConfirmResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phoneNumber: json['phone_number'] as String? ?? '',
      access: json['access'] as String? ?? '',
      refresh: json['refresh'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'LoginConfirmResponse(id: $id, phone: $phoneNumber)';
}

// ---------------------------------------------------------------------------
// Token javobi
// ---------------------------------------------------------------------------

/// `POST /auth/token/` yoki `POST /auth/token/refresh/` javobi.
///
/// ```json
/// {"access": "eyJ...", "refresh": "eyJ..."}
/// ```
class TokenResponse {
  const TokenResponse({
    required this.access,
    this.refresh,
    this.role,
    this.expireIn,
    this.refreshExpire,
  });

  final String access;
  final String? refresh;
  final String? role;

  /// Access token muddati (soniyalarda).
  final int? expireIn;

  /// Refresh token muddati (soniyalarda).
  final int? refreshExpire;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      access: json['access'] as String? ?? '',
      refresh: json['refresh'] as String?,
      role: json['role'] as String?,
      expireIn: (json['expire_in'] as num?)?.toInt(),
      refreshExpire: (json['refresh_expire'] as num?)?.toInt(),
    );
  }

  @override
  String toString() => 'TokenResponse(hasAccess: ${access.isNotEmpty})';
}

// ---------------------------------------------------------------------------
// Eski mos kelish (legacy)
// ---------------------------------------------------------------------------

/// Eski [AuthResponse] — eski repository kodi bilan mos kelish uchun.
@Deprecated('Use LoginConfirmResponse + UserModel.fromJson instead')
class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken:
          json['access'] as String? ?? json['access_token'] as String? ?? '',
      refreshToken:
          json['refresh'] as String? ?? json['refresh_token'] as String? ?? '',
      user: UserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user': user.toJson(),
      };

  @override
  String toString() =>
      'AuthResponse(hasToken: ${accessToken.isNotEmpty})';
}
