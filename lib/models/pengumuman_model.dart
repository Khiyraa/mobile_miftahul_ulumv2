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
      return PengumumanModel(
        id: json['id_pengumuman'] is int
            ? json['id_pengumuman']
            : int.tryParse(json['id_pengumuman'].toString()) ?? 0,
        judul: json['judul'] ?? '',
        isi: json['isi'] ?? '',
        kategori: json['kategori'] ?? '',
        tglMulai: _parseDateTime(json['tgl_mulai']),
        tglSelesai: _parseDateTime(json['tgl_selesai']),
        foto: json['foto'],
        idAkun: json['id_akun'] is int
            ? json['id_akun']
            : int.tryParse(json['id_akun'].toString()) ?? 0,
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
