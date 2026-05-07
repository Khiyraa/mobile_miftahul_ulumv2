import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/chat_message_model.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late Future<List<ChatMessageModel>> _chatFuture;

  // ID orang tua — nanti bisa disesuaikan dengan data SharedPreferences/Login
  final String _parentId = '1';

  // Data fallback lokal saat API belum tersedia
  final List<ChatMessageModel> _fallbackMessages = [
    ChatMessageModel(
      id: '1',
      sender: 'Ust. Abdullah (Admin)',
      text: 'Assalamualaikum, Ibu Rahma. Terkait perkembangan tahfidz Ananda Zaid, saat ini progressnya sudah mencapai Juz 28 dengan makhraj yang semakin baik.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isMe: false,
    ),
    ChatMessageModel(
      id: '2',
      sender: 'Ibu Rahma (Parent)',
      text: "Wa'alaikumussalam, Ustadz. Alhamdulillah, terima kasih atas infonya. Apakah ada catatan khusus untuk murojaahnya di rumah saat liburan nanti?",
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isMe: true,
    ),
    ChatMessageModel(
      id: '3',
      sender: 'Ust. Abdullah (Admin)',
      text: 'Tentu, Bu. Kami menyarankan untuk fokus pada pengulangan Surah Al-Mulk dan Al-Qalam agar hafalannya semakin mutqin. Kami akan kirimkan checklist murojaahnya ya.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isMe: false,
      attachmentType: 'pdf',
      attachmentName: 'Weekly Progress Report',
    ),
    ChatMessageModel(
      id: '4',
      sender: 'Ibu Rahma (Parent)',
      text: 'Baik Ustadz, saya tunggu checklistnya. Jazakallahu khairan.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      isMe: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
  }

  void _fetchChatHistory() {
    _chatFuture = ApiService().getChatHistory(_parentId);
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Kosongkan field agar UI terasa responsif langsung
    _messageController.clear();

    // Panggil API Send Message
    final success = await ApiService().sendMessage(_parentId, messageText);

    if (success) {
      // Jika berhasil, refresh data chat untuk menampilkan pesan baru
      if (mounted) {
        setState(() {
          _fetchChatHistory();
        });
      }
    } else {
      // Jika gagal, kembalikan teks ke kolom input dan tampilkan notif
      _messageController.text = messageText;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // TopAppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDjRfOIiFrXY7ReaIl1Fl7rxhznekqSjuhDnlefUJfjIaOYKlCzZMa7WLMV5tpCZzhbJB8shcIG_uqN-FDaxNavMLEUUBMLROvBPlAVmr8vegSiu8w5wn0hTFwVrJ6dxpiKqdU08y-FIOxBpOdxkTV2jN1NV3t4apOOWrYGAqP0KyfLTbj25bOj7qkalrd1NVejTNWPwOQasqgTg5KJsKwC6LaVBF71oEtvAyRPIsAhCCFyTEFLzUWGHzzG0gfCHr7XNdNiA7Vcqymf',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Miftahul Ulum Kalisat',
                      style: AppTheme.headline.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -1,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      'ADMIN SUPPORT',
                      style: AppTheme.label.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
                style: IconButton.styleFrom(
                  hoverColor: AppTheme.surfaceContainerLow,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Message Container — FutureBuilder
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 160),
            sliver: FutureBuilder<List<ChatMessageModel>>(
              future: _chatFuture,
              builder: (context, snapshot) {
                // Tentukan pesan yang akan ditampilkan
                List<ChatMessageModel> messages;

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  messages = snapshot.data!;
                } else {
                  // Gunakan fallback lokal jika API belum terhubung/kosong
                  messages = _fallbackMessages;
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // Date Indicator
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'TODAY',
                          style: AppTheme.label.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Render semua pesan dari API/fallback
                    ...messages.expand((msg) {
                      List<Widget> widgets = [];

                      widgets.add(
                        _buildMessageBubble(
                          isSender: msg.isMe,
                          name: msg.sender,
                          time: _formatTime(msg.timestamp),
                          text: msg.text,
                        ),
                      );

                      // Tampilkan attachment jika ada
                      if (msg.attachmentType != null && msg.attachmentName != null) {
                        widgets.add(const SizedBox(height: 12));
                        widgets.add(_buildAttachmentCard(msg.attachmentType!, msg.attachmentName!));
                      }

                      widgets.add(const SizedBox(height: 24));
                      return widgets;
                    }),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
      
      // Floating Input Field
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80, left: 24, right: 24),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.outline),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                hoverColor: AppTheme.surfaceContainerLow,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: AppTheme.body.copyWith(color: AppTheme.outline),
                  border: InputBorder.none,
                ),
                // Opsional: Kirim pesan ketika user menekan enter di keyboard
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: IconButton(
                icon: const Icon(Icons.send, size: 18, color: AppTheme.onPrimary),
                // Ubah onPressed memanggil fungsi _sendMessage()
                onPressed: _sendMessage,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentCard(String type, String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              type == 'pdf' ? Icons.auto_stories : Icons.attach_file,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name Attached',
                  style: AppTheme.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  '${type.toUpperCase()} Document',
                  style: AppTheme.body.copyWith(
                    fontSize: 11,
                    color: AppTheme.outline,
                  ),
                )
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.download, size: 14, color: AppTheme.onSurface),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isSender,
    required String name,
    required String time,
    required String text,
  }) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSender) ...[
                  Text(
                    name,
                    style: AppTheme.body.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: -0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(time, style: AppTheme.body.copyWith(fontSize: 10, color: AppTheme.outline)),
                ] else ...[
                  Text(time, style: AppTheme.body.copyWith(fontSize: 10, color: AppTheme.outline)),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: AppTheme.body.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.onSurface, letterSpacing: -0.5),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSender ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isSender ? 16 : 0),
                  bottomRight: Radius.circular(isSender ? 0 : 16),
                ),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Text(
                text,
                style: AppTheme.body.copyWith(
                  color: isSender ? AppTheme.onPrimaryContainer : AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            if (isSender) ...[
              const SizedBox(height: 4),
              const Icon(Icons.done_all, size: 14, color: AppTheme.primary),
            ]
          ],
        ),
      ),
    );
  }
}