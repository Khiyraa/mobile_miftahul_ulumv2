import 'package:mobile_miftahul_ulumv2/core/network/api_client.dart';
import 'package:mobile_miftahul_ulumv2/core/constants/api_constants.dart';
import 'package:mobile_miftahul_ulumv2/models/santri_model.dart';

class SantriService {
  final ApiClient _apiClient = ApiClient();

  Future<List<SantriModel>> getSantriByOrtu(int idOrtu) async {
    try {
      final response = await _apiClient.get(ApiConstants.santriByOrtu(idOrtu));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> listData = data['data'];
          return listData.map((e) => SantriModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      // Return empty list if error occurs to prevent crashing
      return [];
    }
  }

  Future<SantriModel?> getDetailSantri(String idSantri) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.detailSantri(idSantri),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          return SantriModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      // Return null on failure
      return null;
    }
  }
}
