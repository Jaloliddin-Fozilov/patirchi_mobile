/// API xatoliklarini ifodalovchi istisno sinfi.
///
/// Django REST Framework xato formatlari:
/// - `{detail: "Error message"}` — umumiy xato
/// - `{field_name: ["Error1", "Error2"]}` — maydon xatosi
/// - `{non_field_errors: ["Error1"]}` — maydon bo'lmagan xato
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.fieldErrors,
  });

  /// Foydalanuvchiga ko'rsatiladigan xato matni.
  final String message;

  /// HTTP status kodi (masalan: 401, 404, 500).
  final int? statusCode;

  /// Ichki xato kodi.
  final String? errorCode;

  /// DRF maydon xatolari: `{field: ["error1", "error2"]}`.
  final Map<String, List<String>>? fieldErrors;

  // ---------------------------------------------------------------------------
  // Factory konstruktorlar
  // ---------------------------------------------------------------------------

  /// DRF HTTP javob xaritasidan [ApiException] yaratadi.
  ///
  /// Qo'llab-quvvatlanadigan DRF xato formatlari:
  /// 1. `{"detail": "Not found."}`
  /// 2. `{"field_name": ["Error message."]}`
  /// 3. `{"non_field_errors": ["Error message."]}`
  factory ApiException.fromResponse({
    required int statusCode,
    required Map<String, dynamic> body,
  }) {
    final parsed = _parseDrfError(body);
    return ApiException(
      message: parsed.message,
      statusCode: statusCode,
      fieldErrors: parsed.fieldErrors,
    );
  }

  /// So'rov vaqti tugashi.
  factory ApiException.timeout() {
    return const ApiException(
      message: 'So\'rov vaqti tugadi. Iltimos, qayta urinib ko\'ring.',
      statusCode: 408,
      errorCode: 'TIMEOUT',
    );
  }

  /// Internet ulanishi yo'q.
  factory ApiException.noInternet() {
    return const ApiException(
      message: 'Internet ulanishi yo\'q. Tarmoqni tekshiring.',
      statusCode: 503,
      errorCode: 'NO_INTERNET',
    );
  }

  /// Noma'lum xato.
  factory ApiException.unknown([Object? cause]) {
    return ApiException(
      message: 'Noma\'lum xato yuz berdi. Iltimos, keyinroq urinib ko\'ring.',
      errorCode: 'UNKNOWN',
    );
  }

  // ---------------------------------------------------------------------------
  // DRF xato parseri
  // ---------------------------------------------------------------------------

  static _ParsedError _parseDrfError(Map<String, dynamic> body) {
    // Format 1: {"detail": "..."} — eng keng tarqalgan DRF formati
    final detail = body['detail'];
    if (detail != null) {
      return _ParsedError(message: detail.toString());
    }

    // Format 2: {"non_field_errors": ["...", "..."]}
    final nonField = body['non_field_errors'];
    if (nonField is List && nonField.isNotEmpty) {
      return _ParsedError(message: nonField.first.toString());
    }

    // Format 3: {"field_name": ["error1", "error2"], ...}
    // Barcha maydon xatolarini yig'amiz
    final fieldErrors = <String, List<String>>{};
    String? firstMessage;

    for (final entry in body.entries) {
      final value = entry.value;
      if (value is List) {
        final errors = value.map((e) => e.toString()).toList();
        if (errors.isNotEmpty) {
          fieldErrors[entry.key] = errors;
          firstMessage ??= errors.first;
        }
      } else if (value is String) {
        fieldErrors[entry.key] = [value];
        firstMessage ??= value;
      }
    }

    if (firstMessage != null) {
      return _ParsedError(
        message: firstMessage,
        fieldErrors: fieldErrors.isEmpty ? null : fieldErrors,
      );
    }

    // Fallback: status kodi bo'yicha xabar
    return _ParsedError(message: '');
  }

  /// Birinchi maydon xatosini qaytaradi (forma validatsiyasi uchun).
  String? fieldError(String fieldName) => fieldErrors?[fieldName]?.first;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, '
      'errorCode: $errorCode, message: $message)';
}

/// DRF javobini tahlil qilish natijasi.
class _ParsedError {
  const _ParsedError({
    required String message,
    this.fieldErrors,
  }) : _message = message;

  final String _message;
  final Map<String, List<String>>? fieldErrors;

  String get message =>
      _message.isNotEmpty ? _message : 'Noma\'lum xato yuz berdi.';
}
