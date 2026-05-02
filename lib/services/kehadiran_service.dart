import 'package:mobile_miftahul_ulumv2/core/network/api_client.dart';
import 'package:mobile_miftahul_ulumv2/core/constants/api_constants.dart';
import 'package:mobile_miftahul_ulumv2/models/kehadiran_mingguan_model.dart';
import 'package:mobile_miftahul_ulumv2/models/kehadiran_summary_model.dart';

class KehadiranService {
  final ApiClient _apiClient = ApiClient();

  Future<List<KehadiranMingguanModel>> getKehadiranMingguan(
    String idSantri,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.kehadiranMingguan(idSantri),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> listData = data['data'];
          return listData
              .map((e) => KehadiranMingguanModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<KehadiranSummaryModel?> getKehadiranSummary(String idSantri) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.kehadiranSummary(idSantri),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          return KehadiranSummaryModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
