class ChatMessageModel {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final String? attachmentType;
  final String? attachmentName;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.attachmentType,
    this.attachmentName,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isMe: json['isMe'] ?? false,
      attachmentType: json['attachmentType'],
      attachmentName: json['attachmentName'],
    );
  }
}
