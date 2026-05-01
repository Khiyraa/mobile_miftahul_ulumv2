class FaqModel {
  final String id;
  final String category;
  final String question;
  final String answer;

  FaqModel({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}
