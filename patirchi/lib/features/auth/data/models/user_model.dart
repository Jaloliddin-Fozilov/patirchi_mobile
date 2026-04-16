/// Backend `/auth/me/` endpoint javobi bilan mos keladigan foydalanuvchi modeli.
///
/// Backend formati:
/// ```json
/// {
///   "id": 1,
///   "phone_number": "+998901234567",
///   "username": "john_doe",
///   "first_name": "John",
///   "last_name": "Doe",
///   "role": "ordinary",
///   "profile_picture": "https://...",
///   "date_joined": "2024-01-01T00:00:00Z"
/// }
/// ```
class UserModel {
  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profilePicture,
    required this.dateJoined,
  });

  /// Backend dan kelgan int ID.
  final int id;

  /// Telefon raqami: `+998XXXXXXXXX`.
  final String phoneNumber;

  /// Foydalanuvchi nomi (ixtiyoriy).
  final String? username;

  /// Ism.
  final String firstName;

  /// Familiya.
  final String lastName;

  /// Rol: `ordinary`, `business`, `hybrid`, `admin`, `delivery`.
  final String role;

  /// Profil rasm URL (ixtiyoriy).
  final String? profilePicture;

  /// Ro'yxatdan o'tish sanasi.
  final DateTime dateJoined;

  // ---------------------------------------------------------------------------
  // Yordamchi getter'lar
  // ---------------------------------------------------------------------------

  /// To'liq ism (bo'sh bo'lsa username yoki telefon qaytaradi).
  String get fullName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    if (username != null && username!.isNotEmpty) return username!;
    return phoneNumber;
  }

  /// Biznes akkauntimi? (`business` yoki `hybrid` rol).
  bool get isBusiness => role == 'business' || role == 'hybrid';

  /// Yetkazuvchimi?
  bool get isDelivery => role == 'delivery';

  /// Adminmi?
  bool get isAdmin => role == 'admin';

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      phoneNumber: json['phone_number'] as String? ?? '',
      username: json['username'] as String?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: json['role'] as String? ?? 'ordinary',
      profilePicture: json['profile_picture'] as String?,
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

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

  UserModel copyWith({
    int? id,
    String? phoneNumber,
    String? username,
    String? firstName,
    String? lastName,
    String? role,
    String? profilePicture,
    DateTime? dateJoined,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, phone: $phoneNumber, role: $role, name: $fullName)';
}
