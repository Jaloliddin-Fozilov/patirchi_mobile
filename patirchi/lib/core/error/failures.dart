/// Xatoliklar ierarxiyasi — sealed class pattern (Dart 3+).
///
/// Barcha ishlov berilishi mumkin bo'lgan xatoliklar shu fayl
/// orqali ifodalanadi. [Result] tipi bilan birgalikda ishlatiladi.
///
/// Misol:
/// ```dart
/// final failure = ServerFailure(message: 'Server xatosi', code: 500);
/// print(failure.toUserMessage());
/// ```
sealed class Failure implements Exception {
  const Failure({
    required this.message,
    this.code,
  });

  /// Texnik xato matni (log uchun).
  final String message;

  /// HTTP yoki maxsus xato kodi.
  final int? code;

  /// Foydalanuvchiga ko'rsatiladigan o'zbek tilidagi xabar.
  String toUserMessage();

  @override
  String toString() =>
      '$runtimeType(code: $code, message: $message)';
}

// ---------------------------------------------------------------------------
// Konkret xato turlari
// ---------------------------------------------------------------------------

/// Server tomonidan qaytarilgan xato (HTTP 4xx / 5xx).
final class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    this.errorCode,
  });

  /// Backend tomonidan berilgan maxsus xato identifikatori.
  final String? errorCode;

  @override
  String toUserMessage() {
    return switch (code) {
      400 => 'So\'rov noto\'g\'ri. Ma\'lumotlarni tekshiring.',
      401 => 'Tizimga kirish talab qilinadi. Iltimos, qayta kiring.',
      403 => 'Bu amalga ruxsat yo\'q.',
      404 => 'Ma\'lumot topilmadi.',
      409 => 'Bunday ma\'lumot allaqachon mavjud.',
      422 => 'Ma\'lumotlar noto\'g\'ri formatda.',
      429 => 'Juda ko\'p so\'rov. Biroz kutib turing.',
      500 || 502 || 503 => 'Server xatosi. Keyinroq urinib ko\'ring.',
      _ => message.isNotEmpty
          ? message
          : 'Noma\'lum server xatosi yuz berdi.',
    };
  }
}

/// Mahalliy saqlashdan o'qish yoki yozish xatosi.
final class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });

  @override
  String toUserMessage() =>
      'Ma\'lumotlarni o\'qishda xato. Ilovani qayta yoqib ko\'ring.';
}

/// Tarmoq ulanishi yo'q yoki so'rov vaqti tugadi.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    this.isTimeout = false,
  });

  /// So'rov vaqti tugaganmi?
  final bool isTimeout;

  @override
  String toUserMessage() => isTimeout
      ? 'So\'rov vaqti tugadi. Tarmoq aloqasini tekshiring.'
      : 'Internet ulanishi yo\'q. Tarmoqni tekshiring.';
}

/// Autentifikatsiya yoki avtorizatsiya xatosi.
final class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  @override
  String toUserMessage() {
    return switch (code) {
      401 => 'Sessiya tugadi. Iltimos, qayta kiring.',
      403 => 'Bu amalni bajarishga ruxsatingiz yo\'q.',
      _ => 'Autentifikatsiya xatosi. Iltimos, qayta kiring.',
    };
  }
}

/// Kiritilgan ma'lumotlar tekshiruvdan o'tmadi.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors = const {},
  });

  /// Maydon nomi → xato matni ko'rinishidagi xatolar xaritasi.
  final Map<String, String> fieldErrors;

  @override
  String toUserMessage() => message.isNotEmpty
      ? message
      : 'Iltimos, barcha maydonlarni to\'g\'ri to\'ldiring.';
}
