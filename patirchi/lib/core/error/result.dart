import 'failures.dart';

/// Muvaffaqiyat yoki xatolikni ifodalovchi generic tip.
///
/// Either-monad pattern — exception o'rniga xatoliklarni
/// qadriyat sifatida qaytarish uchun ishlatiladi.
///
/// Misol:
/// ```dart
/// final result = await repository.login(phone, password);
/// result.fold(
///   onSuccess: (user) => navigateToDashboard(user),
///   onError: (failure) => showError(failure.toUserMessage()),
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Muvaffaqiyatli holat: [data] qiymatini o'z ichiga oladi.
  const factory Result.success(T data) = Success<T>;

  /// Xato holati: [failure] sababini o'z ichiga oladi.
  const factory Result.error(Failure failure) = Error<T>;
}

// ---------------------------------------------------------------------------
// Konkret holatlar
// ---------------------------------------------------------------------------

/// Muvaffaqiyatli natija.
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  String toString() => 'Success($data)';
}

/// Xato natijasi.
final class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;

  @override
  String toString() => 'Error($failure)';
}

// ---------------------------------------------------------------------------
// Kengaytmalar (extension methods)
// ---------------------------------------------------------------------------

extension ResultExtensions<T> on Result<T> {
  /// Natija muvaffaqiyatli ekanligini tekshiradi.
  bool get isSuccess => this is Success<T>;

  /// Natija xato ekanligini tekshiradi.
  bool get isError => this is Error<T>;

  /// [Success] dagi qiymatni qaytaradi yoki `null`.
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Error() => null,
      };

  /// [Error] dagi xatolikni qaytaradi yoki `null`.
  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error(:final failure) => failure,
      };

  /// Muvaffaqiyat yoki xatolik holatiga qarab funksiya chaqiradi.
  ///
  /// Ikki holatdan biri uchun qiymat qaytaradi.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Error(:final failure) => onError(failure),
    };
  }

  /// Muvaffaqiyatli qiymatni boshqa turga o'zgartiradi.
  ///
  /// Xato holati o'zgarmaydi.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Result.success(transform(data)),
      Error(:final failure) => Result.error(failure),
    };
  }

  /// Muvaffaqiyatli qiymat bo'lmasa [defaultValue] ni qaytaradi.
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(:final data) => data,
      Error() => defaultValue,
    };
  }

  /// Muvaffaqiyatli qiymatni oladi yoki [Exception] tashlaydi.
  T getOrThrow() {
    return switch (this) {
      Success(:final data) => data,
      Error(:final failure) =>
        throw Exception(failure.toUserMessage()),
    };
  }
}
