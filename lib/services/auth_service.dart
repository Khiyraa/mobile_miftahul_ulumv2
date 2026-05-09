import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_miftahul_ulumv2/models/user_model.dart';

abstract class IAuthService {
  Future<UserModel?> login(String email, String password);
  Future<void> logout();
}

class AuthService implements IAuthService {
  static const String _baseUrl = 'http://192.168.1.6:8000/api';

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          // Parse dari key 'akun' sesuai response backend
          return UserModel.fromJson(body['akun']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
