import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const String _keyToken = 'token';
  static const String _keyIdAkun = 'id_akun';
  static const String _keyEmail = 'email';
  static const String _keyUsername = 'username';
  static const String _keyHakAkses = 'hak_akses';

  static Future<void> saveSession({
    required String token,
    required int idAkun,
    required String email,
    required String username,
    required String hakAkses,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyIdAkun, idAkun);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyHakAkses, hakAkses);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<int?> getIdAkun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyIdAkun);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<String?> getHakAkses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHakAkses);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyIdAkun);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyHakAkses);
  }
}
