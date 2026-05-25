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
    for (int i = 1; i <= 10; i++) {
      final response = await http.get(
        Uri.parse('https://103.157.27.237/api/santri/$i'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('Found Santri $i: ${data['data']}');
          
          final kehadiranMingguanResp = await http.get(
            Uri.parse('https://103.157.27.237/api/kehadiran-mingguan/$i'),
            headers: {'Accept': 'application/json'},
          );
          print('Kehadiran Mingguan $i: ${kehadiranMingguanResp.body}');
          
          final kehadiranByTimeResp = await http.get(
            Uri.parse('https://103.157.27.237/api/kehadiran-bytime/$i'),
            headers: {'Accept': 'application/json'},
          );
          print('Kehadiran By Time $i: ${kehadiranByTimeResp.body}');
          break;
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
