import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/storage/session_storage.dart';
import 'package:mobile_miftahul_ulumv2/models/santri_model.dart';
import 'package:mobile_miftahul_ulumv2/models/kehadiran_summary_model.dart';
import 'package:mobile_miftahul_ulumv2/services/santri_service.dart';
import 'package:mobile_miftahul_ulumv2/services/kehadiran_service.dart';

class DashboardProvider extends ChangeNotifier {
  final SantriService _santriService = SantriService();
  final KehadiranService _kehadiranService = KehadiranService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SantriModel> _santriList = [];
  List<SantriModel> get santriList => _santriList;

  SantriModel? _selectedSantri;
  SantriModel? get selectedSantri => _selectedSantri;

  KehadiranSummaryModel? _kehadiranSummary;
  KehadiranSummaryModel? get kehadiranSummary => _kehadiranSummary;

  String _parentName = '';
  String get parentName => _parentName;

  DashboardProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _setLoading(true);
    try {
      final username = await SessionStorage.getUsername();
      _parentName = username ?? '';

      final idAkun = await SessionStorage.getIdAkun();
      if (idAkun != null) {
        await fetchSantriByOrtu(idAkun);
      } else {
        _setError('Session tidak valid. Silakan login kembali.');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchSantriByOrtu(int idOrtu) async {
    try {
      _santriList = await _santriService.getSantriByOrtu(idOrtu);
      if (_santriList.isNotEmpty) {
        _selectedSantri = _santriList.first;
        await fetchKehadiranSummary(_selectedSantri!.idSantri);
      }
      _errorMessage = null;
    } catch (e) {
      _setError('Gagal memuat data santri.');
    }
  }

  Future<void> fetchKehadiranSummary(String idSantri) async {
    try {
      _kehadiranSummary = await _kehadiranService.getKehadiranSummary(idSantri);
      notifyListeners();
    } catch (e) {
      // Gagal ambil summary kehadiran, bisa diabaikan atau diset null
      _kehadiranSummary = null;
      notifyListeners();
    }
  }

  void selectSantri(SantriModel santri) {
    _selectedSantri = santri;
    notifyListeners();
    fetchKehadiranSummary(santri.idSantri);
  }

  Future<void> refresh() async {
    final idAkun = await SessionStorage.getIdAkun();
    if (idAkun != null) {
      _setLoading(true);
      await fetchSantriByOrtu(idAkun);
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
