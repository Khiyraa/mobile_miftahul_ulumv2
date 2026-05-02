import 'package:mobile_miftahul_ulumv2/models/akun_model.dart';

class LoginResponseModel {
  final bool success;
  final String? token;
  final AkunModel? akun;
  final String? message;

  LoginResponseModel({
    required this.success,
    this.token,
    this.akun,
    this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] == true,
      token: json['token']?.toString(),
      akun: json['akun'] != null
          ? AkunModel.fromJson(Map<String, dynamic>.from(json['akun']))
          : null,
      message: json['message']?.toString(),
    );
  }
}
