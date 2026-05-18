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
    final rawIsFromAdmin = json['is_from_admin'] ?? json['isMe'];
    final isFromAdmin = rawIsFromAdmin == true || rawIsFromAdmin == 1;
    final rawTs = json['created_at'] as String? ?? json['timestamp'] as String? ?? '';
    // Parse UTC dari server lalu konversi ke waktu lokal (WIB)
    final timestamp = (DateTime.tryParse(rawTs)?.toLocal()) ?? DateTime.now();
    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      sender: isFromAdmin ? 'Pengurus Pesantren' : 'Saya',
      text: json['pesan'] as String? ?? json['text'] as String? ?? '',
      timestamp: timestamp,
      isMe: !isFromAdmin,
      attachmentType: json['attachmentType'] as String?,
      attachmentName: json['attachmentName'] as String?,
    );
  }
}
