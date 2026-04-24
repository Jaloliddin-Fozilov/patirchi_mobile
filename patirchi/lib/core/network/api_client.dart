import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/dev_mode/api_observer.dart';
import 'package:patirchi/core/dev_mode/models/network_log_entry.dart';
import 'package:patirchi/core/network/api_config.dart';
import 'package:patirchi/core/storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

/// HTTP mijoz singleton — barcha API so'rovlarini boshqaradi.
///
/// Xususiyatlar:
/// - JWT token avtomatik qo'shiladi (SecureStorageService orqali)
/// - 401 da token avtomatik yangilanadi va so'rov qayta yuboriladi
/// - DRF pagination qo'llab-quvvatlanadi ([getList])
/// - Multipart fayl yuklash ([postMultipart])
/// - Timeout: connect 15s, read 30s
/// - dart:io HttpClient asosida (tashqi paket yo'q)
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  // ---------------------------------------------------------------------------
  // Konfiguratsiya
  // ---------------------------------------------------------------------------

  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _readTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Asosiy HTTP metodlar
  // ---------------------------------------------------------------------------

  /// GET so'rovi.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    return _request('GET', path, queryParams: queryParams);
  }

  /// POST so'rovi.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    return _request('POST', path, body: body, queryParams: queryParams);
  }

  /// PUT so'rovi.
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    return _request('PUT', path, body: body, queryParams: queryParams);
  }

  /// PATCH so'rovi.
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    return _request('PATCH', path, body: body, queryParams: queryParams);
  }

  /// DELETE so'rovi.
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    return _request('DELETE', path, queryParams: queryParams);
  }

  // ---------------------------------------------------------------------------
  // DRF Pagination
  // ---------------------------------------------------------------------------

  /// DRF LimitOffset pagination bilan ro'yxat olish.
  ///
  /// Backend javobi: `{count, next, previous, results: [...]}`
  /// [fromJson] har bir elementni parse qiladi.
  Future<PaginatedResult<T>> getList<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    int limit = AppConstants.pageSize,
    int offset = 0,
    Map<String, String>? extraParams,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      ...?extraParams,
    };

    final raw = await get(path, queryParams: params);
    return PaginatedResult.fromJson(raw, fromJson);
  }

  // ---------------------------------------------------------------------------
  // Multipart fayl yuklash
  // ---------------------------------------------------------------------------

  /// Multipart/form-data bilan POST so'rov.
  ///
  /// [fields] — matn maydonlari.
  /// [files] — fayllar: `{fieldName: filePath}`.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, String> files = const {},
  }) async {
    final entryId = _generateEntryId();
    final startedAt = DateTime.now();
    final baseUrl = ApiConfig.instance.baseUrl;

    // Observer: multipart so'rov boshlangani (fayl bytes log ga tushmasin)
    ApiObserverRegistry.emitStart(
      NetworkLogEntry.starting(
        method: 'POST',
        url: baseUrl + path,
        path: path,
        requestBody: {
          '_type': 'multipart',
          'fields': fields.keys.toList(),
          'files': files.keys.toList(),
        },
      ).copyWith(id: entryId),
    );

    try {
      final token = await _getToken();
      final boundary = _generateBoundary();
      final uri = _buildUri(path, null);

      final httpClient = HttpClient()..connectionTimeout = _connectTimeout;

      final request = await httpClient
          .postUrl(uri)
          .timeout(
            _connectTimeout,
            onTimeout: () => throw ApiException.timeout(),
          );

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      final body = await _buildMultipartBody(boundary, fields, files);
      request.headers.set(HttpHeaders.contentLengthHeader, body.length);
      request.add(body);

      final response = await request
          .close()
          .timeout(_readTimeout, onTimeout: () => throw ApiException.timeout());

      final responseBody = await response.transform(utf8.decoder).join();
      httpClient.close();

      final result = _handleResponse(response.statusCode, responseBody);

      // Observer: muvaffaqiyatli yakunlandi
      ApiObserverRegistry.emitComplete(
        entryId,
        statusCode: response.statusCode,
        responseBody: _safeDecodeForLog(responseBody),
        duration: DateTime.now().difference(startedAt),
      );

      return result;
    } on ApiException catch (e) {
      ApiObserverRegistry.emitError(
        entryId,
        error: e.message,
        statusCode: e.statusCode,
        duration: DateTime.now().difference(startedAt),
      );
      rethrow;
    } on Object catch (e) {
      ApiObserverRegistry.emitError(
        entryId,
        error: e.toString(),
        duration: DateTime.now().difference(startedAt),
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Ichki amalga oshirish
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool isRetry = false,
  }) async {
    final entryId = _generateEntryId();
    final startedAt = DateTime.now();
    final baseUrl = ApiConfig.instance.baseUrl;

    // Observer: so'rov boshlangani xabari
    ApiObserverRegistry.emitStart(
      NetworkLogEntry.starting(
        method: method,
        url: baseUrl + path,
        path: path,
        requestBody: body,
        queryParams: queryParams,
      ).copyWith(id: entryId),
    );

    try {
      final token = await _getToken();
      final uri = _buildUri(path, queryParams);
      final httpClient = HttpClient()..connectionTimeout = _connectTimeout;

      final request = await httpClient
          .openUrl(method, uri)
          .timeout(
            _connectTimeout,
            onTimeout: () => throw ApiException.timeout(),
          );

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (token != null) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $token',
        );
      }

      if (body != null) {
        final encoded = utf8.encode(jsonEncode(body));
        request.headers.set(HttpHeaders.contentLengthHeader, encoded.length);
        request.add(encoded);
      }

      final response = await request
          .close()
          .timeout(_readTimeout, onTimeout: () => throw ApiException.timeout());

      final responseBody = await response.transform(utf8.decoder).join();
      httpClient.close();

      // 401 — token muddati tugagan: yangilashga urinib ko'r
      if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return _request(
            method,
            path,
            body: body,
            queryParams: queryParams,
            isRetry: true,
          );
        }
      }

      final result = _handleResponse(response.statusCode, responseBody);

      // Observer: muvaffaqiyatli yakunlandi
      ApiObserverRegistry.emitComplete(
        entryId,
        statusCode: response.statusCode,
        responseBody: _safeDecodeForLog(responseBody),
        duration: DateTime.now().difference(startedAt),
      );

      return result;
    } on ApiException catch (e) {
      // Observer: API exception
      ApiObserverRegistry.emitError(
        entryId,
        error: e.message,
        statusCode: e.statusCode,
        duration: DateTime.now().difference(startedAt),
      );
      rethrow;
    } on SocketException {
      ApiObserverRegistry.emitError(
        entryId,
        error: 'Internet aloqasi yo\'q',
        duration: DateTime.now().difference(startedAt),
      );
      throw ApiException.noInternet();
    } on HandshakeException {
      ApiObserverRegistry.emitError(
        entryId,
        error: 'SSL/TLS xato',
        duration: DateTime.now().difference(startedAt),
      );
      throw ApiException.noInternet();
    } on FormatException {
      ApiObserverRegistry.emitError(
        entryId,
        error: 'Server noto\'g\'ri formatda javob qaytardi',
        duration: DateTime.now().difference(startedAt),
      );
      throw const ApiException(
        message: 'Server noto\'g\'ri formatda javob qaytardi.',
        errorCode: 'PARSE_ERROR',
      );
    } on Object catch (e) {
      ApiObserverRegistry.emitError(
        entryId,
        error: e.toString(),
        duration: DateTime.now().difference(startedAt),
      );
      throw ApiException.unknown(e);
    }
  }

  /// HTTP javobni tahlil qiladi.
  Map<String, dynamic> _handleResponse(int statusCode, String body) {
    if (body.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return {'success': true};
      }
      throw ApiException.fromResponse(statusCode: statusCode, body: const {});
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const ApiException(
        message: 'Server noto\'g\'ri formatda javob qaytardi.',
        errorCode: 'PARSE_ERROR',
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      // List yoki boshqa turdagi javob uchun wrapper
      return {'data': decoded};
    }

    final errorBody =
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    throw ApiException.fromResponse(statusCode: statusCode, body: errorBody);
  }

  /// Access tokenni storage dan oladi.
  Future<String?> _getToken() async {
    return SecureStorageService.instance.getToken();
  }

  /// Refresh token orqali access tokenni yangilashga urinadi.
  ///
  /// Muvaffaqiyatli bo'lsa `true`, aks holda `false` qaytaradi.
  Future<bool> _tryRefreshToken() async {
    final storage = SecureStorageService.instance;
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final uri = _buildUri(ApiEndpoints.tokenRefresh, null);
      final httpClient = HttpClient()..connectionTimeout = _connectTimeout;

      final request = await httpClient.postUrl(uri).timeout(
            _connectTimeout,
            onTimeout: () => throw ApiException.timeout(),
          );

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final encoded = utf8.encode(jsonEncode({'refresh': refreshToken}));
      request.headers.set(HttpHeaders.contentLengthHeader, encoded.length);
      request.add(encoded);

      final response = await request.close().timeout(
            _readTimeout,
            onTimeout: () => throw ApiException.timeout(),
          );

      final responseBody = await response.transform(utf8.decoder).join();
      httpClient.close();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
        final newToken = decoded['access'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          await storage.saveToken(newToken);
          return true;
        }
      }
      return false;
    } on Object {
      return false;
    }
  }

  /// To'liq URI ni quradi (ApiConfig.instance.baseUrl ishlatadi).
  Uri _buildUri(String path, Map<String, String>? queryParams) {
    final baseUrl = ApiConfig.instance.baseUrl;
    final base = Uri.parse(baseUrl + path);
    if (queryParams == null || queryParams.isEmpty) return base;
    return base.replace(
      queryParameters: {
        ...base.queryParameters,
        ...queryParams,
      },
    );
  }

  /// Log uchun unique entry ID hosil qiladi.
  String _generateEntryId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rand = math.Random().nextInt(99999);
    return '${ts}_$rand';
  }

  /// Response body ni log uchun xavfsiz decode qiladi.
  Map<String, dynamic>? _safeDecodeForLog(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'_data': decoded};
    } on Object {
      return {'_raw': body.length > 500 ? body.substring(0, 500) : body};
    }
  }

  /// Multipart boundary hosil qiladi.
  String _generateBoundary() {
    return 'dart_multipart_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Multipart body ni bytes sifatida tayyorlaydi.
  Future<List<int>> _buildMultipartBody(
    String boundary,
    Map<String, String> fields,
    Map<String, String> files,
  ) async {
    final buffer = <int>[];

    // Matn maydonlari
    for (final entry in fields.entries) {
      buffer.addAll(utf8.encode('--$boundary\r\n'));
      buffer.addAll(utf8.encode(
        'Content-Disposition: form-data; name="${entry.key}"\r\n\r\n',
      ));
      buffer.addAll(utf8.encode('${entry.value}\r\n'));
    }

    // Fayllar
    for (final entry in files.entries) {
      final file = File(entry.value);
      final filename = file.uri.pathSegments.last;
      final fileBytes = await file.readAsBytes();

      buffer.addAll(utf8.encode('--$boundary\r\n'));
      buffer.addAll(utf8.encode(
        'Content-Disposition: form-data; name="${entry.key}"; '
        'filename="$filename"\r\n',
      ));
      buffer.addAll(utf8.encode('Content-Type: application/octet-stream\r\n\r\n'));
      buffer.addAll(fileBytes);
      buffer.addAll(utf8.encode('\r\n'));
    }

    buffer.addAll(utf8.encode('--$boundary--\r\n'));
    return buffer;
  }
}

// ---------------------------------------------------------------------------
// DRF Pagination natijasi
// ---------------------------------------------------------------------------

/// DRF LimitOffset pagination javobi.
///
/// Backend format: `{count, next, previous, results: [...]}`
class PaginatedResult<T> {
  const PaginatedResult({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  /// Umumiy natijalar soni.
  final int count;

  /// Keyingi sahifa URL (yoki null).
  final String? next;

  /// Oldingi sahifa URL (yoki null).
  final String? previous;

  /// Joriy sahifa natijalari.
  final List<T> results;

  /// Keyingi sahifa mavjudmi?
  bool get hasMore => next != null;

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawResults = json['results'];
    final List<dynamic> list =
        rawResults is List ? rawResults : [];

    return PaginatedResult(
      count: (json['count'] as int?) ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: list
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(),
    );
  }
}
