class IzinRequestModel {
  final int studentId;
  final String jenis; // 'keluar', 'pulang', 'kegiatan', 'sakit'
  final String tanggalMulai;
  final String tanggalSelesai;
  final String keterangan;

  IzinRequestModel({
    required this.studentId,
    required this.jenis,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.keterangan,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'jenis': jenis,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'keterangan': keterangan,
    };
  }
}
