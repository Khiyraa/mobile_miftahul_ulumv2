class Santri {
  final int idSantri;
  final String nis;
  final String nama;
  final String? tempatLahir;
  final String? tglLahir;
  final String? jenisKelamin;
  final String? alamat;
  final String? noTelp;
  final String? foto;
  final String? kelas;
  final String? kamar;
  final String? status;
  final int? idOrtu;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Santri({
    required this.idSantri,
    required this.nis,
    required this.nama,
    this.tempatLahir,
    this.tglLahir,
    this.jenisKelamin,
    this.alamat,
    this.noTelp,
    this.foto,
    this.kelas,
    this.kamar,
    this.status,
    this.idOrtu,
    this.createdAt,
    this.updatedAt,
  });

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      idSantri: json['id_santri'] is int
          ? json['id_santri']
          : int.tryParse(json['id_santri'].toString()) ?? 0,
      nis: json['nis']?.toString() ?? '',
      nama: json['nama'] ?? '',
      tempatLahir: json['tempat_lahir'],
      tglLahir: json['tgl_lahir'],
      jenisKelamin: json['jenis_kelamin'],
      alamat: json['alamat'],
      noTelp: json['no_telp'],
      foto: json['foto'],
      kelas: json['kelas'],
      kamar: json['kamar'],
      status: json['status'],
      idOrtu: json['id_ortu'] is int
          ? json['id_ortu']
          : int.tryParse(json['id_ortu']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_santri': idSantri,
      'nis': nis,
      'nama': nama,
      'tempat_lahir': tempatLahir,
      'tgl_lahir': tglLahir,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'no_telp': noTelp,
      'foto': foto,
      'kelas': kelas,
      'kamar': kamar,
      'status': status,
      'id_ortu': idOrtu,
    };
  }

  String get fotoUrl {
    if (foto == null || foto!.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    return 'http://localhost:8000/storage/$foto';
  }
}
