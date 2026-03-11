import 'package:flutter/material.dart';
import 'package:patirchi/core/constants/enums.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthLocalDatasource _datasource = AuthLocalDatasource();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  UserModel? _currentUser;
  UserRole _selectedRole = UserRole.buyer;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  UserRole get selectedRole => _selectedRole;

  void selectRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _datasource.login(phone, password);
      _currentUser = _currentUser!.copyWith(role: _selectedRole);
      _datasource.switchRole(_selectedRole);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String phone, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _datasource.register(name, phone, password);
      _currentUser = _currentUser!.copyWith(role: _selectedRole);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void switchRole(UserRole role) {
    _selectedRole = role;
    _datasource.switchRole(role);
    _currentUser = _currentUser?.copyWith(role: role);
    notifyListeners();
  }

  void logout() {
    _datasource.logout();
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}