import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/auth_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AuthStorage _storage = AuthStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String user, String pass) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.login(user, pass);
      await _storage.saveToken(data['token']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}