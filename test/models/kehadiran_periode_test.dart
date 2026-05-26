import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_miftahul_ulumv2/models/kehadiran_periode.dart';

void main() {
  group('KehadiranPeriode Model Unit Tests', () {
    test('fromFlatJson calculates totals and uses provided persentase', () {
      final json = {
        'hadir': 3,
        'izin': 1,
        'alpha': 2,
        'sakit': 0,
        'total_shalat': 6,
        'persentase': 50.0
      };

      final periode = KehadiranPeriode.fromFlatJson(json);

      expect(periode.totalHadir, 3);
      expect(periode.totalTidakHadir, 3); // izin (1) + alpha (2) + sakit (0)
      expect(periode.totalShalat, 6); // Uses total_shalat from json
      expect(periode.persentase, 50.0); // Uses persentase from json
    });

    test('fromFlatJson calculates persentase and totalShalat if not provided', () {
      final json = {
        'hadir': 4,
        'izin': 1,
        'alpha': 0,
        'sakit': 0,
      };

      final periode = KehadiranPeriode.fromFlatJson(json);

      expect(periode.totalHadir, 4);
      expect(periode.totalTidakHadir, 1);
      // totalShalat = hadir(4) + tidak_hadir(1) = 5
      expect(periode.totalShalat, 5); 
      // persentase = 4 / 5 * 100 = 80.0
      expect(periode.persentase, 80.0); 
    });

    test('fromFlatJson handles zeroes properly to avoid division by zero', () {
      final json = {
        'hadir': 0,
        'izin': 0,
        'alpha': 0,
        'sakit': 0,
      };

      final periode = KehadiranPeriode.fromFlatJson(json);

      expect(periode.totalHadir, 0);
      expect(periode.totalTidakHadir, 0);
      expect(periode.totalShalat, 0);
      expect(periode.persentase, 0.0); 
    });
  });
}
