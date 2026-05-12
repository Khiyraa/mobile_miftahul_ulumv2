import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/screens/forgot_password_screen.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _logoController;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoController.forward(); // Trigger initial subtle scale
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email dan password harus diisi'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await loginUser(email, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true || result['token'] != null) {
        // Simpan data sesi ke SharedPreferences (Gabungan logic branch chat & login)
        final prefs = await SharedPreferences.getInstance();
        final akun = result['akun'] as Map<String, dynamic>?;
        
        if (akun != null) {
          final idAkun = akun['id_akun']?.toString() ?? '';
          
          // Data untuk branch login
          await prefs.setString('id_akun', idAkun);
          
          // Data untuk branch chat
          await prefs.setString('parentId', idAkun);
          await prefs.setString('parentName', akun['username']?.toString() ?? '');
          await prefs.setString('parentEmail', akun['email']?.toString() ?? '');
        }

        final token = result['token']?.toString();
        if (token != null) {
          // Token utama
          await prefs.setString('token', token);
          // Token untuk auth WebSocket Reverb
          await prefs.setString('authToken', token);
        } else if (akun != null) {
          // Fallback dari branch chat jika token dari API kosong
          final idAkun = akun['id_akun']?.toString() ?? '';
          await prefs.setString('authToken', 'dummy-token-$idAkun');
        }

        // Jika tidak centang "Ingat sesi", tandai agar dihapus saat logout
        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setBool('rememberSession', _rememberMe);

        if (!mounted) return;

        // Login berhasil
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login gagal'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // Islamic Pattern Background
          Positioned.fill(
            child: CustomPaint(
              painter: _IslamicPatternPainter(),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Branding Section
                  MouseRegion(
                    onEnter: (_) => _logoController.forward(),
                    onExit: (_) => _logoController.reverse(),
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Miftahul Ulum Kalisat',
                    style: AppTheme.headline.copyWith(
                      fontWeight: FontWeight.w900, // font-black
                      fontSize: 36, // text-4xl
                      letterSpacing: -1, // tracking-tighter
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SISTEM MONITORING SANTRI',
                    style: AppTheme.body.copyWith(
                      fontWeight: FontWeight.w500, // font-medium
                      fontSize: 14, // text-sm
                      letterSpacing: 0.5, // tracking-wide
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Login Container
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 448), // max-w-md
                    padding: const EdgeInsets.all(32), // p-8
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12), // rounded-xl
                      boxShadow: AppTheme.shadowSm,
                      border: Border.all(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Assalamu'alaikum",
                          style: AppTheme.headline.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Masukkan email dan kata sandi Anda untuk melanjutkan.',
                          style: AppTheme.body.copyWith(
                            fontSize: 14,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Identifier Input
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'EMAIL ATAU NOMOR TELEPON',
                            style: AppTheme.body.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          hint: 'name@example.com',
                          icon: Icons.alternate_email,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 24),
                        
                        // Password Input
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'KATA SANDI',
                                style: AppTheme.body.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                                child: Text(
                                  'Lupa kata sandi?',
                                  style: AppTheme.body.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 24),
                        
                        // Remember Me
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() {
                                  _rememberMe = val ?? false;
                                });
                              },
                              activeColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(color: AppTheme.outlineVariant),
                            ),
                            Text(
                              'Ingat sesi ini',
                              style: AppTheme.body.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Login Button
                        AnimatedPressButton(
                          onPressed: _isLoading ? () {} : _onLogin,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _isLoading ? AppTheme.primary.withValues(alpha: 0.7) : AppTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppTheme.shadowLg,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                  const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
                                    ),
                                  )
                                else ...[
                                  Text(
                                    'Masuk',
                                    style: AppTheme.headline.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppTheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: AppTheme.onPrimary,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        
                        // Secondary Actions
                        const SizedBox(height: 32),
                        const Divider(color: Color(0x1ABFCABA)), // outline-variant/10
                        const SizedBox(height: 32),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Belum punya akun? ',
                              style: AppTheme.body.copyWith(
                                fontSize: 14,
                                color: AppTheme.onSurfaceVariant,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Hubungi Administrator',
                                  style: AppTheme.body.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Footer Visual
                  const SizedBox(height: 48),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 512), // max-w-lg
                    child: Row(
                      children: [
                        Expanded(child: _buildFooterImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCw05-TkcsGW70vJeVtgNLMM5y9tCZSST6Sjqg2moVcn4E-7dQzemYd3Q_rP-0qDGd60flCsTQXteg5L6OdQw5iYtjUqid77HZEkH2IGXWmov9Eve9GihaLvX2SMRFqEOoAeBL95KIC7Qw0c3_YAV5V45A4o-RuVHaznEKoWyaBr40Z94vZGVt-f8ICZAO_3v6imJ-gFpoU-TTvcNr1IZVYZRFRUuFu5HH1EWELcrjsf3hNG13iQqOBotdme5xz5P5I32R8m7BXsFRC')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFooterImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAAd_b4RD9d9MZ34cEse1NM2Bsyv_zahJlH4u3fc4MmrWWMxQ3U06VIxwurw0YlNyABMvbB2h5G0mB500aETCz43hjOxF8VaBb8U1XLLJFjq6_fvoCOo7fWPRVBgOymJ81HzuKfVPYOXc9KDlxNh_s7p0icy4TtICfT7eFiP0su6_jc_y5dP9mmMJTtNqbwwVOMxLdU3Fze9Ycj2PkJP17wJt1yW-3aRsMNhJuvzi4aa14l_hiE2M1D3u3PLPn9hTtbDS8zHxr-QJ7r')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFooterImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCtpV3-TkUoKRIGOIirrnm-8Iz-VBuo7deSlMWPg194h-G_wcM4axKlt5H-lXEsRMDcP1GL7wsrowguPHaAN20HJjbmH6KOeg6wHI_tW_GqH1gFxDZGiMRd-k_HaqFAb92jPucBQrMwUU6WcFBmCA1iB2-OPVvF-j1agfSZ4D3TGYks-JLj9p1HcOGYuhFtRr9GtkmLCRvw4W9Menqq5vMPLuVnID5xj-pbdBuSoqU1vfECX3S2U8nh01THsLCLsSsG0ehMzW46rVJw')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '© 2024 PESANTREN MIFTAHUL ULUM KALISAT',
                    style: AppTheme.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppTheme.outline,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          
          // Bottom Decorative Gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 4,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryContainer,
                    AppTheme.secondary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, bool isPassword = false, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        style: AppTheme.body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.body.copyWith(
            color: AppTheme.outline.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(icon, color: AppTheme.outline),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.outline,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFooterImage(String url) {
    return _HoverImage(url: url);
  }
}

class _HoverImage extends StatefulWidget {
  final String url;
  const _HoverImage({required this.url});

  @override
  State<_HoverImage> createState() => _HoverImageState();
}

class _HoverImageState extends State<_HoverImage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        height: 96, // h-24
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: ColorFiltered(
          colorFilter: _isHovered
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
              : const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            opacity: _isHovered ? 1.0 : 0.4,
            child: Image.network(
              widget.url,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Draw repeating pattern across the canvas
    const double patternSize = 60;
    
    for (double x = 0; x < size.width; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        final path = Path();
        // Shift context
        path.moveTo(x + 30, y + 0);
        path.lineTo(x + 32.5, y + 7.5);
        path.lineTo(x + 40, y + 10);
        path.lineTo(x + 32.5, y + 12.5);
        path.lineTo(x + 30, y + 20);
        path.lineTo(x + 27.5, y + 12.5);
        path.lineTo(x + 20, y + 10);
        path.lineTo(x + 27.5, y + 7.5);
        path.close();

        // 2nd star
        path.moveTo(x + 30, y + 40);
        path.lineTo(x + 32.5, y + 47.5);
        path.lineTo(x + 40, y + 50);
        path.lineTo(x + 32.5, y + 52.5);
        path.lineTo(x + 30, y + 60);
        path.lineTo(x + 27.5, y + 52.5);
        path.lineTo(x + 20, y + 50);
        path.lineTo(x + 27.5, y + 47.5);
        path.close();

        // 3rd star
        path.moveTo(x + 10, y + 20);
        path.lineTo(x + 12.5, y + 27.5);
        path.lineTo(x + 20, y + 30);
        path.lineTo(x + 12.5, y + 32.5);
        path.lineTo(x + 10, y + 40);
        path.lineTo(x + 7.5, y + 32.5);
        path.lineTo(x + 0, y + 30);
        path.lineTo(x + 7.5, y + 27.5);
        path.close();

        // 4th star
        path.moveTo(x + 50, y + 20);
        path.lineTo(x + 52.5, y + 27.5);
        path.lineTo(x + 60, y + 30);
        path.lineTo(x + 52.5, y + 32.5);
        path.lineTo(x + 50, y + 40);
        path.lineTo(x + 47.5, y + 32.5);
        path.lineTo(x + 40, y + 30);
        path.lineTo(x + 47.5, y + 27.5);
        path.close();

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}