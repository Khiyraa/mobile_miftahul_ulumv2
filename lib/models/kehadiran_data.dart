import 'kehadiran_periode.dart';

class KehadiranData {
  final KehadiranPeriode seminggu;
  final KehadiranPeriode sebulan;
  final KehadiranPeriode setahun;

  KehadiranData({
    required this.seminggu,
    required this.sebulan,
    required this.setahun,
  });

  factory KehadiranData.fromJson(Map<String, dynamic> json) {
    return KehadiranData(
      seminggu: KehadiranPeriode.fromJson(json['seminggu'] ?? {}),
      sebulan: KehadiranPeriode.fromJson(json['sebulan'] ?? {}),
      setahun: KehadiranPeriode.fromJson(json['setahun'] ?? {}),
    );
  }
}
