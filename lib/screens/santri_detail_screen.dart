import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/santri.dart';
import 'package:mobile_miftahul_ulumv2/models/kehadiran_mingguan.dart';
import 'package:mobile_miftahul_ulumv2/models/kehadiran_data.dart';
import 'package:mobile_miftahul_ulumv2/models/perizinan.dart';
import 'package:mobile_miftahul_ulumv2/services/reverb_service.dart';
import 'package:mobile_miftahul_ulumv2/services/santri_api_service.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';

class SantriDetailScreen extends StatefulWidget {
  final String santriId;
  const SantriDetailScreen({super.key, required this.santriId});

  @override
  State<SantriDetailScreen> createState() => _SantriDetailScreenState();
}

class _SantriDetailScreenState extends State<SantriDetailScreen> with SingleTickerProviderStateMixin {
  Santri? _santri;
  List<KehadiranMingguan>? _kehadiranMingguan;
  KehadiranData? _kehadiranData;
  List<Perizinan>? _perizinanList;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  // Periode kehadiran yang dipilih: 0=seminggu, 1=sebulan, 2=setahun
  int _selectedPeriode = 0;

  // Realtime listener
  StreamSubscription<ReverbEvent>? _reverbSub;
  String get _channelName => 'private-santri.${widget.santriId}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
    _setupReverbListener();
  }

  @override
  void dispose() {
    _reverbSub?.cancel();
    ReverbService().unsubscribe(_channelName);
    _tabController.dispose();
    super.dispose();
  }

  /// Subscribe ke channel privat santri & listen perubahan status izin.
  /// Setiap kali admin approve/reject di web, mobile akan update otomatis.
  void _setupReverbListener() {
    ReverbService().subscribe(_channelName);
    _reverbSub = ReverbService().events.listen((evt) {
      if (evt.channel != _channelName) return;
      if (evt.event != 'PermissionStatusUpdated') return;

      try {
        final updated = Perizinan.fromJson(evt.data);
        if (!mounted) return;

        setState(() {
          final list = List<Perizinan>.from(_perizinanList ?? const []);
          final idx = list.indexWhere((p) => p.idPerizinan == updated.idPerizinan);
          if (idx >= 0) {
            list[idx] = updated;
          } else {
            list.insert(0, updated);
          }
          _perizinanList = list;
        });

        // Toast info
        final statusLabel = updated.statusLabel; // DISETUJUI / DITOLAK / MENUNGGU
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin ${updated.jenisIzin} → $statusLabel'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        debugPrint('PermissionStatusUpdated parse error: $e');
      }
    });
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        SantriApiService.getSantriById(widget.santriId),
        SantriApiService.getKehadiranMingguan(widget.santriId),
        SantriApiService.getKehadiranByTime(widget.santriId),
        SantriApiService.getPerizinanSetahun(widget.santriId),
      ]);

      final santriResp = results[0] as ApiResponse<Santri>;
      final kehadiranMingguanResp = results[1] as ApiResponse<List<KehadiranMingguan>>;
      final kehadiranDataResp = results[2] as ApiResponse<KehadiranData>;
      final perizinanResp = results[3] as ApiResponse<List<Perizinan>>;

      if (mounted) {
        setState(() {
          _santri = santriResp.success ? santriResp.data : null;
          _kehadiranMingguan = kehadiranMingguanResp.success ? kehadiranMingguanResp.data : null;
          _kehadiranData = kehadiranDataResp.success ? kehadiranDataResp.data : null;
          _perizinanList = perizinanResp.success ? perizinanResp.data : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await SantriApiService.refreshSantriData(widget.santriId);
    await _loadAllData();
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
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.primary,
            child: CustomScrollView(
              slivers: [
                // App Bar
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
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  title: Text(
                    'Detail Santri',
                    style: AppTheme.headline.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -1,
                      color: AppTheme.primary,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppTheme.primary),
                      onPressed: _onRefresh,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Content
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                          const SizedBox(height: 16),
                          Text('Gagal memuat data', style: AppTheme.headline.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_error!, style: AppTheme.body.copyWith(color: AppTheme.outline, fontSize: 12)),
                          const SizedBox(height: 24),
                          AnimatedPressButton(
                            onPressed: _loadAllData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Coba Lagi', style: AppTheme.headline.copyWith(color: AppTheme.onPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ===== PROFIL SANTRI =====
                        _buildProfilCard(),
                        const SizedBox(height: 24),

                        // ===== STATISTIK KEHADIRAN =====
                        _buildKehadiranStats(),
                        const SizedBox(height: 24),

                        // ===== KEHADIRAN MINGGUAN =====
                        _buildKehadiranMingguan(),
                        const SizedBox(height: 24),

                        // ===== RIWAYAT PERIZINAN =====
                        _buildRiwayatPerizinan(),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROFIL CARD ====================
  Widget _buildProfilCard() {
    final santri = _santri;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -30,
            right: -30,
            child: Icon(Icons.person, size: 120, color: AppTheme.onPrimary.withValues(alpha: 0.06)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.onPrimary.withValues(alpha: 0.3), width: 3),
                      color: AppTheme.onPrimary.withValues(alpha: 0.15),
                    ),
                    child: santri?.foto != null && santri!.foto!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Image.network(santri.fotoUrl, fit: BoxFit.cover, width: 72, height: 72,
                              errorBuilder: (_, e, s) => const Icon(Icons.person, size: 36, color: AppTheme.onPrimary),
                            ),
                          )
                        : const Icon(Icons.person, size: 36, color: AppTheme.onPrimary),
                  ),
                  const SizedBox(width: 20),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          santri?.nama ?? 'Nama Santri',
                          style: AppTheme.headline.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NIS: ${santri?.nis ?? '-'}',
                          style: AppTheme.body.copyWith(
                            fontSize: 13,
                            color: AppTheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Detail Info Row
              Row(
                children: [
                  _buildProfilChip(Icons.class_, santri?.kelas ?? '-'),
                  const SizedBox(width: 12),
                  _buildProfilChip(Icons.meeting_room, santri?.kamar ?? '-'),
                  const SizedBox(width: 12),
                  _buildProfilChip(
                    santri?.status?.toLowerCase() == 'aktif' ? Icons.check_circle : Icons.pause_circle,
                    santri?.status ?? 'Aktif',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.onPrimary.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.label.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== KEHADIRAN STATISTICS ====================
  Widget _buildKehadiranStats() {
    final data = _kehadiranData;
    final labels = ['Minggu Ini', 'Bulan Ini', 'Tahun Ini'];
    final periodes = data != null ? [data.seminggu, data.sebulan, data.setahun] : null;
    final selected = periodes != null ? periodes[_selectedPeriode] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistik Kehadiran', style: AppTheme.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Tab selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: List.generate(3, (i) {
              final isActive = _selectedPeriode == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriode = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.surfaceContainerLowest : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive ? AppTheme.shadowSm : null,
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: AppTheme.label.copyWith(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          color: isActive ? AppTheme.primary : AppTheme.outline,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),

        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Hadir',
                '${selected?.totalHadir ?? 0}',
                Icons.check_circle_outline,
                AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Tidak Hadir',
                '${selected?.totalTidakHadir ?? 0}',
                Icons.cancel_outlined,
                AppTheme.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Persentase',
                '${selected?.persentase.toStringAsFixed(0) ?? 0}%',
                Icons.pie_chart_outline,
                AppTheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTheme.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.label.copyWith(fontSize: 10, color: AppTheme.outline)),
        ],
      ),
    );
  }

  // ==================== KEHADIRAN MINGGUAN TABLE ====================
  Widget _buildKehadiranMingguan() {
    final data = _kehadiranMingguan;
    final waktuShalat = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kehadiran Mingguan', style: AppTheme.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        if (data == null || data.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data kehadiran mingguan belum tersedia.',
                    style: AppTheme.body.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.shadowSm,
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppTheme.surfaceContainerLow),
                columnSpacing: 20,
                horizontalMargin: 20,
                headingTextStyle: AppTheme.label.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                dataTextStyle: AppTheme.body.copyWith(fontSize: 12),
                columns: [
                  const DataColumn(label: Text('Hari')),
                  ...waktuShalat.map((w) => DataColumn(label: Text(w))),
                  const DataColumn(label: Text('Total')),
                ],
                rows: data.map((item) {
                  final statuses = [item.subuh, item.dzuhur, item.ashar, item.maghrib, item.isya];
                  return DataRow(
                    cells: [
                      DataCell(Text(item.hari, style: AppTheme.body.copyWith(fontWeight: FontWeight.w600))),
                      ...statuses.map((s) => DataCell(_buildStatusIcon(s))),
                      DataCell(
                        Text(
                          '${item.totalHadir}/5',
                          style: AppTheme.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item.persentaseHadir >= 80 ? AppTheme.primary : AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusIcon(String status) {
    if (status == 'hadir') {
      return Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: AppTheme.primary),
      );
    } else {
      return Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 14, color: AppTheme.error),
      );
    }
  }

  // ==================== RIWAYAT PERIZINAN ====================
  Widget _buildRiwayatPerizinan() {
    final data = _perizinanList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Perizinan', style: AppTheme.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        if (data == null || data.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppTheme.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Belum ada riwayat perizinan.',
                    style: AppTheme.body.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          )
        else
          ...data.map((izin) {
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
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(badgeIcon, color: badgeColor, size: 22),
                    ),
                    const SizedBox(width: 16),
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
                                  style: AppTheme.headline.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  izin.statusLabel,
                                  style: AppTheme.label.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            izin.alasan,
                            style: AppTheme.body.copyWith(fontSize: 12, color: AppTheme.onSurfaceVariant, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Show rejection reason if ditolak
                          if (izin.status.toLowerCase() == 'ditolak' && izin.catatan != null && izin.catatan!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorContainer.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline, size: 14, color: AppTheme.error),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Alasan Penolakan: ${izin.catatan}',
                                        style: AppTheme.label.copyWith(fontSize: 11, color: AppTheme.error, fontStyle: FontStyle.italic, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: AppTheme.outline.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Text(
                                '${izin.tglMulai} — ${izin.tglSelesai}',
                                style: AppTheme.label.copyWith(fontSize: 11, color: AppTheme.outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const double patternSize = 60;
    
    for (double x = 0; x < size.width; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        final path = Path();
        
        // 1st star
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
