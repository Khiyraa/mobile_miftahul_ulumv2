class UserModel {
  final String id;
  final String name;
  final String email;
  final String relationship;
  final String phone;
  final String address;
  final String role;
  final String token; // ← tambah ini

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.relationship,
    required this.phone,
    this.address = '',
    this.role = 'ortu',
    this.token = '', // ← tambah ini
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:           json['id_akun']?.toString() ?? '',
      name:         json['username'] ?? '',
      email:        json['email'] ?? '',
      relationship: json['relationship'] ?? '',
      phone:        json['phone'] ?? '',
      address:      json['address'] ?? '',
      role:         json['hak_akses'] ?? 'ortu',
      token:        json['token'] ?? '', // ← tambah ini
    );
  }
}