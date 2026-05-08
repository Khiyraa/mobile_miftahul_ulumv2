import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/screens/faq_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/form_izin_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/santri_detail_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/riwayat_perizinan_screen.dart';
import 'package:mobile_miftahul_ulumv2/models/santri.dart';
import 'package:mobile_miftahul_ulumv2/models/perizinan.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';
import 'package:mobile_miftahul_ulumv2/services/santri_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreMenuScreen extends StatefulWidget {
  const MoreMenuScreen({super.key});

  @override
  State<MoreMenuScreen> createState() => _MoreMenuScreenState();
}

class _MoreMenuScreenState extends State<MoreMenuScreen> {
  List<Santri>? _santriList;
  List<Perizinan> _recentPerizinan = [];
  bool _isLoadingSantri = true;
  bool _isLoadingPerizinan = true;

  @override
  void initState() {
    super.initState();
    _loadSantriForQuickAccess();
  }

  Future<void> _loadSantriForQuickAccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idAkun = prefs.getString('id_akun') ?? '1';
      final response = await SantriApiService.getSantriByOrtuIdFromMobile(idAkun);
      if (mounted) {
        setState(() {
          _santriList = (response.success && response.data != null) ? response.data : null;
          _isLoadingSantri = false;
        });
        _loadRecentPerizinan();
      }
    } catch (_) {
      if (mounted) setState(() {
        _isLoadingSantri = false;
        _isLoadingPerizinan = false;
      });
    }
  }

  Future<void> _loadRecentPerizinan() async {
    if (_santriList == null || _santriList!.isEmpty) {
      if (mounted) setState(() => _isLoadingPerizinan = false);
      return;
    }
    List<Perizinan> allPerizinan = [];
    try {
      for (var santri in _santriList!) {
        final resp = await SantriApiService.getPerizinanSetahun(santri.idSantri.toString(), useCache: false);
        if (resp.success && resp.data != null) {
          allPerizinan.addAll(resp.data!);
        }
      }
      // Sort by id descending as rough proxy for latest
      allPerizinan.sort((a, b) => b.idPerizinan.compareTo(a.idPerizinan));
      if (mounted) {
        setState(() {
          _recentPerizinan = allPerizinan.take(3).toList();
          _isLoadingPerizinan = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPerizinan = false);
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
            title: Text(
              'Miftahul Ulum Kalisat',
              style: AppTheme.headline.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -1,
                color: AppTheme.primary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title
                Text(
                  'Menu Lainnya',
                  style: AppTheme.headline.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Akses semua fitur monitoring santri Pondok Pesantren Miftahul Ulum Kalisat.',
                  style: AppTheme.body.copyWith(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ========== QUICK ACCESS: Anak Santri ==========
                Text(
                  'Anak Saya',
                  style: AppTheme.headline.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (_isLoadingSantri)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  )
                else if (_santriList != null && _santriList!.isNotEmpty)
                  ..._santriList!.map((santri) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedPressButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => SantriDetailScreen(santriId: santri.idSantri.toString()),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  santri.nama.isNotEmpty ? santri.nama[0].toUpperCase() : '?',
                                  style: AppTheme.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    santri.nama,
                                    style: AppTheme.headline.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'NIS: ${santri.nis}${santri.kelas != null ? ' • ${santri.kelas}' : ''}',
                                    style: AppTheme.label.copyWith(fontSize: 12, color: AppTheme.outline),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'LIHAT DETAIL',
                                style: AppTheme.label.copyWith(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.primary),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, color: AppTheme.outline, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ))
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.outline, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Data santri belum tersedia. Hubungkan ke server backend.',
                            style: AppTheme.body.copyWith(fontSize: 13, color: AppTheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // ========== MENU GRID ==========
                Text(
                  'Fitur',
                  style: AppTheme.headline.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Grid menu items
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
              
                    _buildMenuCard(
                      icon: Icons.edit_note,
                      title: 'Form Izin',
                      subtitle: 'Ajukan perizinan',
                      color: AppTheme.tertiary,
                      bgColor: AppTheme.tertiary.withValues(alpha: 0.1),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormIzinScreen())),
                    ),
                    _buildMenuCard(
                      icon: Icons.help_outline,
                      title: 'FAQ',
                      subtitle: 'Bantuan & panduan',
                      color: AppTheme.secondary,
                      bgColor: AppTheme.secondaryContainer.withValues(alpha: 0.2),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
                    ),
                    _buildMenuCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'Riwayat Izin',
                      subtitle: 'Lihat status & detail',
                      color: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatPerizinanScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ========== RIWAYAT PERIZINAN TERAKHIR ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status Pengajuan Izin',
                      style: AppTheme.headline.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatPerizinanScreen())),
                      child: Text('Lihat Semua', style: AppTheme.label.copyWith(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (_isLoadingPerizinan)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  )
                else if (_recentPerizinan.isNotEmpty)
                  ..._recentPerizinan.map((izin) {
                    Color badgeColor;
                    Color badgeBg;
                    IconData badgeIcon;
                    switch (izin.status.toLowerCase()) {
                      case 'disetujui':
                        badgeColor = AppTheme.secondary;
                        badgeBg = AppTheme.secondaryContainer;
                        badgeIcon = Icons.check_circle;
                        break;
                      case 'ditolak':
                        badgeColor = AppTheme.error;
                        badgeBg = AppTheme.errorContainer;
                        badgeIcon = Icons.cancel;
                        break;
                      default:
                        badgeColor = AppTheme.outline;
                        badgeBg = AppTheme.surfaceContainerHighest;
                        badgeIcon = Icons.schedule;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatPerizinanScreen())),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.shadowSm,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                              child: Icon(badgeIcon, color: badgeColor, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Izin ${izin.jenisIzin}',
                                          style: AppTheme.headline.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                                        child: Text(
                                          izin.statusLabel,
                                          style: AppTheme.label.copyWith(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    izin.alasan,
                                    style: AppTheme.body.copyWith(fontSize: 11, color: AppTheme.onSurfaceVariant),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (izin.status.toLowerCase() == 'ditolak' && izin.catatan != null && izin.catatan!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorContainer.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Alasan Penolakan: ${izin.catatan}',
                                          style: AppTheme.label.copyWith(fontSize: 10, color: AppTheme.error, fontStyle: FontStyle.italic),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                  })
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: AppTheme.outline, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Belum ada riwayat perizinan.',
                            style: AppTheme.body.copyWith(fontSize: 13, color: AppTheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                
                // Separate Logout Button
                AnimatedPressButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () {
                              SantriApiService.clearAllCache();
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                            },
                            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
                            child: const Text('Keluar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.errorContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: AppTheme.error, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Keluar dari Akun',
                          style: AppTheme.headline.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // App Info Footer
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.school, color: AppTheme.primary, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mobile Miftahul Ulum',
                        style: AppTheme.headline.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v1.0.0 • © 2024 Miftahul Ulum Kalisat',
                        style: AppTheme.label.copyWith(fontSize: 11, color: AppTheme.outline),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return AnimatedPressButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.headline.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.label.copyWith(
                    fontSize: 11,
                    color: AppTheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
