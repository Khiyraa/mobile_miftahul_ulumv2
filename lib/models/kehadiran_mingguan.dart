import 'package:intl/intl.dart';

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
    String parseStatus(dynamic val) {
      if (val == 1 || val == '1') return 'hadir';
      return 'tidak_hadir';
    }

    String hariName = json['hari'] ?? '';
    String? tgl = json['tanggal'];
    if (tgl != null && hariName.isEmpty) {
      try {
        final dt = DateTime.parse(tgl).toLocal();
        hariName = DateFormat('EEEE', 'id_ID').format(dt);
      } catch (e) {
        hariName = '';
      }
    }

    return KehadiranMingguan(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      idSantri: json['id_santri'] is int
          ? json['id_santri']
          : int.tryParse(json['id_santri']?.toString() ?? '0') ?? 0,
      hari: hariName,
      tanggal: tgl,
      subuh: parseStatus(json['Subuh'] ?? json['subuh']),
      dzuhur: parseStatus(json['Dzuhur'] ?? json['dzuhur']),
      ashar: parseStatus(json['Ashar'] ?? json['ashar']),
      maghrib: parseStatus(json['Maghrib'] ?? json['maghrib']),
      isya: parseStatus(json['Isya'] ?? json['isya']),
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
