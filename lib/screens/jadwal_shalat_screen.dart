import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';

class JadwalShalatScreen extends StatelessWidget {
  const JadwalShalatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.onSurface),
        title: Text(
          'Jadwal Shalat',
          style: AppTheme.headlineSm,
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Hero section with gradient
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: AppTheme.ambientShadow,
            ),
            child: Column(
              children: [
                Text(
                  '11:45',
                  style: AppTheme.displayMd.copyWith(color: AppTheme.onPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Menuju Waktu Dhuhur',
                  style: AppTheme.bodyLg.copyWith(color: AppTheme.onPrimary.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Jadwal Hari Ini', style: AppTheme.titleMd),
          const SizedBox(height: 16),
          _buildJadwalItem('Subuh', '04:15'),
          _buildJadwalItem('Dzuhur', '11:45', isActive: true),
          _buildJadwalItem('Ashar', '15:00'),
          _buildJadwalItem('Maghrib', '17:45'),
          _buildJadwalItem('Isya', '19:00'),
        ],
      ),
    );
  }

  Widget _buildJadwalItem(String name, String time, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.surfaceContainerLow : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive ? AppTheme.ambientShadow : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: AppTheme.bodyLg.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primary : AppTheme.onSurface,
            ),
          ),
          Text(
            time,
            style: AppTheme.bodyLg.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
