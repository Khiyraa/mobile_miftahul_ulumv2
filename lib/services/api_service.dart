import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_miftahul_ulumv2/models/pengumuman_model.dart';
import 'package:mobile_miftahul_ulumv2/models/chat_message_model.dart';
import 'package:mobile_miftahul_ulumv2/models/faq_model.dart';
import 'package:mobile_miftahul_ulumv2/models/izin_model.dart';

// ======================= BAGIAN KEDUA: Fungsi Umum =======================

String getBaseUrl() {
  // if (kIsWeb) {
  //   return 'http://127.0.0.1:8000';
  // } else if (Platform.isAndroid) {
  //   return 'http://10.0.2.2:8000';
  // } else {
  //   return 'http://127.0.0.1:8000';
  // }
  // Karena Anda ingin selalu pakai base URL yang tetap ini, kita override semua kondisi:
  return 'http://localhost:8000';
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
      return responseData;
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

// API untuk mengirim link reset password - DIPERBAIKI ENDPOINT NYA
Future<Map<String, dynamic>> sendResetLinkAPI(String email) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/forgot-password'); // UBAH DARI send-reset-link KE forgot-password
  
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
    
    debugPrint('Send Reset Link Response Status: ${response.statusCode}');
    debugPrint('Send Reset Link Response Body: ${response.body}');
    
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
    debugPrint('Send Reset Link Error: $e');
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
    
    debugPrint('Verify Reset Password Request: $requestBody');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    
    debugPrint('Verify Reset Password Response Status: ${response.statusCode}');
    debugPrint('Verify Reset Password Response Body: ${response.body}');
    
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
    debugPrint('Verify Reset Password Error: $e');
    return {
      'success': false,
      'message': 'Terjadi kesalahan: $e',
    };
  }
}

// ======================= BAGIAN PERTAMA: ApiService & Model =======================

class ApiService {
  // Base URL API yang baru
  static final String baseUrl = 'http://localhost:8000/api';

  // Singleton pattern untuk memastikan hanya ada satu instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers default untuk request
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Method untuk mengambil data pengumuman
  Future<List<PengumumanModel>> getPengumuman() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengumuman'),
        headers: _headers,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        List<dynamic> data;

        if (decoded is List) {
          // Server mengembalikan List langsung (e.g. [])
          data = decoded;
        } else if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          // Server mengembalikan {data: [...]}
          data = decoded['data'] as List<dynamic>;
        } else {
          data = [];
        }

        debugPrint('Data count: ${data.length}');

        return data.map((item) => PengumumanModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Gagal mengambil pengumuman. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in getPengumuman: $e');
      throw Exception('Error: $e');
    }
  }

  // ======================= DUMMY METHODS (KOSONG) =======================
  // Silakan integrasikan dengan backend web nantinya.

  Future<List<ChatMessageModel>> getChatHistory() async {
    // Return empty list until backend is ready
    return [];
  }

  Future<List<FaqModel>> getFaqList() async {
    // Return empty list until backend is ready
    return [];
  }

  Future<bool> submitIzin(IzinRequestModel data) async {
    // Return true for now to simulate success until backend is ready
    return true;
  }
}
