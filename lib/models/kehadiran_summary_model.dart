class KehadiranSummaryModel {
  final int? hadir;
  final int? izin;

  KehadiranSummaryModel({this.hadir, this.izin});

  factory KehadiranSummaryModel.fromJson(Map<String, dynamic> json) {
    return KehadiranSummaryModel(
      hadir: json['hadir'] is int
          ? json['hadir']
          : int.tryParse(json['hadir']?.toString() ?? ''),
      izin: json['izin'] is int
          ? json['izin']
          : int.tryParse(json['izin']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'hadir': hadir, 'izin': izin};
  }
}
