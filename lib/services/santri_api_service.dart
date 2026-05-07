import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/santri.dart';
import '../models/kehadiran_mingguan.dart';
import '../models/kehadiran_data.dart';
import '../models/perizinan.dart';

class SantriApiService {
  // Base URL configuration
  static String getBaseUrl() {
    return 'http://localhost:8000/api';
  }

  static final String baseUrl = getBaseUrl();
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Cache untuk menyimpan data sementara
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Helper method untuk cache management
  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamps[key]!) < _cacheExpiry;
  }

  static void _setCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  static T? _getCache<T>(String key) {
    if (_isCacheValid(key)) {
      return _cache[key] as T?;
    }
    return null;
  }

  // Clear cache untuk santri tertentu ketika berganti
  static void clearSantriCache(String santriId) {
    final keysToRemove =
        _cache.keys.where((key) => key.contains(santriId)).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  // Clear all cache
  static void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  // Helper method for HTTP GET requests with caching
  static Future<ApiResponse<T>> _getRequest<T>({
    required String endpoint,
    required T Function(dynamic) fromJson,
    bool useCache = true,
  }) async {
    final cacheKey = endpoint;

    // Check cache first
    if (useCache) {
      final cachedData = _getCache<T>(cacheKey);
      if (cachedData != null) {
        return ApiResponse<T>(
          success: true,
          message: 'Data dari cache',
          data: cachedData,
        );
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonData['success'] == true) {
          final data = fromJson(jsonData['data']);

          // Cache the successful response
          if (useCache) {
            _setCache(cacheKey, data);
          }

          return ApiResponse<T>(
            success: true,
            message: jsonData['message'],
            data: data,
          );
        } else {
          return ApiResponse<T>(
            success: false,
            message: jsonData['message'] ?? 'Request failed',
          );
        }
      } else {
        return ApiResponse<T>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'Network Error: $e');
    }
  }

  // Get all santri
  static Future<ApiResponse<List<Santri>>> getAllSantri({
    bool useCache = true,
  }) async {
    return _getRequest<List<Santri>>(
      endpoint: 'santri',
      fromJson:
          (data) => (data as List).map((e) => Santri.fromJson(e)).toList(),
      useCache: useCache,
    );
  }

  // Get santri by ID with caching
  static Future<ApiResponse<Santri>> getSantriById(
    String id, {
    bool useCache = true,
  }) async {
    return _getRequest<Santri>(
      endpoint: 'santri/$id',
      fromJson: (data) => Santri.fromJson(data),
      useCache: useCache,
    );
  }

  // Get santri by orang tua ID with caching
  static Future<ApiResponse<List<Santri>>> getSantriByOrtuId(
    String idOrtu, {
    bool useCache = true,
  }) async {
    return _getRequest<List<Santri>>(
      endpoint: 'santri/ortu/$idOrtu',
      fromJson:
          (data) => (data as List).map((e) => Santri.fromJson(e)).toList(),
      useCache: useCache,
    );
  }

  // Get santri by orang tua ID from mobile endpoint
  static Future<ApiResponse<List<Santri>>> getSantriByOrtuIdFromMobile(
    String idOrtu, {
    bool useCache = true,
  }) async {
    return _getRequest<List<Santri>>(
      endpoint: 'ortu/$idOrtu',
      fromJson:
          (data) => (data as List).map((e) => Santri.fromJson(e)).toList(),
      useCache: useCache,
    );
  }

  // Get kehadiran mingguan by santri ID with caching
  static Future<ApiResponse<List<KehadiranMingguan>>> getKehadiranMingguan(
    String idSantri, {
    bool useCache = true,
  }) async {
    return _getRequest<List<KehadiranMingguan>>(
      endpoint: 'kehadiran-mingguan/$idSantri',
      fromJson:
          (data) =>
              (data as List).map((e) => KehadiranMingguan.fromJson(e)).toList(),
      useCache: useCache,
    );
  }

  // Get kehadiran by time (seminggu, sebulan, setahun) with caching
  static Future<ApiResponse<KehadiranData>> getKehadiranByTime(
    String idSantri, {
    bool useCache = true,
  }) async {
    return _getRequest<KehadiranData>(
      endpoint: 'kehadiran-bytime/$idSantri',
      fromJson: (data) => KehadiranData.fromJson(data),
      useCache: useCache,
    );
  }

  // Get perizinan setahun by santri ID with caching
  static Future<ApiResponse<List<Perizinan>>> getPerizinanSetahun(
    String idSantri, {
    bool useCache = true,
  }) async {
    return _getRequest<List<Perizinan>>(
      endpoint: 'perizinan/$idSantri',
      fromJson:
          (data) => (data as List).map((e) => Perizinan.fromJson(e)).toList(),
      useCache: useCache,
    );
  }

  // Method untuk refresh data santri tertentu
  static Future<void> refreshSantriData(String santriId) async {
    // Clear cache untuk santri tersebut
    clearSantriCache(santriId);

    // Reload data tanpa cache
    await Future.wait([
      getSantriById(santriId, useCache: false),
      getKehadiranMingguan(santriId, useCache: false),
      getKehadiranByTime(santriId, useCache: false),
      getPerizinanSetahun(santriId, useCache: false),
    ]);
  }

  // Method untuk preload data santri (untuk performa yang lebih baik)
  static Future<void> preloadSantriData(List<String> santriIds) async {
    for (final santriId in santriIds) {
      // Load data di background tanpa await semua sekaligus
      Future.microtask(() async {
        await Future.wait([
          getSantriById(santriId),
          getKehadiranMingguan(santriId),
          getKehadiranByTime(santriId),
          getPerizinanSetahun(santriId),
        ]);
      });
    }
  }
}

// Response wrapper class
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.success({required T data, String message = 'Berhasil'}) {
    return ApiResponse<T>(success: true, message: message, data: data);
  }

  factory ApiResponse.error({required String message}) {
    return ApiResponse<T>(success: false, message: message, error: message);
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }
}
