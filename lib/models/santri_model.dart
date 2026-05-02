import 'package:mobile_miftahul_ulumv2/models/ortu_model.dart';

class SantriModel {
  final String idSantri;
  final String nama;
  final String? tahunAngkatan;
  final String? sidikJari;
  final String? status;
  final int? idOrtu;
  final OrtuModel? ortu;

  SantriModel({
    required this.idSantri,
    required this.nama,
    this.tahunAngkatan,
    this.sidikJari,
    this.status,
    this.idOrtu,
    this.ortu,
  });

  factory SantriModel.fromJson(Map<String, dynamic> json) {
    int? parseIdOrtu(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return SantriModel(
      idSantri: json['id_santri']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      tahunAngkatan: json['tahun_angkatan']?.toString(),
      sidikJari: json['sidik_jari']?.toString(),
      status: json['status']?.toString(),
      idOrtu: parseIdOrtu(json['id_ortu']),
      ortu: json['ortu'] != null ? OrtuModel.fromJson(json['ortu']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_santri': idSantri,
      'nama': nama,
      'tahun_angkatan': tahunAngkatan,
      'sidik_jari': sidikJari,
      'status': status,
      'id_ortu': idOrtu,
      'ortu': ortu?.toJson(),
    };
  }
}
