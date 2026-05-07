class IzinRequestModel {
  final String idSantri;
  final String jenisIzin;
  final String startDate;
  final String endDate;
  final String alasan;

  IzinRequestModel({
    required this.idSantri,
    required this.jenisIzin,
    required this.startDate,
    required this.endDate,
    required this.alasan,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_santri': idSantri,
      'jenis_izin': jenisIzin,
      'start_date': startDate,
      'end_date': endDate,
      'alasan': alasan,
    };
  }
}
