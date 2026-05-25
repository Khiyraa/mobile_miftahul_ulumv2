class KehadiranPeriode {
  final int totalHadir;
  final int totalTidakHadir;
  final int totalShalat;
  final double persentase;

  KehadiranPeriode({
    required this.totalHadir,
    required this.totalTidakHadir,
    required this.totalShalat,
    required this.persentase,
  });

  factory KehadiranPeriode.fromJson(Map<String, dynamic> json) {
    return KehadiranPeriode(
      totalHadir: json['total_hadir'] is int
          ? json['total_hadir']
          : int.tryParse(json['total_hadir']?.toString() ?? '0') ?? 0,
      totalTidakHadir: json['total_tidak_hadir'] is int
          ? json['total_tidak_hadir']
          : int.tryParse(json['total_tidak_hadir']?.toString() ?? '0') ?? 0,
      totalShalat: json['total_shalat'] is int
          ? json['total_shalat']
          : int.tryParse(json['total_shalat']?.toString() ?? '0') ?? 0,
      persentase: json['persentase'] is double
          ? json['persentase']
          : double.tryParse(json['persentase']?.toString() ?? '0') ?? 0.0,
    );
  }

  factory KehadiranPeriode.fromFlatJson(Map<String, dynamic> json) {
    int hadir = json['hadir'] is int ? json['hadir'] : int.tryParse(json['hadir']?.toString() ?? '0') ?? 0;
    int izin = json['izin'] is int ? json['izin'] : int.tryParse(json['izin']?.toString() ?? '0') ?? 0;
    int alpha = json['alpha'] is int ? json['alpha'] : int.tryParse(json['alpha']?.toString() ?? '0') ?? 0;
    int sakit = json['sakit'] is int ? json['sakit'] : int.tryParse(json['sakit']?.toString() ?? '0') ?? 0;
    
    int totalTidakHadir = izin + alpha + sakit;
    
    int totalShalat = json.containsKey('total_shalat')
        ? (json['total_shalat'] is int ? json['total_shalat'] : int.tryParse(json['total_shalat']?.toString() ?? '0') ?? 0)
        : (hadir + totalTidakHadir);

    double persentase = json.containsKey('persentase')
        ? (json['persentase'] is num ? (json['persentase'] as num).toDouble() : double.tryParse(json['persentase']?.toString() ?? '0') ?? 0.0)
        : (totalShalat > 0 ? (hadir / totalShalat) * 100 : 0.0);
    
    return KehadiranPeriode(
      totalHadir: hadir,
      totalTidakHadir: totalTidakHadir,
      totalShalat: totalShalat,
      persentase: persentase,
    );
  }
}
