import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/screens/home_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/login_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/forgot_password_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/verify_code_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/santri_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final prefs = await SharedPreferences.getInstance();
  final parentId = prefs.getString('parentId') ?? '';
  final isLoggedIn = parentId.isNotEmpty;

  runApp(MyApp(initialRoute: isLoggedIn ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miftahul Ulum Kalisat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/verify_code': (context) => const VerifyCodeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/santri_detail/')) {
          final santriId = settings.name!.replaceFirst('/santri_detail/', '');
          return MaterialPageRoute(
            builder: (context) => SantriDetailScreen(santriId: santriId),
          );
        }
        return null;
      },
    );
  }
}

