import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/widgets/primary_button.dart';

class FormIzinScreen extends StatelessWidget {
  const FormIzinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.onSurface),
        title: Text(
          'Form Pengajuan Izin',
          style: AppTheme.headlineSm,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Izin', style: AppTheme.titleMd),
                  const SizedBox(height: 24),
                  _buildInputRow('Jenis Izin', 'Sakit'),
                  const SizedBox(height: 16),
                  _buildInputRow('Tanggal Mulai', '12 Okt 2026'),
                  const SizedBox(height: 16),
                  _buildInputRow('Tanggal Selesai', '14 Okt 2026'),
                  const SizedBox(height: 24),
                  Text('Keterangan', style: AppTheme.labelMd),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Mohon izin pulang karena sakit demam dan butuh istirahat.',
                      style: AppTheme.bodyMd.copyWith(color: AppTheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Ajukan Izin',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Izin berhasil diajukan')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMd),
          Text(value, style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
