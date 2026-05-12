import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/pengumuman_model.dart';
import 'package:mobile_miftahul_ulumv2/models/santri.dart';
import 'package:mobile_miftahul_ulumv2/models/kehadiran_data.dart';
import 'package:mobile_miftahul_ulumv2/models/perizinan.dart';
import 'package:mobile_miftahul_ulumv2/screens/form_izin_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/jadwal_shalat_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/chat_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/more_menu_screen.dart';
import 'package:mobile_miftahul_ulumv2/screens/santri_detail_screen.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:mobile_miftahul_ulumv2/services/reverb_service.dart';
import 'package:mobile_miftahul_ulumv2/services/santri_api_service.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeContent(onGoToChat: () => setState(() => _currentIndex = 2)),
      const JadwalShalatScreen(),
      const ChatScreen(),
      const MoreMenuScreen(),
    ];
    _initReverb();
  }

  /// Inisialisasi koneksi WebSocket Reverb (sekali saja, sepanjang sesi).
  Future<void> _initReverb() async {
    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getString('parentId') ?? '';
    final token = prefs.getString('authToken') ?? 'dummy-token-$parentId';
    if (parentId.isEmpty) return;
    ReverbService().connect(authToken: token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      extendBody: true, // Allow content behind the bottom nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.only(bottom: 24, top: 12, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9), // bg-white/90
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF191C1B).withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                  spreadRadius: -4,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, 'home', 'Beranda'),
                _buildNavItem(1, 'auto_stories', 'Jadwal'),
                _buildNavItem(2, 'chat_bubble', 'Pesan'),
                _buildNavItem(3, 'more_horiz', 'Lainnya'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconName, String label) {
    final isActive = _currentIndex == index;
    // Map string to Material Icons
    IconData icon;
    switch (iconName) {
      case 'home': icon = Icons.home; break;
      case 'auto_stories': icon = Icons.menu_book; break; 
      case 'chat_bubble': icon = Icons.chat_bubble; break;
      case 'more_horiz': icon = Icons.more_horiz; break;
      default: icon = Icons.home;
    }

    return AnimatedPressButton(
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primary : AppTheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppTheme.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5, // tracking-widest
                color: isActive ? AppTheme.primary : AppTheme.onSurface.withValues(alpha: 0.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final VoidCallback? onGoToChat;
  const _HomeContent({this.onGoToChat});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  // Data dari API — nullable, null = belum dimuat
  List<Santri>? _santriList;
  KehadiranData? _kehadiranData;
  List<Perizinan>? _perizinanList;
  String? _santriNama;
  bool _isLoadingSantri = true;

  // Pengumuman (state lokal agar bisa real-time push)
  List<PengumumanModel> _pengumumanList = [];
  bool _isLoadingPengumuman = true;
  StreamSubscription<ReverbEvent>? _reverbSub;

  // Variabel Dinamis untuk UI
  String _namaOrtu = 'Bapak/Ibu'; // Default, akan dioverride dari API
  late String _tanggalHariIni;

  // ID orang tua — diambil dari SharedPreferences setelah login
  String _idOrtu = '1';
  String? _selectedSantriId;

  @override
  void initState() {
    super.initState();
    _initDate();
    _loadSantriData();
    _loadPengumuman();
    _setupReverbListener();
  }

  @override
  void dispose() {
    _reverbSub?.cancel();
    ReverbService().unsubscribe('pengumuman');
    super.dispose();
  }

  /// Load pengumuman dari API + state list (bukan FutureBuilder
  /// agar bisa di-prepend secara real-time).
  /// Tidak perlu filter isActive — backend sudah filter is_published=true.
  Future<void> _loadPengumuman() async {
    try {
      final list = await ApiService().getPengumuman();
      if (!mounted) return;
      setState(() {
        _pengumumanList = list;
        _isLoadingPengumuman = false;
      });
    } catch (e) {
      debugPrint('Pengumuman load error: $e');
      if (mounted) setState(() => _isLoadingPengumuman = false);
    }
  }

  /// Subscribe ke channel `pengumuman` & listen event AnnouncementCreated
  void _setupReverbListener() {
    ReverbService().subscribe('pengumuman');
    _reverbSub = ReverbService().events.listen((evt) {
      if (evt.channel == 'pengumuman' && evt.event == 'AnnouncementCreated') {
        try {
          final newPengumuman = PengumumanModel.fromJson(evt.data);
          if (!mounted) return;
          // Hindari duplikat
          if (_pengumumanList.any((p) => p.id == newPengumuman.id)) return;
          setState(() {
            _pengumumanList = [newPengumuman, ..._pengumumanList];
          });
          // Toast singkat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📢 Pengumuman baru: ${newPengumuman.judul}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        } catch (e) {
          debugPrint('Pengumuman parse error: $e');
        }
      }
    });
  }

  // Fungsi untuk men-generate tanggal hari ini secara dinamis
  void _initDate() {
    final now = DateTime.now();
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    _tanggalHariIni = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _loadSantriData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idAkun = prefs.getString('id_akun');
      if (idAkun != null && idAkun.isNotEmpty) {
        _idOrtu = idAkun;
      }

      // 1. Ambil Nama Orang Tua secara dinamis dari ApiService yang baru
      final ortuResponse = await ApiService().getSantriByOrtu(_idOrtu);
      if (ortuResponse['success'] == true && ortuResponse['data'] != null) {
        final List dataList = ortuResponse['data'];
        if (dataList.isNotEmpty && dataList[0]['ortu'] != null) {
          if (mounted) {
            setState(() {
              _namaOrtu = dataList[0]['ortu']['nama_lengkap'] ?? _namaOrtu;
            });
          }
        }
      }

      // 2. Load data santri menggunakan service yang sudah ada
      final santriResponse = await SantriApiService.getSantriByOrtuIdFromMobile(_idOrtu);

      if (santriResponse.success && santriResponse.data != null && santriResponse.data!.isNotEmpty) {
        final santriList = santriResponse.data!;
        final firstSantri = santriList.first;

        if (mounted) {
          setState(() {
            _santriList = santriList;
            _selectedSantriId = firstSantri.idSantri.toString();
            _santriNama = firstSantri.nama;
          });
        }

        // Load kehadiran dan perizinan untuk santri pertama
        await _loadSantriDetail(firstSantri.idSantri.toString());
      } else {
        if (mounted) setState(() => _isLoadingSantri = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSantri = false);
    }
  }

  Future<void> _loadSantriDetail(String santriId) async {
    setState(() => _isLoadingSantri = true);
    try {
      final results = await Future.wait([
        SantriApiService.getKehadiranByTime(santriId),
        SantriApiService.getPerizinanSetahun(santriId),
      ]);

      final kehadiranResp = results[0] as ApiResponse<KehadiranData>;
      final perizinanResp = results[1] as ApiResponse<List<Perizinan>>;

      if (mounted) {
        setState(() {
          _kehadiranData = kehadiranResp.success ? kehadiranResp.data : null;
          _perizinanList = perizinanResp.success ? perizinanResp.data : null;
          _isLoadingSantri = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSantri = false);
    }
  }

  void _showSantriPicker() {
    if (_santriList == null || _santriList!.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pilih Anak', style: AppTheme.headline.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.outline),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ..._santriList!.map((santri) {
                final isSelected = santri.idSantri.toString() == _selectedSantriId;
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) {
                      setState(() {
                        _selectedSantriId = santri.idSantri.toString();
                        _santriNama = santri.nama;
                      });
                      _loadSantriDetail(santri.idSantri.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryContainer.withValues(alpha: 0.15) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              santri.nama.isNotEmpty ? santri.nama[0].toUpperCase() : '?',
                              style: AppTheme.headline.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                              ),
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
                                style: AppTheme.headline.copyWith(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                                ),
                              ),
                              if (santri.kelas != null || santri.kamar != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    [if (santri.kelas != null) santri.kelas!, if (santri.kamar != null) santri.kamar!].join(' • '),
                                    style: AppTheme.label.copyWith(fontSize: 12, color: AppTheme.outline),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppTheme.primary)
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // TopAppBar (Sticky & Glassmorphic)
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryContainer, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
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
              icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
              style: IconButton.styleFrom(
                hoverColor: AppTheme.surfaceContainerLow,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        
        // Main Content
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              
              // Welcome Hero with Integrated Child Switcher
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AHLAN WA SAHLAN',
                          style: AppTheme.label.copyWith(
                            fontSize: 14,
                            letterSpacing: 2.8,
                            color: AppTheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Assalamu'alaikum,\n$_namaOrtu", // Menggunakan variabel dinamis nama ortu
                          style: AppTheme.headline.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: AppTheme.onPrimary.withValues(alpha: 0.9)),
                            const SizedBox(width: 8),
                            Text(
                              _tanggalHariIni, // Menggunakan variabel dinamis tanggal
                              style: AppTheme.body.copyWith(
                                fontSize: 14,
                                color: AppTheme.onPrimary.withValues(alpha: 0.9),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ===== CHILD SWITCHER BUTTON =====
                        GestureDetector(
                          onTap: () => _showSantriPicker(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.onPrimary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.onPrimary.withValues(alpha: 0.25), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.onPrimary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _santriNama != null && _santriNama!.isNotEmpty
                                          ? _santriNama![0].toUpperCase()
                                          : '?',
                                      style: AppTheme.headline.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _santriNama ?? 'Pilih Anak',
                                        style: AppTheme.headline.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.onPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_selectedSantriId != null && _santriList != null)
                                        Builder(builder: (_) {
                                          final santri = _santriList!.firstWhere(
                                            (s) => s.idSantri.toString() == _selectedSantriId,
                                            orElse: () => _santriList!.first,
                                          );
                                          final info = [
                                            if (santri.kelas != null) santri.kelas!,
                                            if (santri.kamar != null) santri.kamar!,
                                          ].join(' • ');
                                          return info.isNotEmpty
                                              ? Text(
                                                  info,
                                                  style: AppTheme.label.copyWith(
                                                    fontSize: 11,
                                                    color: AppTheme.onPrimary.withValues(alpha: 0.7),
                                                  ),
                                                )
                                              : const SizedBox.shrink();
                                        }),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_santriList != null && _santriList!.length > 1)
                                  Icon(Icons.swap_horiz, size: 18, color: AppTheme.onPrimary.withValues(alpha: 0.8))
                                else
                                  Icon(Icons.person, size: 16, color: AppTheme.onPrimary.withValues(alpha: 0.6)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Decorative Pattern
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.change_history, size: 120, color: AppTheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bento Summary Grid
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: _isLoadingSantri
                        ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                        : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.menu_book, color: AppTheme.primary),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('IBADAH', style: AppTheme.label.copyWith(fontSize: 12, letterSpacing: 1.2, color: AppTheme.onSurfaceVariant)),
                              Text(
                                _kehadiranData != null
                                    ? '${_kehadiranData!.seminggu.persentase.toStringAsFixed(0)}%'
                                    : '95%',
                                style: AppTheme.headline.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                              Text(
                                _kehadiranData != null
                                    ? (_kehadiranData!.seminggu.persentase >= 90 ? 'Sangat Baik' : _kehadiranData!.seminggu.persentase >= 70 ? 'Baik' : 'Perlu Perhatian')
                                    : 'Sangat Baik',
                                style: AppTheme.body.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.outline),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 160,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _isLoadingSantri
                        ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                        : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.verified_user_outlined, color: AppTheme.secondary),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DISIPLIN', style: AppTheme.label.copyWith(fontSize: 12, letterSpacing: 1.2, color: AppTheme.onSurfaceVariant)),
                              Text(
                                _perizinanList != null
                                    ? (_perizinanList!.any((p) => p.isActive) ? 'Izin Aktif' : 'Aktif')
                                    : 'Aktif',
                                style: AppTheme.headline.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                              ),
                              Text(
                                _perizinanList != null
                                    ? '${_perizinanList!.where((p) => p.status.toLowerCase() == 'disetujui').length} izin disetujui'
                                    : 'Tanpa Pelanggaran',
                                style: AppTheme.body.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.secondary),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedPressButton(
                onPressed: () {
                  if (_selectedSantriId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SantriDetailScreen(santriId: _selectedSantriId!),
                      ),
                    );
                  }
                },
                child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.workspace_premium, color: AppTheme.tertiary),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('KEHADIRAN BULAN INI', style: AppTheme.label.copyWith(fontSize: 12, letterSpacing: 1.2, color: AppTheme.onSurfaceVariant)),
                            Text(
                              _kehadiranData != null
                                  ? '${_kehadiranData!.sebulan.totalHadir}/${_kehadiranData!.sebulan.totalShalat} shalat'
                                  : 'Lihat Detail',
                              style: AppTheme.headline.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.outline),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 32),

              // Quick Actions Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildActionButton('Ajukan izin', Icons.add_circle, true, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FormIzinScreen()));
                    }),
                    const SizedBox(width: 12),
                    _buildActionButton('Lihat laporan', Icons.analytics, false, () {
                      if (_selectedSantriId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SantriDetailScreen(santriId: _selectedSantriId!),
                          ),
                        );
                      }
                    }),
                    const SizedBox(width: 12),
                    _buildActionButton('Chat admin', Icons.chat_bubble_outline, false, () {
                      widget.onGoToChat?.call();
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Pengumuman
              Text('Pengumuman', style: AppTheme.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  if (_isLoadingPengumuman) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.tertiaryFixed,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (_pengumumanList.isEmpty) {
                    return Container(
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
                              'Tidak ada pengumuman aktif saat ini.',
                              style: AppTheme.body.copyWith(color: AppTheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: _pengumumanList.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppTheme.tertiaryFixed,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.foto != null && item.foto!.isNotEmpty)
                                Container(
                                  height: 140,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(item.fotoUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 32, height: 32,
                                              decoration: BoxDecoration(
                                                color: AppTheme.onTertiaryFixedVariant.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(item.icon, size: 16, color: AppTheme.onTertiaryFixedVariant),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              item.kategori.toUpperCase(),
                                              style: AppTheme.label.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2,
                                                color: AppTheme.onTertiaryFixedVariant.withValues(alpha: 0.6),
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: item.prioritas == 'tinggi'
                                                    ? AppTheme.error.withValues(alpha: 0.15)
                                                    : AppTheme.secondary.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                item.prioritas.toUpperCase(),
                                                style: AppTheme.label.copyWith(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8,
                                                  color: item.prioritas == 'tinggi' ? AppTheme.error : AppTheme.secondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          item.judul,
                                          style: AppTheme.headline.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.onTertiaryFixedVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.isi.length > 120 ? '${item.isi.substring(0, 120)}...' : item.isi,
                                          style: AppTheme.body.copyWith(
                                            fontSize: 13,
                                            height: 1.5,
                                            color: AppTheme.onTertiaryFixedVariant.withValues(alpha: 0.75),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 13, color: AppTheme.onTertiaryFixedVariant.withValues(alpha: 0.5)),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.timeAgo,
                                              style: AppTheme.label.copyWith(
                                                fontSize: 11,
                                                color: AppTheme.onTertiaryFixedVariant.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      bottom: -24,
                                      right: -24,
                                      child: Icon(item.icon, size: 80, color: AppTheme.onTertiaryFixedVariant.withValues(alpha: 0.06)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Status Perizinan
              Text('Status Perizinan', style: AppTheme.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_perizinanList != null && _perizinanList!.isNotEmpty)
                ...(_perizinanList!.take(3).map((izin) {
                  Color badgeColor;
                  Color badgeBg;
                  switch (izin.status.toLowerCase()) {
                    case 'disetujui':
                      badgeColor = AppTheme.secondary;
                      badgeBg = AppTheme.secondaryContainer;
                      break;
                    case 'ditolak':
                      badgeColor = AppTheme.error;
                      badgeBg = AppTheme.errorContainer;
                      break;
                    default:
                      badgeColor = AppTheme.outline;
                      badgeBg = AppTheme.surfaceContainerHighest;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: const BoxDecoration(
                              color: AppTheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.history_edu, color: AppTheme.outline),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(izin.statusLabel, style: AppTheme.label.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${izin.tglMulai} - ${izin.tglSelesai}', style: AppTheme.body.copyWith(fontSize: 12, color: AppTheme.outline)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList())
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history_edu, color: AppTheme.outline),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Izin Sakit', style: AppTheme.headline.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text('DISETUJUI', style: AppTheme.label.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Berlaku sampai 26 Okt', style: AppTheme.body.copyWith(fontSize: 12, color: AppTheme.outline)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, bool isPrimary, VoidCallback onTap) {
    return AnimatedPressButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primary : AppTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPrimary ? [
            BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 10))
          ] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isPrimary ? AppTheme.onPrimary : AppTheme.onSurface),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTheme.headline.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPrimary ? AppTheme.onPrimary : AppTheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}