import 'package:mobile_miftahul_ulumv2/models/user_model.dart';

abstract class IAuthService {
  Future<UserModel?> login(String username, String password);
  Future<void> logout();
}

class AuthService implements IAuthService {
  @override
  Future<UserModel?> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Dummy login logic
    if (username.isNotEmpty && password.isNotEmpty) {
      return UserModel(
        id: '1',
        name: 'Ahmad Santoso',
        nisn: '1234567890',
        role: 'Santri',
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    // Simulate logout
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
