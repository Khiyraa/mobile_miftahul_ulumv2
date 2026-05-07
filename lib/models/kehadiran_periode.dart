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
}
