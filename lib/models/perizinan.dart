class Perizinan {
  final int idPerizinan;
  final int idSantri;
  final String jenisIzin;
  final String alasan;
  final String tglMulai;
  final String tglSelesai;
  final String status;
  final String? keterangan;
  final String? approvedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Perizinan({
    required this.idPerizinan,
    required this.idSantri,
    required this.jenisIzin,
    required this.alasan,
    required this.tglMulai,
    required this.tglSelesai,
    required this.status,
    this.keterangan,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Perizinan.fromJson(Map<String, dynamic> json) {
    return Perizinan(
      idPerizinan: json['id_perizinan'] is int
          ? json['id_perizinan']
          : int.tryParse(json['id_perizinan']?.toString() ?? '0') ?? 0,
      idSantri: json['id_santri'] is int
          ? json['id_santri']
          : int.tryParse(json['id_santri']?.toString() ?? '0') ?? 0,
      jenisIzin: json['jenis_izin'] ?? '',
      alasan: json['alasan'] ?? '',
      tglMulai: json['tgl_mulai'] ?? '',
      tglSelesai: json['tgl_selesai'] ?? '',
      status: json['status'] ?? 'pending',
      keterangan: json['keterangan'],
      approvedBy: json['approved_by'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Label status yang ramah user
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return 'DISETUJUI';
      case 'ditolak':
        return 'DITOLAK';
      case 'pending':
        return 'MENUNGGU';
      default:
        return status.toUpperCase();
    }
  }

  /// Apakah perizinan masih berlaku
  bool get isActive {
    try {
      final now = DateTime.now();
      final end = DateTime.parse(tglSelesai);
      return now.isBefore(end.add(const Duration(days: 1))) && status.toLowerCase() == 'disetujui';
    } catch (_) {
      return false;
    }
  }
}
