import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';
import 'package:patirchi/core/repositories/base_repository.dart';
import 'package:patirchi/core/storage/secure_storage_service.dart';
import 'package:patirchi/features/auth/data/models/tg_login_models.dart';
import 'package:patirchi/features/auth/data/models/user_model.dart';

/// Telegram bot orqali login uchun repository.
///
/// Flow:
/// 1. [start] — secret + deep link oladi
/// 2. App deep link'ni ochadi (url_launcher)
/// 3. [pollStatus] — har 3s da tekshiradi
/// 4. status='confirmed' bo'lsa — tokenlarni saqlaydi va [UserModel] qaytaradi
class TgAuthRepository extends BaseRepository {
  TgAuthRepository({ApiClient? apiClient, SecureStorageService? storage})
      : _api = apiClient ?? ApiClient.instance,
        _storage = storage ?? SecureStorageService.instance;

  final ApiClient _api;
  final SecureStorageService _storage;

  // ---------------------------------------------------------------------------
  // Sessiyani boshlash
  // ---------------------------------------------------------------------------

  /// Telegram login sessiyasini boshlaydi.
  ///
  /// [phoneNumber] — `+998XXXXXXXXX` formatida.
  /// [role] — `ordinary` yoki `business`.
  ///
  /// Muvaffaqiyatli bo'lsa [TgLoginStartResponse] qaytaradi.
  Future<Result<TgLoginStartResponse>> start(
    String phoneNumber,
    String role,
  ) async {
    return safeApiCall(() async {
      final req = TgLoginStartRequest(phoneNumber: phoneNumber, role: role);
      final response = await _api.post(
        ApiEndpoints.tgLoginStart,
        body: req.toJson(),
      );
      return TgLoginStartResponse.fromJson(response);
    });
  }

  // ---------------------------------------------------------------------------
  // Holat tekshirish
  // ---------------------------------------------------------------------------

  /// Telegram login sessiyasi holatini tekshiradi.
  ///
  /// [secret] — [TgLoginStartResponse.secret] dan olingan kalit.
  Future<Result<TgLoginStatusResponse>> pollStatus(String secret) async {
    return safeApiCall(() async {
      final response = await _api.get(
        ApiEndpoints.tgLoginStatus,
        queryParams: {'secret': secret},
      );
      return TgLoginStatusResponse.fromJson(response);
    });
  }

  // ---------------------------------------------------------------------------
  // Tokenlarni saqlash
  // ---------------------------------------------------------------------------

  /// Tasdiqlangan status'dan tokenlarni saqlaydi va [UserModel] qaytaradi.
  ///
  /// [status.isConfirmed] bo'lmasa yoki tokenlar yo'q bo'lsa `null` qaytaradi.
  Future<UserModel?> persistFromStatus(TgLoginStatusResponse status) async {
    if (!status.isConfirmed ||
        status.access == null ||
        status.refresh == null) {
      return null;
    }

    await _storage.saveToken(status.access!);
    await _storage.saveRefreshToken(status.refresh!);

    final userJson = status.userJson;
    if (userJson != null) {
      await _storage.saveUserJson(userJson);
      return UserModel.fromJson(userJson);
    }
    return null;
  }
}
