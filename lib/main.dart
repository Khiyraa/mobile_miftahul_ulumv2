import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/screens/home_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/login_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/forgot_password_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/verify_code_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/santri_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Miftahul Ulum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/verify_code': (context) => const VerifyCodeScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes like /santri_detail/:id
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

