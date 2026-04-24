import 'dart:math' as math;

/// Bitta HTTP so'rovining immutable log yozuvi.
class NetworkLogEntry {
  const NetworkLogEntry({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.url,
    required this.path,
    this.requestBody,
    this.queryParams,
    this.statusCode,
    this.duration,
    this.responseBody,
    this.errorMessage,
    this.requestHeaders,
  });

  final String id;
  final DateTime timestamp;
  final String method;
  final String url;
  final String path;
  final Map<String, dynamic>? requestBody;
  final Map<String, String>? queryParams;
  final int? statusCode;
  final Duration? duration;
  final Map<String, dynamic>? responseBody;
  final String? errorMessage;
  final Map<String, String>? requestHeaders;

  // ---------------------------------------------------------------------------
  // Named constructors
  // ---------------------------------------------------------------------------

  /// So'rov boshlanganda yaratiladi — statusCode va duration yo'q.
  factory NetworkLogEntry.starting({
    required String method,
    required String url,
    required String path,
    Map<String, dynamic>? requestBody,
    Map<String, String>? queryParams,
    Map<String, String>? requestHeaders,
  }) {
    return NetworkLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      method: method,
      url: url,
      path: path,
      requestBody: requestBody,
      queryParams: queryParams,
      requestHeaders: requestHeaders,
    );
  }

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  bool get isRedirect =>
      statusCode != null && statusCode! >= 300 && statusCode! < 400;

  bool get isInFlight => statusCode == null && errorMessage == null;

  bool get hasError => errorMessage != null;

  /// 2xx / 3xx / 4xx / 5xx / error / pending
  String get statusCategory {
    if (isInFlight) return 'pending';
    if (hasError && statusCode == null) return 'error';
    if (isSuccess) return '2xx';
    if (isRedirect) return '3xx';
    if (isClientError) return '4xx';
    if (isServerError) return '5xx';
    return 'other';
  }

  // ---------------------------------------------------------------------------
  // copyWith — in-flight entry'ni yangilash uchun
  // ---------------------------------------------------------------------------

  NetworkLogEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? method,
    String? url,
    String? path,
    Map<String, dynamic>? requestBody,
    Map<String, String>? queryParams,
    int? statusCode,
    Duration? duration,
    Map<String, dynamic>? responseBody,
    String? errorMessage,
    Map<String, String>? requestHeaders,
    bool clearError = false,
  }) {
    return NetworkLogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      method: method ?? this.method,
      url: url ?? this.url,
      path: path ?? this.path,
      requestBody: requestBody ?? this.requestBody,
      queryParams: queryParams ?? this.queryParams,
      statusCode: statusCode ?? this.statusCode,
      duration: duration ?? this.duration,
      responseBody: responseBody ?? this.responseBody,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      requestHeaders: requestHeaders ?? this.requestHeaders,
    );
  }

  // ---------------------------------------------------------------------------
  // ID generator
  // ---------------------------------------------------------------------------

  static String _generateId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rand = math.Random().nextInt(99999);
    return '${ts}_$rand';
  }
}
