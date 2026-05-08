import 'package:flutter/material.dart';


class PengumumanModel {
  final int id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime tglMulai;
  final DateTime tglSelesai;
  final String? foto;
  final int idAkun;
  final DateTime createdAt;
  final DateTime updatedAt;

  PengumumanModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.tglMulai,
    required this.tglSelesai,
    this.foto,
    required this.idAkun,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PengumumanModel.fromJson(Map<String, dynamic> json) {
    try {
      // Field bisa datang dengan beberapa nama berbeda (REST API vs WebSocket payload)
      final rawId    = json['id']        ?? json['id_pengumuman'];
      final rawAkun  = json['id_akun']   ?? json['user_id'] ?? 0;
      final rawIsi   = json['isi']       ?? json['konten']  ?? '';
      final rawMulai = json['tgl_mulai'] ?? json['published_at'] ?? json['created_at'];
      final rawAkhir = json['tgl_selesai']; // null = pengumuman tanpa expiry

      return PengumumanModel(
        id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0,
        judul: (json['judul'] ?? '').toString(),
        isi: rawIsi.toString(),
        kategori: (json['kategori'] ?? 'umum').toString(),
        tglMulai: _parseDateTime(rawMulai),
        // Default 1 tahun ke depan jika tidak ada tgl_selesai
        tglSelesai: rawAkhir != null
            ? _parseDateTime(rawAkhir)
            : DateTime.now().add(const Duration(days: 365)),
        foto: json['foto'] as String?,
        idAkun: rawAkun is int ? rawAkun : int.tryParse(rawAkun.toString()) ?? 0,
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );
    } catch (e) {
      debugPrint('Error parsing PengumumanModel: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        debugPrint('Error parsing date: $dateValue');
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengumuman': id,
      'judul': judul,
      'isi': isi,
      'kategori': kategori,
      'tgl_mulai': tglMulai.toIso8601String(),
      'tgl_selesai': tglSelesai.toIso8601String(),
      'foto': foto,
      'id_akun': idAkun,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    }
  }

  String get prioritas {
    if (kategori.toLowerCase() == 'administrasi') return 'tinggi';
    if (kategori.toLowerCase() == 'akademik') return 'tinggi';
    return 'sedang';
  }

  IconData get icon {
    switch (kategori.toLowerCase()) {
      case 'akademik':
        return Icons.school;
      case 'administrasi':
        return Icons.payment;
      case 'kegiatan':
        return Icons.event;
      default:
        return Icons.announcement;
    }
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(tglMulai.subtract(const Duration(days: 1))) &&
        now.isBefore(tglSelesai.add(const Duration(days: 1)));
  }
}

extension PengumumanModelExtension on PengumumanModel {
  String get fotoUrl {
    if (foto == null || foto!.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    final url = 'http://localhost:8000/storage/$foto';
    return url;
  }
}
