class OrtuModel {
  final String? namaLengkap;
  final String? alamat;
  final String? noTelp;

  OrtuModel({this.namaLengkap, this.alamat, this.noTelp});

  factory OrtuModel.fromJson(Map<String, dynamic> json) {
    return OrtuModel(
      namaLengkap: json['nama_lengkap']?.toString(),
      alamat: json['alamat']?.toString(),
      noTelp: json['no_telp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nama_lengkap': namaLengkap, 'alamat': alamat, 'no_telp': noTelp};
  }
}
