class KehadiranMingguanModel {
  final String? tanggal;
  final int? jumlahKehadiran;
  final int? subuh;
  final int? dzuhur;
  final int? ashar;
  final int? maghrib;
  final int? isya;
  final String? jamMasukSubuh;
  final String? jamKeluarSubuh;
  final String? jamMasukDzuhur;
  final String? jamKeluarDzuhur;
  final String? jamMasukAshar;
  final String? jamKeluarAshar;
  final String? jamMasukMaghrib;
  final String? jamKeluarMaghrib;
  final String? jamMasukIsya;
  final String? jamKeluarIsya;

  KehadiranMingguanModel({
    this.tanggal,
    this.jumlahKehadiran,
    this.subuh,
    this.dzuhur,
    this.ashar,
    this.maghrib,
    this.isya,
    this.jamMasukSubuh,
    this.jamKeluarSubuh,
    this.jamMasukDzuhur,
    this.jamKeluarDzuhur,
    this.jamMasukAshar,
    this.jamKeluarAshar,
    this.jamMasukMaghrib,
    this.jamKeluarMaghrib,
    this.jamMasukIsya,
    this.jamKeluarIsya,
  });

  factory KehadiranMingguanModel.fromJson(Map<String, dynamic> json) {
    return KehadiranMingguanModel(
      tanggal: json['tanggal']?.toString(),
      jumlahKehadiran: json['jumlah_kehadiran'] is int
          ? json['jumlah_kehadiran']
          : int.tryParse(json['jumlah_kehadiran']?.toString() ?? ''),
      subuh: json['Subuh'] is int
          ? json['Subuh']
          : int.tryParse(json['Subuh']?.toString() ?? ''),
      dzuhur: json['Dzuhur'] is int
          ? json['Dzuhur']
          : int.tryParse(json['Dzuhur']?.toString() ?? ''),
      ashar: json['Ashar'] is int
          ? json['Ashar']
          : int.tryParse(json['Ashar']?.toString() ?? ''),
      maghrib: json['Maghrib'] is int
          ? json['Maghrib']
          : int.tryParse(json['Maghrib']?.toString() ?? ''),
      isya: json['Isya'] is int
          ? json['Isya']
          : int.tryParse(json['Isya']?.toString() ?? ''),
      jamMasukSubuh: json['jam_masuk_subuh']?.toString(),
      jamKeluarSubuh: json['jam_keluar_subuh']?.toString(),
      jamMasukDzuhur: json['jam_masuk_dzuhur']?.toString(),
      jamKeluarDzuhur: json['jam_keluar_dzuhur']?.toString(),
      jamMasukAshar: json['jam_masuk_ashar']?.toString(),
      jamKeluarAshar: json['jam_keluar_ashar']?.toString(),
      jamMasukMaghrib: json['jam_masuk_maghrib']?.toString(),
      jamKeluarMaghrib: json['jam_keluar_maghrib']?.toString(),
      jamMasukIsya: json['jam_masuk_isya']?.toString(),
      jamKeluarIsya: json['jam_keluar_isya']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'jumlah_kehadiran': jumlahKehadiran,
      'Subuh': subuh,
      'Dzuhur': dzuhur,
      'Ashar': ashar,
      'Maghrib': maghrib,
      'Isya': isya,
      'jam_masuk_subuh': jamMasukSubuh,
      'jam_keluar_subuh': jamKeluarSubuh,
      'jam_masuk_dzuhur': jamMasukDzuhur,
      'jam_keluar_dzuhur': jamKeluarDzuhur,
      'jam_masuk_ashar': jamMasukAshar,
      'jam_keluar_ashar': jamKeluarAshar,
      'jam_masuk_maghrib': jamMasukMaghrib,
      'jam_keluar_maghrib': jamKeluarMaghrib,
      'jam_masuk_isya': jamMasukIsya,
      'jam_keluar_isya': jamKeluarIsya,
    };
  }
}
