import 'package:patirchi/core/dev_mode/models/network_log_entry.dart';
import 'package:patirchi/core/dev_mode/stores/network_log_store.dart';

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

/// API so'rovlarini kuzatuvchi interfeys.
///
/// Implement qiluvchi observer emit metodlarida HECH QACHON exception otmaydi.
/// [ApiObserverRegistry] emit metodlari try/catch bilan o'ralgan.
abstract interface class ApiObserver {
  void onRequestStart(NetworkLogEntry entry);

  void onRequestComplete(
    String entryId, {
    int? statusCode,
    Map<String, dynamic>? responseBody,
    Duration? duration,
  });

  void onRequestError(
    String entryId, {
    String? error,
    int? statusCode,
    Duration? duration,
  });
}

// ---------------------------------------------------------------------------
// Registry
// ---------------------------------------------------------------------------

/// Global observer registry — ApiClient uni ishlatadi.
///
/// Observer null bo'lsa yoki exception otsa, API flow to'xtamaydi.
class ApiObserverRegistry {
  ApiObserverRegistry._();

  static ApiObserver? _observer;

  static set observer(ApiObserver? o) => _observer = o;
  static ApiObserver? get observer => _observer;

  /// So'rov boshlanganda chaqiriladi.
  static void emitStart(NetworkLogEntry entry) {
    try {
      _observer?.onRequestStart(entry);
    } catch (_) {
      // Observer hech qachon API flow ni buzmasin
    }
  }

  /// So'rov muvaffaqiyatli yakunlanganda chaqiriladi.
  static void emitComplete(
    String entryId, {
    int? statusCode,
    Map<String, dynamic>? responseBody,
    Duration? duration,
  }) {
    try {
      _observer?.onRequestComplete(
        entryId,
        statusCode: statusCode,
        responseBody: responseBody,
        duration: duration,
      );
    } catch (_) {}
  }

  /// So'rov xato bilan yakunlanganda chaqiriladi.
  static void emitError(
    String entryId, {
    String? error,
    int? statusCode,
    Duration? duration,
  }) {
    try {
      _observer?.onRequestError(
        entryId,
        error: error,
        statusCode: statusCode,
        duration: duration,
      );
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Recording implementation
// ---------------------------------------------------------------------------

/// [ApiObserver] ning [NetworkLogStore] ga yozuvchi implementatsiyasi.
class RecordingApiObserver implements ApiObserver {
  RecordingApiObserver(this._store);

  final NetworkLogStore _store;

  @override
  void onRequestStart(NetworkLogEntry entry) {
    _store.add(entry);
  }

  @override
  void onRequestComplete(
    String entryId, {
    int? statusCode,
    Map<String, dynamic>? responseBody,
    Duration? duration,
  }) {
    _store.update(
      entryId,
      (e) => e.copyWith(
        statusCode: statusCode,
        responseBody: responseBody,
        duration: duration,
      ),
    );
  }

  @override
  void onRequestError(
    String entryId, {
    String? error,
    int? statusCode,
    Duration? duration,
  }) {
    _store.update(
      entryId,
      (e) => e.copyWith(
        errorMessage: error,
        statusCode: statusCode,
        duration: duration,
      ),
    );
  }
}
