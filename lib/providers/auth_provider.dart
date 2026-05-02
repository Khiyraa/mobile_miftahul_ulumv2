import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);

      if (user == null) {
        errorMessage = 'Login gagal, silakan periksa email dan password Anda.';
        return false;
      }

      return true;
    } catch (e) {
      errorMessage = 'Tidak dapat terhubung ke server.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
