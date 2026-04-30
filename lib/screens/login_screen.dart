import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/screens/home_screen.dart';
import 'package:mobile_miftahul_ulumv2/services/auth_service.dart';
import 'package:mobile_miftahul_ulumv2/widgets/custom_text_field.dart';
import 'package:mobile_miftahul_ulumv2/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final user = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login gagal, silakan periksa kredensial Anda.'),
            backgroundColor: AppTheme.tertiary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Intentional Asymmetry: Large headline left, subtle element somewhere else
              Text(
                'Selamat\nDatang.',
                style: AppTheme.displayMd,
              ),
              const SizedBox(height: 12),
              Text(
                'Sistem Monitoring Santri\nMiftahul Ulum',
                style: AppTheme.bodyLg.copyWith(color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 64),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _usernameController,
                      label: 'NISN / Username',
                      hint: 'Masukkan NISN',
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Masukkan kata sandi',
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Masuk',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                      ),
                      child: Text(
                        'Lupa kata sandi?',
                        style: AppTheme.labelMd.copyWith(color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
