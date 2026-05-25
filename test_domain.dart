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
    // 1. IP - api/ortu/5
    final res1 = await http.get(Uri.parse('https://103.157.27.237/api/ortu/5'), headers: {'Accept': 'application/json'});
    print('IP api/ortu/5: ${res1.body}');

    // 2. Domain - api/ortu/5
    final res2 = await http.get(Uri.parse('https://miftahululumkalisat.web.id/api/ortu/5'), headers: {'Accept': 'application/json'});
    print('Domain api/ortu/5: ${res2.body}');

    // 3. IP - api/santri/5
    final res3 = await http.get(Uri.parse('https://103.157.27.237/api/santri/5'), headers: {'Accept': 'application/json'});
    print('IP api/santri/5: ${res3.body}');
    
    // 4. Domain - api/santri/5
    final res4 = await http.get(Uri.parse('https://miftahululumkalisat.web.id/api/santri/5'), headers: {'Accept': 'application/json'});
    print('Domain api/santri/5: ${res4.body}');

  } catch (e) {
    print('Error: $e');
  }
}
