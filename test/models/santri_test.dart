import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_miftahul_ulumv2/models/santri.dart';

void main() {
  group('Santri Model Unit Tests', () {
    test('Santri.fromJson parses correctly with all data', () {
      final json = {
        'id_santri': 10,
        'nis': '2026001',
        'nama': 'Ahmad',
        'tahun_angkatan': '8A',
        'status': 'aktif',
        'id_ortu': 5,
        'kamar': 'Asrama Putra'
      };

      final santri = Santri.fromJson(json);

      expect(santri.idSantri, 10);
      expect(santri.nis, '2026001');
      expect(santri.nama, 'Ahmad');
      expect(santri.kelas, '8A');
      expect(santri.status, 'aktif');
      expect(santri.idOrtu, 5);
      expect(santri.kamar, 'Asrama Putra');
    });

    test('Santri.fromJson handles missing NIS by falling back to id_santri or dash', () {
      final json = {
        'id_santri': 15,
        'nama': 'Budi',
      };

      final santri = Santri.fromJson(json);

      expect(santri.idSantri, 15);
      // Since nis is missing, it should fallback to id_santri which is 15
      expect(santri.nis, '15');
      expect(santri.nama, 'Budi');
      expect(santri.kelas, '-'); // default value
    });

    test('Santri.fromJson handles null id_santri properly', () {
      final json = {
        'nama': 'Cici',
      };

      final santri = Santri.fromJson(json);

      expect(santri.idSantri, 0); // fallback is 0
      expect(santri.nis, '-'); // fallback is '-' since id_santri is null
      expect(santri.nama, 'Cici');
    });
  });
}
