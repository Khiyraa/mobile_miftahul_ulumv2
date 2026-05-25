import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  try {
    for (int i = 1; i <= 20; i++) {
      final kehadiranMingguanResp = await http.get(
        Uri.parse('https://103.157.27.237/api/kehadiran-mingguan/$i'),
        headers: {'Accept': 'application/json'},
      );
      if (kehadiranMingguanResp.statusCode == 200) {
        final kData = jsonDecode(kehadiranMingguanResp.body);
        if (kData['success'] == true && kData['data'] != null && (kData['data'] as List).isNotEmpty) {
          print('Santri $i: ${kData['data']}');
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
