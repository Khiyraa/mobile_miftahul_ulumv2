import 'dart:convert';
import 'package:mobile_miftahul_ulumv2/models/santri.dart';
import 'package:mobile_miftahul_ulumv2/models/kehadiran_mingguan.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  await initializeDateFormatting('id_ID', null);

  try {
    final response = await http.get(
      Uri.parse('https://103.157.27.237/api/santri/5'),
      headers: {'Accept': 'application/json'},
    );
    final data = jsonDecode(response.body);
    final santri = Santri.fromJson(data['data']);
    print('Parsed Santri: NIS=${santri.nis}, Kelas=${santri.kelas}, Kamar=${santri.kamar}');

    final kehadiranMingguanResp = await http.get(
      Uri.parse('https://103.157.27.237/api/kehadiran-mingguan/5'),
      headers: {'Accept': 'application/json'},
    );
    final kData = jsonDecode(kehadiranMingguanResp.body);
    final listKehadiran = (kData['data'] as List).map((e) => KehadiranMingguan.fromJson(e)).toList();
    
    for (var k in listKehadiran) {
      print('Kehadiran: Hari=${k.hari}, Tanggal=${k.tanggal}, Subuh=${k.subuh}, Dzuhur=${k.dzuhur}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
