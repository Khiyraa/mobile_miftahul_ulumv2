/// Model FAQ yang sinkron dengan schema database backend (tabel `faqs`).
///
/// Field backend → field Dart:
///   id          → id
///   pertanyaan  → pertanyaan
///   jawaban     → jawaban
///   kategori    → kategori
///   urutan      → urutan
///   is_active   → isActive
class FaqModel {
  final int id;
  final String pertanyaan;
  final String jawaban;
  final String kategori;
  final int urutan;
  final bool isActive;

  const FaqModel({
    required this.id,
    required this.pertanyaan,
    required this.jawaban,
    required this.kategori,
    required this.urutan,
    required this.isActive,
  });

  /// Bangun [FaqModel] dari JSON yang dikirim endpoint `GET /api/faq`.
  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id:         (json['id'] as num?)?.toInt() ?? 0,
      pertanyaan: (json['pertanyaan'] as String?) ?? '',
      jawaban:    (json['jawaban']    as String?) ?? '',
      kategori:   (json['kategori']   as String?) ?? 'Umum',
      urutan:     (json['urutan']     as num?)?.toInt() ?? 0,
      isActive:   (json['is_active']  as bool?)   ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'pertanyaan': pertanyaan,
    'jawaban':    jawaban,
    'kategori':   kategori,
    'urutan':     urutan,
    'is_active':  isActive,
  };
}

/// Response wrapper dari endpoint `GET /api/faq`.
class FaqResponse {
  final bool success;
  final List<FaqModel> data;
  final List<String> kategoris;
  final int total;

  const FaqResponse({
    required this.success,
    required this.data,
    required this.kategoris,
    required this.total,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    final rawData      = json['data']      as List<dynamic>? ?? [];
    final rawKategoris = json['kategoris'] as List<dynamic>? ?? [];

    return FaqResponse(
      success:   (json['success'] as bool?) ?? false,
      data:      rawData.map((e) => FaqModel.fromJson(e as Map<String, dynamic>)).toList(),
      kategoris: rawKategoris.map((e) => e.toString()).toList(),
      total:     (json['total'] as num?)?.toInt() ?? rawData.length,
    );
  }
}
