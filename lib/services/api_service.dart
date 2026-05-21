import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_miftahul_ulumv2/models/pengumuman_model.dart';
import 'package:mobile_miftahul_ulumv2/models/chat_message_model.dart';
import 'package:mobile_miftahul_ulumv2/models/faq_model.dart';
import 'package:mobile_miftahul_ulumv2/models/izin_model.dart';

// ======================= BAGIAN KEDUA: Fungsi Umum =======================

// Konfigurasi server — VPS Production
const String _kVpsBaseUrl = 'http://103.157.27.237';

String getBaseUrl() {
  return _kVpsBaseUrl;
}

// ─── Konfigurasi Laravel Reverb (WebSocket) ───────────────────
// Harus sinkron dengan nilai di .env Laravel (REVERB_*)
const String kReverbAppKey = '5e3xxduirsctb4kkd899';
const int kReverbWsPort = 8081;
const bool kReverbUseTls = false; // REVERB_SCHEME=http

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
      return responseData;
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Login gagal',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
  }
}

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
      body: jsonEncode({'email': email}),
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
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
  }
}

Future<Map<String, dynamic>> verifyResetPasswordAPI(
  String email,
  String token,
  String newPassword,
) async {
  final baseUrl = getBaseUrl();
  final url = Uri.parse('$baseUrl/api/reset-password');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'token': token,
        'password': newPassword,
        'password_confirmation': newPassword,
      }),
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
        'message':
            responseData['message'] ??
            responseData['error'] ??
            'Gagal reset password',
        'errors': responseData['errors'] ?? {},
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Terjadi kesalahan: $e'};
  }
}

// ======================= BAGIAN PERTAMA: ApiService =======================

class ApiService {
  static final String baseUrl = '${getBaseUrl()}/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ==================== PENGUMUMAN ====================

  Future<List<PengumumanModel>> getPengumuman() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengumuman'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> data;

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic> &&
            decoded.containsKey('data')) {
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
      final response = await http.get(
        Uri.parse('$baseUrl/santri/$santriId'),
        headers: _headers,
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSantriByOrtu(String parentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/santri/ortu/$parentId'),
        headers: _headers,
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== KEHADIRAN ====================

  Future<Map<String, dynamic>> getKehadiranMingguan(String santriId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kehadiran-mingguan/$santriId'),
        headers: _headers,
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getKehadiranSummary(String santriId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kehadiran-bytime/$santriId'),
        headers: _headers,
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== PERIZINAN ====================

  Future<Map<String, dynamic>> getPerizinan(String santriId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/perizinan/$santriId'),
        headers: _headers,
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {'success': false, 'message': 'Gagal mengambil data'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> submitIzin(IzinRequestModel data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/perizinan'),
        headers: _headers,
        body: jsonEncode(data.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Izin berhasil diajukan'};
      }
      final decoded = json.decode(response.body);
      return {
        'success': false,
        'message': decoded['message'] ?? 'Gagal mengajukan izin',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== CHAT ====================

  Future<List<ChatMessageModel>> getChatHistory(String parentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$parentId/history'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        return decoded
            .map(
              (item) => ChatMessageModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
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

  /// Ambil semua FAQ aktif dari backend.
  ///
  /// [search]   → kata kunci pencarian (opsional)
  /// [kategori] → filter per kategori (opsional)
  ///
  /// Mengembalikan [FaqResponse] yang berisi list FAQ dan daftar kategori.
  Future<FaqResponse> getFaqs({String? search, String? kategori}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (kategori != null && kategori.trim().isNotEmpty) {
        queryParams['kategori'] = kategori.trim();
      }

      final uri = Uri.parse(
        '$baseUrl/faq',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return FaqResponse.fromJson(decoded);
      } else {
        debugPrint('FAQ API error ${response.statusCode}: ${response.body}');
        throw Exception('Gagal mengambil FAQ (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('getFaqs error: $e');
      rethrow;
    }
  }

  /// Alias sederhana — kembalikan hanya list [FaqModel].
  Future<List<FaqModel>> getFaqList({String? search, String? kategori}) async {
    final res = await getFaqs(search: search, kategori: kategori);
    return res.data;
  }

  /// Ambil detail satu FAQ berdasarkan [id].
  Future<FaqModel?> getFaqById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/faq/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return FaqModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('getFaqById error: $e');
      return null;
    }
  }
  Future<bool> saveFcmToken({required String authToken, required String fcmToken}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('saveFcmToken error: $e');
      return false;
    }
  }
}
