class Perizinan {
  final int idPerizinan;
  final int idSantri;
  final String jenisIzin;
  final String alasan;
  final String tglMulai;
  final String tglSelesai;
  final String status;
  final String? keterangan;
  final String? catatan; // New field
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
    this.catatan,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Perizinan.fromJson(Map<String, dynamic> json) {
    return Perizinan(
      // The API returns 'id', fallback to 'id_perizinan' if from older endpoint
      idPerizinan: json['id'] is int 
          ? json['id']
          : (json['id_perizinan'] is int ? json['id_perizinan'] : int.tryParse(json['id']?.toString() ?? json['id_perizinan']?.toString() ?? '0') ?? 0),
      
      // The API riwayat doesn't return student_id actually! We might need to handle this or modify API.
      // Wait, let's just make it default to 0 if not present.
      idSantri: json['student_id'] is int 
          ? json['student_id']
          : (json['id_santri'] is int ? json['id_santri'] : int.tryParse(json['student_id']?.toString() ?? json['id_santri']?.toString() ?? '0') ?? 0),
      
      // API returns 'jenis'
      jenisIzin: json['jenis'] ?? json['jenis_izin'] ?? '',
      
      // API returns 'keterangan' for the reason OF the permit (alasan in Dart)
      alasan: json['keterangan'] ?? json['alasan'] ?? '',
      
      // tgl_mulai / tanggal_mulai
      tglMulai: json['tanggal_mulai'] ?? json['tgl_mulai'] ?? '',
      tglSelesai: json['tanggal_selesai'] ?? json['tgl_selesai'] ?? '',
      
      status: json['status'] ?? 'pending',
      
      // New field for admin rejection notes
      catatan: json['catatan'],
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
