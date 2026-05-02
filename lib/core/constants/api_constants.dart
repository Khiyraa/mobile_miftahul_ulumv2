class ApiConstants {
  static const String baseUrl = "http://127.0.0.1:8000";

  // TODO: Sesuaikan dengan routes/api.php jika ada perubahan endpoint

  // Auth
  static const String login = "$baseUrl/api/login";

  // Santri
  static String santriByOrtu(int idOrtu) => "$baseUrl/api/santri/ortu/$idOrtu";
  static String detailSantri(String idSantri) =>
      "$baseUrl/api/santri/$idSantri";

  // Pengumuman
  static const String pengumuman = "$baseUrl/api/pengumuman";

  // Kehadiran
  static String kehadiranMingguan(String idSantri) =>
      "$baseUrl/api/kehadiran/mingguan/$idSantri";
  static String kehadiranSummary(String idSantri) =>
      "$baseUrl/api/kehadiran/summary/$idSantri";

  // Perizinan
  static String perizinan(String idSantri) =>
      "$baseUrl/api/perizinan/$idSantri";

  // Chat
  static String chat(int parentId) => "$baseUrl/api/chat/$parentId";
}
