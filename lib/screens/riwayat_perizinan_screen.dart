import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/perizinan.dart';
import 'package:mobile_miftahul_ulumv2/models/santri.dart';
import 'package:mobile_miftahul_ulumv2/services/reverb_service.dart';
import 'package:mobile_miftahul_ulumv2/services/santri_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatPerizinanScreen extends StatefulWidget {
  const RiwayatPerizinanScreen({super.key});

  @override
  State<RiwayatPerizinanScreen> createState() => _RiwayatPerizinanScreenState();
}

class _RiwayatPerizinanScreenState extends State<RiwayatPerizinanScreen>
    with SingleTickerProviderStateMixin {
  List<Perizinan> _allPerizinan = [];
  List<Santri> _santriList = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'semua';
  late TabController _tabController;

  StreamSubscription<ReverbEvent>? _reverbSub;
  final List<String> _subscribedChannels = [];

  final List<Map<String, dynamic>> _tabs = [
    {'key': 'semua', 'label': 'Semua'},
    {'key': 'pending', 'label': 'Menunggu'},
    {'key': 'disetujui', 'label': 'Disetujui'},
    {'key': 'ditolak', 'label': 'Ditolak'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _filterStatus = _tabs[_tabController.index]['key']);
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _reverbSub?.cancel();
    for (final ch in _subscribedChannels) {
      ReverbService().unsubscribe(ch);
    }
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() { _isLoading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final idAkun = prefs.getString('id_akun') ?? '1';

      print('DEBUG RIWAYAT: idAkun = $idAkun');

      final santriResp = await SantriApiService.getSantriByOrtuIdFromMobile(idAkun, useCache: false);
      if (!santriResp.success || santriResp.data == null || santriResp.data!.isEmpty) {
        print('DEBUG RIWAYAT: santriResp failed or empty');
        if (mounted) setState(() { _isLoading = false; _error = 'Tidak ada data santri ditemukan.'; });
        return;
      }
      _santriList = santriResp.data!;
      print('DEBUG RIWAYAT: _santriList length = ${_santriList.length}');
      _setupReverbListeners();

      List<Perizinan> all = [];
      for (var santri in _santriList) {
        print('DEBUG RIWAYAT: Fetching perizinan for idSantri = ${santri.idSantri}');
        final resp = await SantriApiService.getPerizinanSetahun(santri.idSantri.toString(), useCache: false);
        print('DEBUG RIWAYAT: resp.success = ${resp.success}, msg = ${resp.message}');
        if (resp.success && resp.data != null) {
          all.addAll(resp.data!);
        }
      }
      // Sort newest first
      all.sort((a, b) => b.idPerizinan.compareTo(a.idPerizinan));

      print('DEBUG RIWAYAT: all length = ${all.length}');
      if (mounted) setState(() { _allPerizinan = all; _isLoading = false; });
    } catch (e) {
      print('DEBUG RIWAYAT: error = $e');
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  void _setupReverbListeners() {
    // Bersihkan subscription & channel lama sebelum re-subscribe
    _reverbSub?.cancel();
    for (final ch in _subscribedChannels) {
      ReverbService().unsubscribe(ch);
    }
    _subscribedChannels.clear();

    // Subscribe ke private-santri.{id} untuk setiap anak dari wali ini
    for (final santri in _santriList) {
      final channel = 'private-santri.${santri.idSantri}';
      ReverbService().subscribe(channel);
      _subscribedChannels.add(channel);
    }

    _reverbSub = ReverbService().events.listen((evt) {
      if (!_subscribedChannels.contains(evt.channel)) return;
      if (evt.event != 'PermissionStatusUpdated') return;
      if (!mounted) return;

      try {
        final updated = Perizinan.fromJson(evt.data);
        setState(() {
          final idx = _allPerizinan.indexWhere((p) => p.idPerizinan == updated.idPerizinan);
          if (idx >= 0) {
            _allPerizinan[idx] = updated;
          } else {
            _allPerizinan.insert(0, updated);
          }
        });

        Color snackColor;
        switch (updated.status.toLowerCase()) {
          case 'disetujui':
            snackColor = const Color(0xFF0D9488);
            break;
          case 'ditolak':
            snackColor = AppTheme.error;
            break;
          default:
            snackColor = AppTheme.outline;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status izin ${updated.jenisIzin}: ${updated.statusLabel}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: snackColor,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        debugPrint('PermissionStatusUpdated parse error (riwayat): $e');
      }
    });
  }

  List<Perizinan> get _filtered {
    if (_filterStatus == 'semua') return _allPerizinan;
    return _allPerizinan.where((p) => p.status.toLowerCase() == _filterStatus).toList();
  }

  String _getNamaSantri(Perizinan izin) {
    try {
      final s = _santriList.firstWhere((s) => s.idSantri == izin.idSantri);
      return s.nama;
    } catch (_) {
      return 'Santri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
              'Riwayat Perizinan',
              style: AppTheme.headline.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
                color: AppTheme.primary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primary),
                onPressed: _loadData,
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.outline,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 2.5,
              labelStyle: AppTheme.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTheme.label.copyWith(fontSize: 13),
              tabs: _tabs.map((t) {
                final count = t['key'] == 'semua'
                    ? _allPerizinan.length
                    : _allPerizinan.where((p) => p.status.toLowerCase() == t['key']).length;
                return Tab(text: '${t['label']} ($count)');
              }).toList(),
            ),
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                          const SizedBox(height: 16),
                          Text('Gagal memuat data', style: AppTheme.headline.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_error!, style: AppTheme.body.copyWith(color: AppTheme.outline, fontSize: 12), textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppTheme.primary,
                    child: _filtered.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.assignment_outlined, size: 64, color: AppTheme.outline.withValues(alpha: 0.4)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada riwayat pengajuan izin',
                                      style: AppTheme.headline.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pengajuan izin akan muncul di sini setelah santri mengajukan izin.',
                                      style: AppTheme.body.copyWith(fontSize: 13, color: AppTheme.outline),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final izin = _filtered[index];
                              return _buildPerizinanCard(izin);
                            },
                          ),
                  ),
      ),
    );
  }

  Widget _buildPerizinanCard(Perizinan izin) {
    Color badgeColor;
    Color badgeBg;
    IconData badgeIcon;
    Color borderColor;

    switch (izin.status.toLowerCase()) {
      case 'disetujui':
        badgeColor = const Color(0xFF0D9488); // teal
        badgeBg = const Color(0xFF0D9488).withValues(alpha: 0.1);
        badgeIcon = Icons.check_circle_rounded;
        borderColor = const Color(0xFF0D9488).withValues(alpha: 0.3);
        break;
      case 'ditolak':
        badgeColor = AppTheme.error;
        badgeBg = AppTheme.errorContainer.withValues(alpha: 0.2);
        badgeIcon = Icons.cancel_rounded;
        borderColor = AppTheme.error.withValues(alpha: 0.3);
        break;
      default: // pending
        badgeColor = const Color(0xFFF59E0B); // amber
        badgeBg = const Color(0xFFF59E0B).withValues(alpha: 0.1);
        badgeIcon = Icons.schedule_rounded;
        borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.3);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(14)),
                    child: Icon(badgeIcon, color: badgeColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Izin ${izin.jenisIzin[0].toUpperCase()}${izin.jenisIzin.substring(1)}',
                          style: AppTheme.headline.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getNamaSantri(izin),
                          style: AppTheme.label.copyWith(fontSize: 12, color: AppTheme.outline),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      izin.statusLabel,
                      style: AppTheme.label.copyWith(fontSize: 11, fontWeight: FontWeight.w800, color: badgeColor, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Info Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'Tanggal Mulai',
                      value: _formatTanggal(izin.tglMulai),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.event_available_outlined,
                      label: 'Tanggal Selesai',
                      value: _formatTanggal(izin.tglSelesai),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Keterangan / Alasan Izin
              _buildInfoItem(
                icon: Icons.description_outlined,
                label: 'Keterangan',
                value: izin.alasan.isNotEmpty ? izin.alasan : '-',
                fullWidth: true,
              ),

              // Catatan Penolakan (only for ditolak)
              if (izin.status.toLowerCase() == 'ditolak') ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppTheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alasan Penolakan',
                              style: AppTheme.label.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.error),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (izin.catatan != null && izin.catatan!.isNotEmpty) ? izin.catatan! : 'Tidak ada keterangan dari admin.',
                              style: AppTheme.body.copyWith(fontSize: 12, color: AppTheme.error.withValues(alpha: 0.8), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Approved By (for disetujui)
              if (izin.status.toLowerCase() == 'disetujui' && izin.approvedBy != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF0D9488)),
                      const SizedBox(width: 8),
                      Text(
                        'Disetujui oleh: ${izin.approvedBy}',
                        style: AppTheme.label.copyWith(fontSize: 12, color: const Color(0xFF0D9488), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.outline),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.label.copyWith(fontSize: 10, color: AppTheme.outline, letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(value, style: AppTheme.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTanggal(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
