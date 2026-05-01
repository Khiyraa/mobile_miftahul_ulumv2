import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/izin_model.dart';
import 'package:mobile_miftahul_ulumv2/models/santri.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:mobile_miftahul_ulumv2/services/santri_api_service.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';

class FormIzinScreen extends StatefulWidget {
  const FormIzinScreen({super.key});

  @override
  State<FormIzinScreen> createState() => _FormIzinScreenState();
}

class _FormIzinScreenState extends State<FormIzinScreen> {
  String? _selectedSantri;
  String _selectedJenisIzin = 'sakit';
  DateTime? _selectedDate;
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;

  // Data santri dari API
  List<Santri> _santriList = [];
  bool _isLoadingSantri = true;

  @override
  void initState() {
    super.initState();
    _loadSantriList();
  }

  Future<void> _loadSantriList() async {
    try {
      // Menggunakan ID orang tua placeholder — nanti diambil dari SharedPreferences
      final response = await SantriApiService.getSantriByOrtuIdFromMobile('1');
      if (mounted) {
        setState(() {
          if (response.success && response.data != null && response.data!.isNotEmpty) {
            _santriList = response.data!;
          }
          _isLoadingSantri = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSantri = false);
    }
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_selectedSantri == null || _selectedDate == null || _keteranganController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap lengkapi semua field'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final izin = IzinRequestModel(
        idSantri: _selectedSantri!,
        jenisIzin: _selectedJenisIzin,
        startDate: _selectedDate!.toIso8601String().split('T').first,
        endDate: _selectedDate!.toIso8601String().split('T').first,
        alasan: _keteranganController.text.trim(),
      );

      final success = await ApiService().submitIzin(izin);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pengajuan izin berhasil dikirim!'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal mengirim pengajuan izin'),
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
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  hoverColor: AppTheme.surfaceContainerLow,
                ),
                onPressed: () {
                  // Wait, this is part of the bottom nav normally, or can be pushed.
                  // Just standard pop if pushed. If bottom nav, this doesn't pop.
                },
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
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 24),
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAJDpgMtUB7QyTIReKxLclqds2h7vqdBoRAUvwi-JbVHmJdzb5LutGzd_PJAOk9vn2AYQbbiecx1VmBZA5r2BY-L-MRHjkJQHRDCdOsLpuiYs30Pa-2MLJEhF82hW16JioiDhqogxZfqn9rgMFkKkTVlNRUEw65K-bgSKsA1Olo1ZDqCTZYWY7KrAE_IltiRHHZQAn6mpoRt-zCS3HRdpT5b-_CcBbCUISDgyfus1hYlGNUwLVkWXAF7sow33rCpH30k2_yMOoPgV6g',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                // Hero Section / Context
                Text(
                  'Form Pengajuan Izin',
                  style: AppTheme.headline.copyWith(
                    fontSize: 28, // text-3xl
                    fontWeight: FontWeight.w800, // font-extrabold
                    letterSpacing: -0.5,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan lengkapi formulir di bawah ini untuk mengajukan permohonan izin santri.',
                  style: AppTheme.body.copyWith(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),

                // Main Form Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(32), // rounded-[2rem]
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF191C1B).withValues(alpha: 0.06),
                        blurRadius: 48,
                        offset: const Offset(0, 24),
                        spreadRadius: -12,
                      )
                    ], // editorial-shadow
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Santri Field
                      _buildLabel('Nama Santri'),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: _isLoadingSantri
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : DropdownButton<String>(
                            value: _selectedSantri,
                            hint: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Pilih Santri', style: AppTheme.body.copyWith(color: AppTheme.outline)),
                            ),
                            isExpanded: true,
                            icon: const Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.expand_more, color: AppTheme.outline),
                            ),
                            style: AppTheme.body.copyWith(color: AppTheme.onSurface, fontSize: 14),
                            dropdownColor: AppTheme.surfaceContainerLowest,
                            items: _santriList.isNotEmpty
                                ? _santriList.map((s) {
                                    return DropdownMenuItem(
                                      value: s.idSantri.toString(),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(s.nama),
                                      ),
                                    );
                                  }).toList()
                                : const [
                                    DropdownMenuItem(value: '1', child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Ahmad Zaki'))),
                                    DropdownMenuItem(value: '2', child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Muhammad Ridwan'))),
                                    DropdownMenuItem(value: '3', child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Fathan Al-Ghifari'))),
                                  ],
                            onChanged: (val) {
                              setState(() {
                                _selectedSantri = val;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tanggal Izin Field
                      _buildLabel('Tanggal Izin'),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          style: AppTheme.body.copyWith(fontSize: 14, color: AppTheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Pilih Tanggal',
                            hintStyle: AppTheme.body.copyWith(color: AppTheme.outline),
                            suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.outline),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDate = date;
                                _dateController.text = '${date.day}/${date.month}/${date.year}';
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Jenis Izin Selection
                      _buildLabel('Jenis Izin'),
                      Row(
                        children: [
                          Expanded(child: _buildRadioOption('Sakit', 'sakit', Icons.medical_services)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildRadioOption('Lainnya', 'lainnya', Icons.pending_actions)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Keterangan Field
                      _buildLabel('Keterangan'),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _keteranganController,
                          maxLines: 4,
                          style: AppTheme.body.copyWith(fontSize: 14, color: AppTheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Jelaskan alasan atau detail izin di sini...',
                            hintStyle: AppTheme.body.copyWith(color: AppTheme.outline),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      AnimatedPressButton(
                        onPressed: _isLoading ? () {} : _onSubmit,
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
                                  'Ajukan Izin',
                                  style: AppTheme.headline.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.send,
                                  color: AppTheme.onPrimary,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'AKSI INI AKAN MENGIRIM NOTIFIKASI KE PENGURUS',
                          style: AppTheme.label.copyWith(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            color: AppTheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Informational Card
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.info_outline, color: AppTheme.secondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ketentuan Perizinan',
                              style: AppTheme.headline.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Setiap pengajuan izin harus disetujui oleh Kepala Asrama atau bagian Kesiswaan minimal 3 jam sebelum keberangkatan.',
                              style: AppTheme.body.copyWith(
                                fontSize: 12,
                                height: 1.5,
                                color: AppTheme.onSecondaryContainer.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )

              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: AppTheme.headline.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title, String value, IconData icon) {
    bool isSelected = _selectedJenisIzin == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedJenisIzin = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.05) : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTheme.label.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
