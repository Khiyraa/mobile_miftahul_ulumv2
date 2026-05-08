import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_miftahul_ulumv2/models/pengumuman_model.dart';
import 'package:mobile_miftahul_ulumv2/models/chat_message_model.dart';
import 'package:mobile_miftahul_ulumv2/models/faq_model.dart';
import 'package:mobile_miftahul_ulumv2/models/izin_model.dart';

// ======================= BAGIAN KEDUA: Fungsi Umum =======================

// Konfigurasi server — ganti sesuai environment:
//   Emulator Android : 'http://10.0.2.2:8000'
//   Real device (LAN): 'http://192.168.x.x:8000'
//   Windows host     : 'http://localhost:8000'
String getBaseUrl() {
  return 'http://10.0.2.2:8000';
}

// ─── Konfigurasi Laravel Reverb (WebSocket) ───────────────────
// Harus sinkron dengan nilai di .env Laravel (REVERB_*)
const String kReverbAppKey = '5e3xxduirsctb4kkd899';
const int    kReverbWsPort = 8080;
const bool   kReverbUseTls = false; // REVERB_SCHEME=http

/// Host Reverb — sama dengan host API tapi port 8080
String getReverbHost() {
  final uri = Uri.parse(getBaseUrl());
  return uri.host; // misal: 10.0.2.2 atau localhost
}

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/login');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return responseData; // Mengembalikan success, token, dan akun
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Login gagal',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}

// API untuk mengirim link reset password
Future<Map<String, dynamic>> sendResetLinkAPI(String email) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/forgot-password'); 
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Link reset berhasil dikirim',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal mengirim link reset',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}

// API untuk verifikasi dan reset password dengan token
Future<Map<String, dynamic>> verifyResetPasswordAPI(
  String email,
  String token,
  String newPassword,
) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/reset-password');
  
  try {
    final requestBody = {
      'email': email,
      'token': token,
      'password': newPassword,
      'password_confirmation': newPassword,
    };
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Password berhasil direset',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? responseData['error'] ?? 'Gagal reset password',
        'errors': responseData['errors'] ?? {},
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}

// ======================= BAGIAN PERTAMA: ApiService & Model =======================

class ApiService {
  // Base URL API
  static final String baseUrl = '${getBaseUrl()}/api';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers default
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ==================== PENGUMUMAN ====================
  Future<List<PengumumanModel>> getPengumuman() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pengumuman'), headers: _headers);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded; // Laravel mereturn List langsung
        } else if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          data = decoded['data'] as List<dynamic>;
        } else {
          data = [];
        }
        return data.map((item) => PengumumanModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil pengumuman.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== DATA SANTRI ====================
  Future<Map<String, dynamic>> getSantriById(String santriId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/santri/$santriId'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body); // Return format: { success, message, data }
      }
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSantriByOrtu(String parentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/santri/ortu/$parentId'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body); // Return format: { success, message, data: [...] }
      }
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== KEHADIRAN ====================
  Future<Map<String, dynamic>> getKehadiranMingguan(String santriId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kehadiran-mingguan/$santriId'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getKehadiranSummary(String santriId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kehadiran-bytime/$santriId'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body); // Return format: { success, data: { hadir, izin } }
      }
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== PERIZINAN ====================
  Future<Map<String, dynamic>> getPerizinan(String santriId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/perizinan/$santriId'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> submitIzin(IzinRequestModel data) async {
    // Sesuaikan endpoint submit izin dengan API yang akan Anda buat
    return true; 
  }

  // ==================== CHAT HISTORY & SEND ====================
  Future<List<ChatMessageModel>> getChatHistory(String parentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$parentId/history'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        return decoded.map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error in getChatHistory: $e');
      return [];
    }
  }

  Future<bool> sendMessage(String parentId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/$parentId/send-api'),
        headers: _headers,
        body: json.encode({'pesan': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      return false;
    }
  }

  // ==================== FAQ ====================
  Future<List<FaqModel>> getFaqList() async {
    // Belum ada rute di web.php / api.php, biarkan dummy
    return [];
  }
}