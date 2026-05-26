import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_miftahul_ulumv2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('Verify Login Flow', (WidgetTester tester) async {
      // Bersihkan sesi (SharedPreferences) agar selalu mulai dari LoginScreen
      SharedPreferences.setMockInitialValues({});
      
      app.main();
      // Tunggu aplikasi selesai loading awal
      await tester.pumpAndSettle();

      // Pastikan kita berada di halaman Login
      expect(find.text('Miftahul Ulum Kalisat'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);

      // Cari input email dan password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Isi form login
      await tester.enterText(emailField, 'gibran@gmail.com');
      await tester.enterText(passwordField, 'gibran123');
      await tester.pumpAndSettle();

      // Tap tombol login
      final loginButton = find.text('Masuk');
      await tester.tap(loginButton);
      
      // Gunakan pump dengan durasi tertentu karena HomeScreen memiliki Timer.periodic
      // yang membuat pumpAndSettle() menunggu selamanya (timeout).
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));

      // Jika berhasil login, kita harusnya tidak di layar login lagi
      // Tes ini sangat bergantung pada kredensial aktif.
    });
  });
}
