class KehadiranMingguan {
  final int id;
  final int idSantri;
  final String hari;
  final String? tanggal;
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KehadiranMingguan({
    required this.id,
    required this.idSantri,
    required this.hari,
    this.tanggal,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    this.createdAt,
    this.updatedAt,
  });

  factory KehadiranMingguan.fromJson(Map<String, dynamic> json) {
    return KehadiranMingguan(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      idSantri: json['id_santri'] is int
          ? json['id_santri']
          : int.tryParse(json['id_santri'].toString()) ?? 0,
      hari: json['hari'] ?? '',
      tanggal: json['tanggal'],
      subuh: json['subuh'] ?? 'tidak_hadir',
      dzuhur: json['dzuhur'] ?? 'tidak_hadir',
      ashar: json['ashar'] ?? 'tidak_hadir',
      maghrib: json['maghrib'] ?? 'tidak_hadir',
      isya: json['isya'] ?? 'tidak_hadir',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Menghitung jumlah kehadiran pada hari ini (dari 5 waktu shalat)
  int get totalHadir {
    int count = 0;
    if (subuh == 'hadir') count++;
    if (dzuhur == 'hadir') count++;
    if (ashar == 'hadir') count++;
    if (maghrib == 'hadir') count++;
    if (isya == 'hadir') count++;
    return count;
  }

  double get persentaseHadir => (totalHadir / 5) * 100;
}
