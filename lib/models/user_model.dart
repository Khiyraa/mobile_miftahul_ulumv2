class UserModel {
  final String id;
  final String name;
  final String nisn;
  final String role;
  final String profileImageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.nisn,
    required this.role,
    this.profileImageUrl = '',
  });

  // Factory constructor to simulate JSON parsing (OOP concept: Encapsulation)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nisn: json['nisn'] ?? '',
      role: json['role'] ?? 'Santri',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}
