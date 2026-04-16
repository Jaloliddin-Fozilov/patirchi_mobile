import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_endpoints.dart';
import 'package:patirchi/core/network/api_exception.dart';
import 'package:patirchi/core/repositories/base_repository.dart';
import 'package:patirchi/core/storage/secure_storage_service.dart';
import 'package:patirchi/features/auth/data/models/auth_request_model.dart';
import 'package:patirchi/features/auth/data/models/auth_response_model.dart';
import 'package:patirchi/features/auth/data/models/user_model.dart';

/// Autentifikatsiya repository — OTP kirish, ro'yxatdan o'tish
/// va token boshqaruvini amalga oshiradi.
///
/// Auth oqimi:
/// 1. [login] — telefon + rol yuborish → OTP + secret olish
/// 2. [confirmOtp] — secret + OTP → tokenlar + foydalanuvchi
/// 3. [getMe] — tokenlar bilan profil olish
/// 4. [refreshToken] — yangi access token olish
/// 5. [logout] — storage tozalash
class AuthRepository extends BaseRepository {
  AuthRepository({
    ApiClient? apiClient,
    SecureStorageService? storage,
  })  : _api = apiClient ?? ApiClient.instance,
        _storage = storage ?? SecureStorageService.instance;

  final ApiClient _api;
  final SecureStorageService _storage;

  // ---------------------------------------------------------------------------
  // OTP yuborish (1-qadam)
  // ---------------------------------------------------------------------------

  /// Telefon raqamiga OTP kodi yuboradi.
  ///
  /// [phoneNumber] — `+998XXXXXXXXX` formatida.
  /// [role] — `ordinary` yoki `business`.
  ///
  /// Muvaffaqiyatli bo'lsa [LoginResponse] (secret) qaytaradi.
  Future<Result<LoginResponse>> login(
    String phoneNumber,
    String role,
  ) async {
    return safeApiCall(() async {
      final request = LoginRequest(phoneNumber: phoneNumber, role: role);
      final response = await _api.post(
        ApiEndpoints.login,
        body: request.toJson(),
      );
      return LoginResponse.fromJson(response);
    });
  }

  // ---------------------------------------------------------------------------
  // OTP tasdiqlash (2-qadam)
  // ---------------------------------------------------------------------------

  /// OTP kodni tasdiqlaydi va tokenlarni saqlaydi.
  ///
  /// [secret] — login javobidan kelgan maxfiy kalit.
  /// [otp] — foydalanuvchi kiritgan 4 raqamli kod.
  ///
  /// Muvaffaqiyatli bo'lsa [UserModel] qaytaradi va tokenlarni saqlaydi.
  Future<Result<UserModel>> confirmOtp(String secret, String otp) async {
    return safeApiCall(() async {
      final request = LoginConfirmRequest(secret: secret, otp: otp);
      final response = await _api.post(
        ApiEndpoints.loginConfirm,
        body: request.toJson(),
      );
      final confirmed = LoginConfirmResponse.fromJson(response);

      // Tokenlarni saqlash
      await _storage.saveToken(confirmed.access);
      await _storage.saveRefreshToken(confirmed.refresh);

      // Profil ma'lumotlarini olish
      final user = await _fetchAndCacheMe();
      return user;
    });
  }

  // ---------------------------------------------------------------------------
  // Ro'yxatdan o'tish
  // ---------------------------------------------------------------------------

  /// Yangi hisob yaratadi.
  ///
  /// Backend `{detail: "..."}` javobi qaytaradi.
  Future<Result<String>> signup(
    String phoneNumber,
    String password,
    String passwordConfirm,
  ) async {
    return safeApiCall(() async {
      final request = SignupRequest(
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirm: passwordConfirm,
      );
      final response = await _api.post(
        ApiEndpoints.signup,
        body: request.toJson(),
      );
      return response['detail'] as String? ?? 'Muvaffaqiyatli ro\'yxatdan o\'tdingiz.';
    });
  }

  // ---------------------------------------------------------------------------
  // Profil olish
  // ---------------------------------------------------------------------------

  /// Tokenlar orqali joriy foydalanuvchi profilini oladi.
  Future<Result<UserModel>> getMe() async {
    return safeApiCall(() => _fetchAndCacheMe());
  }

  /// Profilni API dan oladi va cache'ga saqlaydi.
  Future<UserModel> _fetchAndCacheMe() async {
    final response = await _api.get(ApiEndpoints.me);
    final user = UserModel.fromJson(response);
    await _storage.saveUserJson(user.toJson());
    return user;
  }

  // ---------------------------------------------------------------------------
  // Token yangilash
  // ---------------------------------------------------------------------------

  /// Access tokenni refresh token orqali yangilaydi.
  ///
  /// Muvaffaqiyatli bo'lsa yangi access token qaytaradi.
  Future<Result<String>> refreshToken() async {
    return safeApiCall(() async {
      final refreshTkn = await _storage.getRefreshToken();
      if (refreshTkn == null || refreshTkn.isEmpty) {
        throw ApiException.fromResponse(
          statusCode: 401,
          body: const {'detail': 'Refresh token topilmadi.'},
        );
      }

      final response = await _api.post(
        ApiEndpoints.tokenRefresh,
        body: {'refresh': refreshTkn},
      );

      final newToken = response['access'] as String?;
      if (newToken == null || newToken.isEmpty) {
        throw ApiException.fromResponse(
          statusCode: 401,
          body: const {'detail': 'Yangi token olinmadi.'},
        );
      }

      await _storage.saveToken(newToken);
      return newToken;
    });
  }

  // ---------------------------------------------------------------------------
  // Tizimdan chiqish
  // ---------------------------------------------------------------------------

  /// Foydalanuvchini tizimdan chiqaradi va barcha ma'lumotlarni tozalaydi.
  Future<void> logout() async {
    await _storage.clear();
  }

  // ---------------------------------------------------------------------------
  // Saqlangan ma'lumotlar
  // ---------------------------------------------------------------------------

  /// Cache'dan saqlangan foydalanuvchini qaytaradi.
  ///
  /// Ilovani qayta ishga tushirishda sessiyani tiklash uchun.
  Future<UserModel?> getStoredUser() async {
    final json = await _storage.getUserJson();
    if (json == null) return null;
    try {
      return UserModel.fromJson(json);
    } on Object {
      return null;
    }
  }

  /// Foydalanuvchi tizimga kirganmi?
  bool get isLoggedIn => _storage.isLoggedIn;

  /// Async versiya — eski kod bilan mos kelish uchun.
  Future<bool> get isLoggedInAsync => _storage.isLoggedInAsync;
}
