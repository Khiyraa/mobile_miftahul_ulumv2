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
    // API mengembalikan: { id?, pesan, is_from_admin, created_at }
    // is_from_admin: true = pesan dari admin/pesantren (bukan "saya" di mobile)
    // is_from_admin: false = pesan dari wali santri ("saya" di mobile)
    final isFromAdmin = json['is_from_admin'] as bool? ?? json['isMe'] as bool? ?? false;
    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      sender: isFromAdmin ? 'Admin Pesantren' : 'Saya',
      text: json['pesan'] as String? ?? json['text'] as String? ?? '',
      timestamp: DateTime.tryParse(
            json['created_at'] as String? ?? json['timestamp'] as String? ?? '',
          ) ??
          DateTime.now(),
      isMe: !isFromAdmin,
      attachmentType: json['attachmentType'] as String?,
      attachmentName: json['attachmentName'] as String?,
    );
  }
}
