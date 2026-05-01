import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/santri.dart';
import 'package:mobile_miftahul_ulumv2/services/santri_api_service.dart';
import 'package:mobile_miftahul_ulumv2/screens/santri_detail_screen.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';

class DaftarSantriScreen extends StatefulWidget {
  const DaftarSantriScreen({super.key});

  @override
  State<DaftarSantriScreen> createState() => _DaftarSantriScreenState();
}

class _DaftarSantriScreenState extends State<DaftarSantriScreen> {
  List<Santri>? _santriList;
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSantri();
  }

  Future<void> _loadSantri() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await SantriApiService.getAllSantri();
      if (mounted) {
        setState(() {
          _santriList = response.success ? response.data : null;
          _isLoading = false;
          if (!response.success) {
            _error = response.message;
          }
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

  List<Santri> get _filteredSantri {
    if (_santriList == null) return [];
    if (_searchQuery.isEmpty) return _santriList!;
    return _santriList!.where((s) =>
      s.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      s.nis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (s.kelas?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadSantri,
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
                'Daftar Santri',
                style: AppTheme.headline.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -1,
                  color: AppTheme.primary,
                ),
              ),
              centerTitle: true,
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  Text(
                    'Santri Miftahul Ulum',
                    style: AppTheme.headline.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lihat informasi lengkap, kehadiran, dan riwayat perizinan setiap santri.',
                    style: AppTheme.body.copyWith(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari nama, NIS, atau kelas...',
                        hintStyle: AppTheme.body.copyWith(color: AppTheme.outline),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: AppTheme.body.copyWith(color: AppTheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats bar
                  if (_santriList != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.people, size: 18, color: AppTheme.primary.withValues(alpha: 0.8)),
                          const SizedBox(width: 10),
                          Text(
                            '${_filteredSantri.length} santri ditemukan',
                            style: AppTheme.label.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Loading State
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // Error State
                  if (_error != null && !_isLoading)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_off, size: 48, color: AppTheme.error),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak dapat terhubung ke server',
                            style: AppTheme.headline.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: AppTheme.body.copyWith(fontSize: 12, color: AppTheme.outline),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          AnimatedPressButton(
                            onPressed: _loadSantri,
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

                  // Santri List
                  if (!_isLoading && _santriList != null)
                    ..._filteredSantri.map((santri) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnimatedPressButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SantriDetailScreen(santriId: santri.idSantri.toString()),
                            ),
                          );
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
                              // Avatar
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: santri.foto != null && santri.foto!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(santri.fotoUrl, fit: BoxFit.cover, width: 56, height: 56,
                                          errorBuilder: (_, e, s) => Center(
                                            child: Text(
                                              santri.nama.isNotEmpty ? santri.nama[0].toUpperCase() : '?',
                                              style: AppTheme.headline.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          santri.nama.isNotEmpty ? santri.nama[0].toUpperCase() : '?',
                                          style: AppTheme.headline.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      santri.nama,
                                      style: AppTheme.headline.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _infoChip(Icons.badge_outlined, 'NIS: ${santri.nis}'),
                                        if (santri.kelas != null) ...[
                                          const SizedBox(width: 8),
                                          _infoChip(Icons.class_outlined, santri.kelas!),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: santri.status?.toLowerCase() == 'aktif'
                                      ? AppTheme.secondaryContainer
                                      : AppTheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  (santri.status ?? 'Aktif').toUpperCase(),
                                  style: AppTheme.label.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: santri.status?.toLowerCase() == 'aktif'
                                        ? AppTheme.secondary
                                        : AppTheme.outline,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, color: AppTheme.outline, size: 20),
                            ],
                          ),
                        ),
                      ),
                    )),

                  // Empty filtered state
                  if (!_isLoading && _santriList != null && _filteredSantri.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off, size: 48, color: AppTheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada santri ditemukan',
                            style: AppTheme.headline.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.outline),
                          ),
                        ],
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.outline),
        const SizedBox(width: 4),
        Text(text, style: AppTheme.label.copyWith(fontSize: 11, color: AppTheme.outline)),
      ],
    );
  }
}
