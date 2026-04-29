// Telegram bot orqali login uchun model'lar.
//
// Flow:
// 1. [TgLoginStartRequest] — POST /auth/tg-login/start/
// 2. [TgLoginStartResponse] — secret + deep_link
// 3. [TgLoginStatusResponse] — GET /auth/tg-login/status/?secret=X

// ---------------------------------------------------------------------------
// Boshlash so'rovi
// ---------------------------------------------------------------------------

/// `POST /auth/tg-login/start/` so'rov modeli.
class TgLoginStartRequest {
  const TgLoginStartRequest({
    required this.phoneNumber,
    required this.role,
  });

  final String phoneNumber;
  final String role;

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'role': role,
      };
}

// ---------------------------------------------------------------------------
// Boshlash javobi
// ---------------------------------------------------------------------------

/// `POST /auth/tg-login/start/` javobi.
class TgLoginStartResponse {
  const TgLoginStartResponse({
    required this.secret,
    required this.deepLink,
    required this.botUsername,
    required this.phoneNumber,
    required this.expiresAt,
  });

  final String secret;
  final String deepLink;
  final String botUsername;
  final String phoneNumber;
  final DateTime expiresAt;

  factory TgLoginStartResponse.fromJson(Map<String, dynamic> json) {
    return TgLoginStartResponse(
      secret: json['secret'] as String,
      deepLink: json['deep_link'] as String,
      botUsername: json['bot_username'] as String? ?? 'patirchibot',
      phoneNumber: json['phone_number'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ??
          DateTime.now().add(const Duration(minutes: 10)),
    );
  }
}

// ---------------------------------------------------------------------------
// Sessiya holati
// ---------------------------------------------------------------------------

/// TG sessiya holati.
enum TgLoginStatus {
  pending,
  confirmed,
  expired,
  rejected,
  unknown;

  static TgLoginStatus fromString(String? value) => switch (value) {
        'pending' => TgLoginStatus.pending,
        'confirmed' => TgLoginStatus.confirmed,
        'expired' => TgLoginStatus.expired,
        'rejected' => TgLoginStatus.rejected,
        _ => TgLoginStatus.unknown,
      };
}

// ---------------------------------------------------------------------------
// Status javobi
// ---------------------------------------------------------------------------

/// `GET /auth/tg-login/status/` javobi.
class TgLoginStatusResponse {
  const TgLoginStatusResponse({
    required this.status,
    this.access,
    this.refresh,
    this.userJson,
    this.message,
  });

  final TgLoginStatus status;
  final String? access;
  final String? refresh;
  final Map<String, dynamic>? userJson;
  final String? message;

  bool get isConfirmed => status == TgLoginStatus.confirmed;
  bool get isPending => status == TgLoginStatus.pending;
  bool get isFinished =>
      status == TgLoginStatus.confirmed ||
      status == TgLoginStatus.expired ||
      status == TgLoginStatus.rejected;

  factory TgLoginStatusResponse.fromJson(Map<String, dynamic> json) {
    return TgLoginStatusResponse(
      status: TgLoginStatus.fromString(json['status'] as String?),
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
      userJson: json['user'] as Map<String, dynamic>?,
      message: json['message'] as String?,
    );
  }
}
