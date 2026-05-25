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
    final res1 = await http.get(Uri.parse('https://103.157.27.237/api/kehadiran-bytime/5?period=minggu'), headers: {'Accept': 'application/json'});
    print('minggu: ${res1.body}');
    
    final res2 = await http.get(Uri.parse('https://103.157.27.237/api/kehadiran-bytime/5?period=bulan'), headers: {'Accept': 'application/json'});
    print('bulan: ${res2.body}');
  } catch (e) {
    print('Error: $e');
  }
}
