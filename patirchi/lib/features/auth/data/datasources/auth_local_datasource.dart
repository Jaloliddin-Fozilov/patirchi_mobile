import 'package:patirchi/core/constants/enums.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel> login(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: '1',
      name: 'Demo User',
      phone: phone,
      email: 'demo@patirchi.uz',
      role: UserRole.buyer,
      createdAt: DateTime(2026, 2, 24),
    );
    return _currentUser!;
  }

  Future<UserModel> register(String name, String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: '1',
      name: name,
      phone: phone,
      role: UserRole.buyer,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  void switchRole(UserRole role) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
    }
  }

  void logout() {
    _currentUser = null;
  }
}