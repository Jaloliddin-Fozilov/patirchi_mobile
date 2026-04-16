import 'dart:io';

import 'package:patirchi/core/error/failures.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/network/api_exception.dart';

/// Barcha repository'lar uchun asosiy abstrakt sinf.
///
/// [safeApiCall] metodi orqali xatoliklarni bir joyda ushlaydi
/// va ularni [Failure] turlariga o'giradi.
///
/// Misol:
/// ```dart
/// class ProductRepositoryImpl extends BaseRepository {
///   Future<Result<List<ProductModel>>> getProducts() {
///     return safeApiCall(() => _remote.fetchProducts());
///   }
/// }
/// ```
abstract class BaseRepository {
  /// API yoki lokal chaqiruvni xavfsiz bajaradi.
  ///
  /// [call] funksiyasi chaqiriladi va natija [Result] ga o'raladi:
  /// - Muvaffaqiyatli bo'lsa → [Result.success]
  /// - [ApiException] → [Result.error] ([ServerFailure] yoki [NetworkFailure])
  /// - [SocketException] → [Result.error] ([NetworkFailure])
  /// - Boshqa istisnolar → [Result.error] ([ServerFailure])
  Future<Result<T>> safeApiCall<T>(Future<T> Function() call) async {
    try {
      final data = await call();
      return Result.success(data);
    } on ApiException catch (e) {
      return Result.error(_apiExceptionToFailure(e));
    } on Failure catch (f) {
      // Failure (ValidationFailure, AuthFailure, etc.) to'g'ridan-to'g'ri tashlangan
      return Result.error(f);
    } on SocketException {
      return Result.error(
        const NetworkFailure(
          message: 'Internet ulanishi yo\'q.',
          isTimeout: false,
        ),
      );
    } on HandshakeException {
      return Result.error(
        const NetworkFailure(
          message: 'Xavfsiz ulanishni o\'rnatib bo\'lmadi.',
          isTimeout: false,
        ),
      );
    } on Object catch (e) {
      return Result.error(
        ServerFailure(
          message: e.toString(),
          errorCode: 'UNKNOWN',
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Yordamchi
  // ---------------------------------------------------------------------------

  Failure _apiExceptionToFailure(ApiException e) {
    // Timeout
    if (e.errorCode == 'TIMEOUT') {
      return NetworkFailure(
        message: e.message,
        code: e.statusCode,
        isTimeout: true,
      );
    }

    // Internet yo'q
    if (e.errorCode == 'NO_INTERNET') {
      return NetworkFailure(
        message: e.message,
        code: e.statusCode,
        isTimeout: false,
      );
    }

    // Auth xatosi
    if (e.statusCode == 401 || e.statusCode == 403) {
      return AuthFailure(
        message: e.message,
        code: e.statusCode,
      );
    }

    // Validatsiya xatosi
    if (e.statusCode == 422 || e.statusCode == 400) {
      return ValidationFailure(
        message: e.message,
        code: e.statusCode,
      );
    }

    // Boshqa barcha server xatolari
    return ServerFailure(
      message: e.message,
      code: e.statusCode,
      errorCode: e.errorCode,
    );
  }
}
