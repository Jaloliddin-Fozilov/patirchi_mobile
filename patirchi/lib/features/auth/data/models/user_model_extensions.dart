import 'package:patirchi/features/auth/data/models/user_model.dart';

/// [UserModel] uchun eski JSON serializatsiya kengaytmalari.
///
/// [UserModel] endi o'zida `fromJson`/`toJson` metodlariga ega.
/// Bu kengaytma eski kod bilan orqaga mos kelish uchun saqlanadi.
@Deprecated(
  'UserModel now has built-in fromJson/toJson. '
  'Use UserModel.fromJson() and model.toJson() directly.',
)
extension UserModelJson on UserModel {
  /// JSON xaritasidan [UserModel] yaratadi.
  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }

  /// [UserModel] ni JSON xaritasiga aylantiradi.
  Map<String, dynamic> toJson() => {
        'id': id,
        'phone_number': phoneNumber,
        if (username != null) 'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
        if (profilePicture != null) 'profile_picture': profilePicture,
        'date_joined': dateJoined.toIso8601String(),
      };
}
