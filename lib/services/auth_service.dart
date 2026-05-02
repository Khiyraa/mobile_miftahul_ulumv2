import 'package:dio/dio.dart';
import 'package:mobile_miftahul_ulumv2/core/constants/api_constants.dart';
import 'package:mobile_miftahul_ulumv2/core/network/api_client.dart';
import 'package:mobile_miftahul_ulumv2/core/storage/session_storage.dart';
import 'package:mobile_miftahul_ulumv2/models/user_model.dart';

abstract class IAuthService {
  Future<UserModel?> login(String username, String password);
  Future<void> logout();
}

class AuthService implements IAuthService {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': username, // Using username field for email as per API spec
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['success'] == true) {
          final token = data['token']?.toString();
          final akunData = data['akun'];

          if (token != null && akunData != null) {
            final idAkun =
                int.tryParse(akunData['id_akun']?.toString() ?? '0') ?? 0;
            final email = akunData['email']?.toString() ?? '';
            final usernameAkun = akunData['username']?.toString() ?? '';
            final hakAkses = akunData['hak_akses']?.toString() ?? '';

            await SessionStorage.saveSession(
              token: token,
              idAkun: idAkun,
              email: email,
              username: usernameAkun,
              hakAkses: hakAkses,
            );

            // Mapping to existing UserModel to keep UI intact
            return UserModel(
              id: idAkun.toString(),
              name: usernameAkun,
              nisn: email,
              role: hakAkses,
            );
          }
        }
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await SessionStorage.clearSession();
  }
}
