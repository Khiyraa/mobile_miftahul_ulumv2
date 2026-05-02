class AkunModel {
  final int idAkun;
  final String email;
  final String username;
  final String hakAkses;

  AkunModel({
    required this.idAkun,
    required this.email,
    required this.username,
    required this.hakAkses,
  });

  factory AkunModel.fromJson(Map<String, dynamic> json) {
    return AkunModel(
      idAkun: json['id_akun'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      hakAkses: json['hak_akses'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_akun': idAkun,
      'email': email,
      'username': username,
      'hak_akses': hakAkses,
    };
  }
}
