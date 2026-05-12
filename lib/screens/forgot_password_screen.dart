import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masukkan email atau nomor telepon'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await sendResetLinkAPI(email);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Kode verifikasi telah dikirim'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushNamed(context, '/verify_code');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengirim kode'),
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
      body: SafeArea(
        child: Stack(
          children: [
            // Top Navigation
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.onSurfaceVariant),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainerLowest,
                        hoverColor: AppTheme.surfaceContainerLow,
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Miftahul Ulum Kalisat',
                      style: AppTheme.headline.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer for symmetry
                  ],
                ),
              ),
            ),
            
            // Main Content
            Padding(
              padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Hero Content
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_reset, size: 40, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Lupa Kata Sandi',
                          style: AppTheme.headline.copyWith(
                            fontSize: 28, // text-3xl
                            fontWeight: FontWeight.w800, // font-extrabold
                            letterSpacing: -0.5,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Masukkan email atau nomor telepon yang terdaftar, kami akan mengirimkan kode untuk mengatur ulang kata sandi Anda.',
                            textAlign: TextAlign.center,
                            style: AppTheme.body.copyWith(
                              fontSize: 16,
                              color: AppTheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Form Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              'EMAIL / NOMOR TELEPON',
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
                          height: 64, // h-16
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email atau Nomor Telepon',
                              hintStyle: AppTheme.body.copyWith(color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              prefixIcon: const Icon(Icons.alternate_email, color: AppTheme.onSurfaceVariant),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            ),
                            style: AppTheme.body.copyWith(color: AppTheme.onSurface),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Send Button
                        AnimatedPressButton(
                          onPressed: _isLoading ? () {} : _onSendCode,
                          child: Container(
                            height: 64, // h-16
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
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
                                : Text(
                                    'Kirim Kode Verifikasi',
                                    style: AppTheme.headline.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Assistance Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(height: 1, width: 32, color: AppTheme.outlineVariant),
                            const SizedBox(width: 8),
                            Text(
                              'OR HELP WITH',
                              style: AppTheme.label.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(height: 1, width: 32, color: AppTheme.outlineVariant),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAssistanceButton('Bantuan', Icons.support_agent),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildAssistanceButton('FAQ', Icons.help_outline),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 48),

                        // Contextual Branding Image
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.onSurface.withValues(alpha: 0.6),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              '"Seeking knowledge is an obligation upon every Muslim."',
                              style: AppTheme.body.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Footer Note
                        Text(
                          'SECURE ACCESS • MIFTAHUL ULUM KALISAT ECOSYSTEM',
                          style: AppTheme.label.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistanceButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.headline.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          )
        ],
      ),
    );
  }
}
