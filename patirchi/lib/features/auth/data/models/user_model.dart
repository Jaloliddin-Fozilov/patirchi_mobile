import 'package:patirchi/core/constants/enums.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final UserRole role;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    UserRole? role,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt,
    );
  }
}