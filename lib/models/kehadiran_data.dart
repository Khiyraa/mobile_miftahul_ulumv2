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
    if (json.containsKey('seminggu') || json.containsKey('sebulan') || json.containsKey('setahun')) {
      return KehadiranData(
        seminggu: KehadiranPeriode.fromJson(json['seminggu'] ?? {}),
        sebulan: KehadiranPeriode.fromJson(json['sebulan'] ?? {}),
        setahun: KehadiranPeriode.fromJson(json['setahun'] ?? {}),
      );
    } else {
      final periode = KehadiranPeriode.fromFlatJson(json);
      return KehadiranData(
        seminggu: periode,
        sebulan: periode,
        setahun: periode,
      );
    }
  }
}
