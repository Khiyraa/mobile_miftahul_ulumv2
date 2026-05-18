import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onVerify() async {
    final code = _otpCode;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masukkan 6 digit kode verifikasi'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email dan password baru harus diisi'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await verifyResetPasswordAPI(email, code, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Password berhasil direset'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Verifikasi gagal'),
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
      body: CustomScrollView(
        slivers: [
          // TopAppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.security, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'Miftahul Ulum Kalisat',
                  style: AppTheme.headline.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -1,
                    color: AppTheme.primary,
                  ),
                )
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: AppTheme.onSurfaceVariant),
                style: IconButton.styleFrom(
                  hoverColor: AppTheme.surfaceContainerLow,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                // Hero Illustration
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondaryFixedDim],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 128, // w-32
                        height: 128, // h-32
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.contain,
                            opacity: 0.3,
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.overlay),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.shield_rounded, // fallback for shield_person
                        size: 48, // text-5xl (roughly)
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Textual Content
                Text(
                  'Verify Your Identity',
                  textAlign: TextAlign.center,
                  style: AppTheme.headline.copyWith(
                    fontSize: 28, // text-3xl
                    fontWeight: FontWeight.w800, // font-extrabold
                    letterSpacing: -0.5,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.body.copyWith(
                      fontSize: 16,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "We've sent a 6-digit verification code to your registered email "),
                      TextSpan(
                        text: "u***@santri.edu",
                        style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                      const TextSpan(text: ". Please enter it below to secure your session."),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Input Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48, // md:w-16 on larger screens, 48 is w-12
                      height: 64, // md:h-20
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppTheme.headline.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "·",
                          hintStyle: AppTheme.headline.copyWith(color: AppTheme.outline),
                          filled: true,
                          fillColor: AppTheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Email Input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      'EMAIL',
                      style: AppTheme.label.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email yang didaftarkan',
                      hintStyle: AppTheme.body.copyWith(color: AppTheme.outline),
                      prefixIcon: const Icon(Icons.alternate_email, color: AppTheme.outline),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: AppTheme.body.copyWith(color: AppTheme.onSurface),
                  ),
                ),
                const SizedBox(height: 16),

                // New Password Input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      'PASSWORD BARU',
                      style: AppTheme.label.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Masukkan password baru',
                      hintStyle: AppTheme.body.copyWith(color: AppTheme.outline),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.outline),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: AppTheme.body.copyWith(color: AppTheme.onSurface),
                  ),
                ),
                const SizedBox(height: 48),

                // Primary Action
                AnimatedPressButton(
                  onPressed: _isLoading ? () {} : _onVerify,
                  child: Container(
                    height: 64, // py-5 approximation
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryContainer],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Verify Code',
                                style: AppTheme.headline.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: AppTheme.onPrimary),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Auxiliary Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: AppTheme.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Resend in 00:45",
                        style: AppTheme.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info, size: 14, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          "Standard message and data rates may apply.",
                          style: AppTheme.body.copyWith(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 64),

                // Content-Focused Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Privacy Policy", style: AppTheme.body.copyWith(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                    const SizedBox(width: 16),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.outlineVariant, shape: BoxShape.circle)),
                    const SizedBox(width: 16),
                    Text("Security Center", style: AppTheme.body.copyWith(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                    const SizedBox(width: 16),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.outlineVariant, shape: BoxShape.circle)),
                    const SizedBox(width: 16),
                    Text("Contact Support", style: AppTheme.body.copyWith(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "© 2024 MIFTAHUL ULUM KALISAT SANTRI ECOSYSTEM. ALL RIGHTS RESERVED.",
                    style: AppTheme.label.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
